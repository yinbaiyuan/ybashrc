#!/bin/bash

. $HOME/ybashrc/command-common.sh

gitRestoreFile()
{
    if [ $1 == "??" ]; then
        return
    fi

    echoEmptyLine
    echoCyan "$2 差异："
    echoCyan "-----------------------------------------------------------------------"
    git diff HEAD $2
    echoCyan "======================================================================="
        
    commandInput "Skip rst cancel" "是否添加 $2 到暂存区？" "跳过此文件 重置此文件的变动 退出流程"
    result=$GLOBAL_INPUT_RESULT
    case $result in
        skip )
            echoYellow "跳过 $2"
            ;;
        rst ) 
            cmdExecute "git reset $2"
            cmdExecute "git restore $2"
            ;;
        cancel ) 
            echoYellow "退出流程"
            exit 1
            ;;
        * ) echoRed "错误命令！"
            exit 1
    esac
}

gitRestoreCustom()
{
    gssInfo=$(git status -s)
    tempIFS="$IFS"
    IFS=$'\n'
    gssInfoArr=($gssInfo)
    IFS="$tempIFS"
    for(( i=0;i<${#gssInfoArr[@]};i++)) do 
        gitRestoreFile ${gssInfoArr[i]}
    done;
}


gitRestoreAction()
{
    echoEmptyLine ""
    echoCyan "请检查 当前分支跟踪状态："
    echoCyan "-----------------------------------------------------------------------"
    git status -s
    echoCyan "======================================================================="

    commandInput "Custom all no skip" "是否重置 以上暂存区文件？" "每个文件独立处理 重置所有变动 退出流程 跳过"
    result=$GLOBAL_INPUT_RESULT
    case $result in
        custom ) 
            gitRestoreCustom
            ;;
        all ) 
            cmdExecute "git reset ."
            cmdExecute "git restore ."
            ;;
        no ) echoYellow "请手动执行 'git reset <file>...' 命令将部分文件从暂存区重置"
            exit 1
            ;;
        skip ) echoGreen "保持当前暂存区不变"
            ;;
        * ) echoRed "错误命令"
            exit 1
    esac
}

gitRestoreAction $@
