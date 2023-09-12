#!/bin/bash

. $HOME/ybashrc/command-common.sh


gitAddUntrackedFile()
{
    git add $1 
    echoEmptyLine
    echoCyan "$1 为未跟踪文件："
    echoCyan "======================================================================="
    git diff HEAD $1  
    echoCyan "======================================================================="

    commandInput "Add skip cancel" "是否添加 $1 到暂存区？" "添加到暂存区 跳过此文件 退出流程"
    result=$GLOBAL_INPUT_RESULT
    case $result in
        add )
            cmdExecute "git add $1"
            ;;
        skip ) 
            git restore --staged $1
            ;;
        cancel ) echoYellow "退出流程"
            git restore --staged $1
            exit 1
            ;;
        * ) echoRed "错误命令！"
            exit 1
    esac
}

gitAddTrackedFile()
{
    echoEmptyLine
    echoCyan "$1 差异："
    echoCyan "======================================================================="
    git diff HEAD $1
    echoCyan "======================================================================="
        
    commandInput "Add skip restore rst cancel" "是否添加 $1 到暂存区？" "添加到暂存区 跳过此文件 将此文件移到非暂存区 将此文件重置 退出流程"
    result=$GLOBAL_INPUT_RESULT
    case $result in
        add )
            cmdExecute "git add $1"
            ;;
        skip ) 
            echoYellow "跳过 $1"
            ;;
        restore )
            cmdExecute "git restore --staged $1"
            ;;
        rst )
            cmdExecute "git reset $1"
            cmdExecute "git restore $1"
            ;;
        cancel ) echoYellow "退出流程"
            exit 1
            ;;
        * ) echoRed "错误命令！"
            exit 1
    esac

}

gitAddFile()
{
    if [ $1 == "??" ]; then
        gitAddUntrackedFile $2
    else
        gitAddTrackedFile $2
    fi
    

}

gitAddCustom()
{
    gssInfo=$(git status -s)
    tempIFS="$IFS"
    IFS=$'\n'
    gssInfoArr=($gssInfo)
    IFS="$tempIFS"
    for(( i=0;i<${#gssInfoArr[@]};i++)) do 
        gitAddFile ${gssInfoArr[i]}
    done;
}

gitAddAction()
{
    echoEmptyLine
    echoCyan "请检查 当前分支跟踪状态："
    echoCyan "-----------------------------------------------------------------------"
    git status -s
    echoCyan "======================================================================="

    commandInput "Custom all no skip" "是否添加 以上到暂存区？" "每个文件独立处理 添加所有 退出流程 跳过"
    result=$GLOBAL_INPUT_RESULT
    echoEmptyLine
    case $result in
        custom )
            gitAddCustom
            echoEmptyLine
            echoCyan "请再次检查 当前分支跟踪状态："
            echoCyan "-----------------------------------------------------------------------"
            git status -s
            echoCyan "======================================================================="
            ;;
        all ) 
            cmdExecute "git add ."
            echoEmptyLine
            echoCyan "请再次检查 当前分支跟踪状态："
            echoCyan "-----------------------------------------------------------------------"
            git status -s
            echoCyan "======================================================================="
            ;;
        no ) 
            echoYellow "请手动执行 'git add <file>...' 命令将部分文件添加到暂存区。"
            exit 1
            ;;
        skip ) 
            echoGreen "保持当前暂存区不变。"
            ;;
        * ) 
            echoRed "错误命令！"
            exit 1
    esac
}

gitAddAction $@
