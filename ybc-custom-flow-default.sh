#!/bin/bash

. $HOME/ybashrc/command-common.sh

customFlowStart()
{
    echo ""
}

main() 
{
    commandArr="cmd1 cmd2 cmd3"
    commandDesc="cmd1介绍 cmd2介绍 cmd3介绍"
    inputQuestion="请输入流程名称"
    command=""
    if [ -z $1 ];then  
        commandInput "$commandArr" "$inputQuestion" "$commandDesc"
        command="$GLOBAL_INPUT_RESULT"
    else
        command=${1,,}
    fi
    case $command in
        cmd1 ) 
            
            ;;
        cmd2 ) 
            makeX86
            ;;
        cmd3 ) 
            scpFile
            ;;
        * ) 
            echoRed "[ERROR] 流程名称错误!"
            exit 1
    esac
}

main $@