#!/bin/bash

. $HOME/ybashrc/command-common.sh



gitCleanFile()
{
    if [ $1 != "??" ]; then
        return
    fi

    git add $2
    echoEmptyLine
    echoCyan "$2 为未跟踪文件："
    echoCyan "-----------------------------------------------------------------------"
    git diff HEAD $2
    echoCyan "======================================================================="
    git restore --staged $2

    commandInput "Skip yes cancel" "是否删除 $2 ？"
    result=$GLOBAL_INPUT_RESULT
    case $result in
        skip )
            echoYellow "跳过 $2"
            ;;
        yes ) 
            cmdExecute "rm $2"
            ;;
        cancel ) echoYellow "退出流程"
            exit 1
            ;;
        * ) echoRed "错误命令！"
            exit 1
    esac
}

gitCleanCustom()
{
    gssInfo=$(git status -s)
    tempIFS="$IFS"
    IFS=$'\n'
    gssInfoArr=($gssInfo)
    IFS="$tempIFS"
    for(( i=0;i<${#gssInfoArr[@]};i++)) do 
        gitCleanFile ${gssInfoArr[i]}
    done;
}


gitCleanAction()
{
    echoEmptyLine ""
    echoCyan "请检查 当前分支跟踪状态："
    echoCyan "-----------------------------------------------------------------------"
    git status -s
    echoCyan "======================================================================="

    commandInput "Custom all no skip" "是否删除 以上未跟踪文件"
    result=$GLOBAL_INPUT_RESULT
    case $result in
        custom ) 
            gitCleanCustom
            ;;
        all ) 
            echoYellow "确定要删除以下文件吗"
            git clean -nf
            commandInput "No yes" "确定删除 以上所有文件吗"
            subResult=$GLOBAL_INPUT_RESULT
            case $subResult in
                No ) echoYellow "放弃删除 退出"
                    exit 0
                ;;
                yes )
                    cmdExecute "git clean -f"
                ;;
                * ) echoRed "错误命令"
                    exit 1
            esac
            ;;
        no ) 
            echoYellow "请手动执行 'git clean <file>...' 命令将未跟踪文件删除"
            exit 0
            ;;
        skip ) 
            echoGreen "保持当前未跟踪文件不变"
            ;;
        * ) echoRed "错误命令"
            exit 1
    esac
}

gitCleanAction $@