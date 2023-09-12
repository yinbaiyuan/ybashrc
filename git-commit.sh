#!/bin/bash

. $HOME/ybashrc/command-common.sh

gitCommitAction()
{
    commandInput "Yes no skip" "是否提交 暂存区内容？"
    result=$GLOBAL_INPUT_RESULT
    case $result in
        yes ) messageInput "请输入 提交信息："
            msg=$GLOBAL_INPUT_RESULT
            cmdExecute "git commit -m" "\"$msg\""
            ;;
        no ) 
            echoYellow "取消提交！"
            exit 1
            ;;
        skip ) 
            echoYellow "跳过提交！"
            ;;
        * ) echoRed "错误命令！"
            exit 1
    esac
}

gitCommitAction $@
