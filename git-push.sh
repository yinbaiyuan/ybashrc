#!/bin/bash

. $HOME/ybashrc/command-common.sh

pushToRemoteBranch()
{
    # echoGreen "正在向提交 $1/$2 分支提交数据"
    cmdExecute "git push $1 $2"
}

pushCurrentBranchToNewRemoteBranch()
{
    remoteRepos=$(git remote)
    tempIFS="$IFS"
    IFS=$'\n'
    paraStr=""
    for para in $remoteRepos;do
        paraStr="$paraStr"" $para"
        seq=$((seq+1))
    done
    IFS="$tempIFS"
    paraStr=${paraStr:1}
    multiSelectInput "$paraStr" "请选择 要推送到的远程分支："
    result=$GLOBAL_INPUT_RESULT
    for input in $result;do
        pushToRemoteBranch $input $CURRENT_GLOGAL_BRANCH
    done
}

gitPushAction()
{
    currentLocalBranch=$(git branch --show-current)
    remoteBranchList=$(git branch -r)
    tempIFS="$IFS"
    IFS=$'\n'
    paraStr=""
    for para in $remoteBranchList;do
        if [[ ! $para =~ "->" ]]
        then
            if [[ $para =~ "$currentLocalBranch" ]]
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
    paraStr="$paraStr create_new_remote_branch"

    multiSelectInput "$paraStr" "请选择 要推送到的远程分支："
    result=$GLOBAL_INPUT_RESULT
    
    for input in $result;do
        
        if [ "create_new_remote_branch" == "$input" ];
        then         
            pushCurrentBranchToNewRemoteBranch
        else
            branchInfoArr=(${input//// }) 
            pushToRemoteBranch ${branchInfoArr[0]} ${branchInfoArr[1]}
        fi
    done
}

gitPushAction $@

