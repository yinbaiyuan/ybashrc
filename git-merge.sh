#!/bin/bash

. $HOME/ybashrc/command-common.sh

mergeRemoteBranchToLocal()
{
    remoteBranchList=$(git branch -r)
    tempIFS="$IFS"
    IFS=$'\n'
    paraStr=""
    for para in $remoteBranchList;do
        if [[ ! $para =~ "->" ]]
        then
            if [[ $para =~ "$CURRENT_GLOGAL_BRANCH" ]]
            then
                paraStr="$paraStr""$para"
            else
                continue
            fi
        else
            continue
        fi
    done
    IFS="$tempIFS"
    paraStr=${paraStr:2}

    multiSelectInput "$paraStr" "请选择 要合并的远程分支："
    result=$GLOBAL_INPUT_RESULT

    for input in $result;do
        echo ""
        echoCyan "当前分支 $CURRENT_GLOGAL_BRANCH 与远程分支 $input 的差异如下"
        echoCyan "-----------------------------------------------------------------------"
        cmdExecute "git diff --name-status $CURRENT_GLOGAL_BRANCH..$input"
        echoCyan "======================================================================="

        commandInput "Yes no skip" "是否合并"
        subResult=$GLOBAL_INPUT_RESULT
        case $subResult in
            yes ) cmdExecute "git merge $CURRENT_GLOGAL_BRANCH $input"
                ;;
            no ) echo ""
                echoYellow "取消合并"
                exit 1
                ;;
            skip ) echo ""
                echoYellow "跳过 $input 合并到 $CURRENT_GLOGAL_BRANCH"
                continue
                ;;
            * ) echo ""
                echoRed "[ERROR]错误命令"
                exit 1
        esac
    done
}

createNewLocalBranchFromRemote()
{
    # git checkout -b localName github/remoteName
    remoteBranchList=$(git branch -r)
    localBranchList=$(git branch -l)
    tempIFS="$IFS"
    IFS=$'\n'
    paraStr=""
    for para in $remoteBranchList;do
        contain="no"
        if [[ $para =~ "->" ]];then
            contain="yes"
        fi
        for localPara in $localBranchList;do
            if [[ $localPara =~ $CURRENT_GLOGAL_BRANCH ]];then
                localPara=${localPara:2}
            fi
            localPara=`echo $localPara | sed -e 's/^[ \t]*//g'`
            # if [[ $para =~ "$localPara" ]];then
            #     contain="yes"
            #     continue
            # fi
        done
        if [ "$contain" == "no" ];
        then
            paraStr="$paraStr""$para"
        fi
    done
    IFS="$tempIFS"

    if [ "$paraStr" == "" ];then
        echoYellow "所有远程分支都已经有对应的本地分支，无法创建"
        exit 1
    fi

    singleSelectInput "$paraStr" "请选择 基于哪个远程分支创建同名称的本地分支"
    result=$GLOBAL_INPUT_RESULT

    branchInfoArr=(${result//// }) 

    echoGreen "正在基于 $result 分支创建本地分支 ${branchInfoArr[1]}"
    cmdExecute "git checkout -b ${branchInfoArr[1]} $result"
}

selectLocalBranch()
{
    echo ""
    echoDefault "当前本地分支：" -n ; echoCyanUnderline $CURRENT_GLOGAL_BRANCH 

    localBranches=$(git branch -l)
    tempIFS="$IFS"
    IFS=$'\n'
    paraStr=""
    for para in $localBranches;do
        if [[ $para =~ "$CURRENT_GLOGAL_BRANCH" ]]
        then
            paraStr="$paraStr""$para"
            break
        fi
    done
    for para in $localBranches;do
        if [[ $para =~ "$CURRENT_GLOGAL_BRANCH" ]]
        then
            continue
        else
            paraStr="$paraStr""$para"
        fi
    done
    IFS="$tempIFS"
    paraStr=${paraStr:2}
    paraStr="$paraStr create_new_local_branch_from_remote"

    singleSelectInput "$paraStr" "请输入 要切换到的本地分支，直接回车保持在当前分支"
    result=$GLOBAL_INPUT_RESULT

    if [ "create_new_local_branch_from_remote" == "$result" ];
    then         
        createNewLocalBranchFromRemote
        return
    elif [ "$CURRENT_GLOGAL_BRANCH" == "$result" ];
    then
        mergeRemoteBranchToLocal
    else
        cmdExecute "git checkout $result"
        CURRENT_GLOGAL_BRANCH=$(git branch --show-current)
        mergeRemoteBranchToLocal
    fi
}

selectLocalBranch $@
