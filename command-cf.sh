#!/bin/bash

. $HOME/ybashrc/command-common.sh

main()
{
    if [ -f "ybc-custom-flow.sh" ];then
        . ybc-custom-flow.sh $@
        if [ $? != "0" ]; then return; fi
    else
        echoEmptyLine
        echoRed "$PWD/ybc-custom-flow.sh 文件不存在！请创建后再试"

        commandInput "No yes" "是否创建ybc-custom-flow.sh文件"
        result=$GLOBAL_INPUT_RESULT
        case $result in
            no ) 
                echoYellow "退出流程"
                exit 0
                ;;
            yes ) 
                echoYellow "请手动执行 'git clean <file>...' 命令将未跟踪文件删除"
                cmdExecute "cp $HOME/ybashrc/ybc-custom-flow-default.sh ybc-custom-flow.sh"
                exit 0
                ;;
            * ) echoRed "错误命令"
                exit 1
        esac
    fi
}

main $@


