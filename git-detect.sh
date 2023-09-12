#!/bin/bash

. $HOME/ybashrc/command-common.sh

gitDetectAction()
{
    if [ ! -d ".git" ];then
        echoRed "当前目录不是 git 仓库的根目录！"
        exit 1
    else
        export CURRENT_GLOGAL_BRANCH=$(git branch --show-current)
        echoEmptyLine
        echoDefault "当前本地分支：" -n;echoCyanUnderline $CURRENT_GLOGAL_BRANCH 
    fi
}

gitDetectAction $@
