#!/bin/bash

GLOBAL_NEVER_INPUT="####never_input####"

#颜色输出##########################################
echoColor()
{
    if [ ! $3 ]
    then
        printf  "\e[%sm%s\e[0m\n"  "$2" "$1"
    else
        printf  "\e[%sm%s\e[0m" "$2" "$1"
    fi
}

echoColorUnderline()
{
    if [ ! $3 ]
    then
        printf  "\e[%sm\e[4m%s\e[0m\n"  "$2" "$1"
    else
        printf  "\e[%sm\e[4m%s\e[0m" "$2" "$1"
    fi
}

echoEmptyLine()
{
    printf "\n"
}

echoNormal()
{
    echoColor "$1" "0" "$2"
}

echoRed()
{
    echoColor "$1" "31" "$2"
}

echoGreen()
{
    echoColor "$1" "32" "$2"
}

echoYellow()
{
    echoColor "$1" "93" "$2"
}

echoCyan()
{
    echoColor "$1" "36" "$2"
}

echoCyanUnderline()
{
    echoColorUnderline "$1" "96" "$2"
}

echoDefault()
{
    echoColor "$1" "39" "$2"
}

#执行命令##########################################
cmdExecute()
{
    echoEmptyLine
    echoCyan "正在执行 '$1' 命令...  " 
    if [ "$2" ];then
        $1 "$2"
    else
        $1
    fi
    executeResult=$?
    if [ $executeResult == "0" ]
    then
        echoGreen "[  OK  ] '$1' 执行成功！"
        
    else
        echoRed "[FAILED]执行失败！脚本退出"
        exit $executeResult
    fi

    # echoYellow "[FAKE SUCCESS]假装执行成功"
}


#规范化输入##########################################

##输入合法性检测#####################################
checkCommandInput()
{
    typeset p_input="$1"
    typeset p_paraArr="$2"
    typeset p_res=1
    typeset p_para=""
    for p_para in ${p_paraArr[*]};do
        if [ "${p_para,,}" = "${p_input,,}" ]
        then
            RESULT_CHECK_COMMAND_INPUT=${p_para,,}
            return 0
        fi
        p_res=$((p_res+1))
    done
    return 1
}

checkMultiSelectInput()
{
    typeset p_inputArr="$1"
    typeset p_paraArr="$2"
    
    typeset p_inputArrList=($p_paraArr)
    typeset p_paraCount="${#p_inputArrList[@]}"

    if [[ -z $p_inputArr ]];
    then
        return 1
    fi
    typeset p_input=""
    for p_input in $p_inputArr;do
        expr $p_input "+" 10 &> /dev/null
        if [ $? -eq 0 ];then
            if [ $p_input -ge $p_paraCount ];
            then
                return 1
            fi
        else
            return 1
        fi
    done
    return 0
}

checkSingleSelectInput()
{
    typeset p_input="$1"
    typeset p_paraArr="$2"

    typeset p_inputArrList=($p_paraArr)
    typeset p_paraCount="${#p_inputArrList[@]}"

    if [[ -z $p_input ]];
    then
        p_input="0"
    fi

    expr $p_input "+" 10 &> /dev/null
    if [ $? -eq 0 ];then
        if [ $p_input -ge $p_paraCount ];
        then
            return 1
        fi
    else
        return 1
    fi

    return 0
}

##输入引导函数#######################################

###输入单一命令######################################
####$1 命令字符串，多命令用空格隔开。例如"Yes no"。建议第一个单词首字母大写，提示用户此为默认值
####$2 输入提示文本。例如"确认提交吗？"
commandInput() 
{
    typeset p_paraArr="$1"
    typeset p_prompt="$2"

    typeset p_paraStr=""
    typeset p_seq=0
    for p_para in ${p_paraArr[@]};do
        if [ $p_seq -eq 0 ];then
            p_paraStr="$p_paraStr | $p_para(默认)"
        else
            p_paraStr="$p_paraStr | $p_para"
        fi
        p_seq=$((p_seq+1))
    done
    p_paraStr=${p_paraStr:2}
    # typeset p_default=${p_paraArr%% *}

    typeset p_result="never_input"
    while [ "$p_result" != "0" ];do
        echoEmptyLine
        if [ "$p_result" != "never_input" ];then
            echoRed "[ERROR]请输入正确的指令！ "
        fi
        if [ "$3" ];then
            echoCyan "$p_prompt"
            typeset p_paraDesc=($3)
            typeset p_seq=0
            for p_para in $p_paraArr;do
                printf "    "
                echoCyanUnderline "$p_para" -n
                printf "  \t--%s\n" "${p_paraDesc[$p_seq]}"
                p_seq=$((p_seq+1))
            done
            echoGreen ">>>[$p_paraStr ]：" -n
        else
            echoGreen ">>>$p_prompt [$p_paraStr ]：" -n
        fi
        
        read -e p_command_input
        if [ ! $p_command_input ];
        then
            p_command_input=${p_paraArr%% *}
        fi
        checkCommandInput "$p_command_input" "$p_paraArr"
        p_result=$?
    done

    GLOBAL_INPUT_RESULT="$RESULT_CHECK_COMMAND_INPUT"
}


###输入多个序号######################################
####$1 选项字符串，多选项用空格隔开。例如"select1 select2"。用户必须要显示选择，不支持默认值
####$2 输入提示文本。例如"请选择远程分支："
multiSelectInput()
{
    typeset p_paraArr="$1"
    typeset p_prompt="$2"

    typeset p_result="never_input"
    while [ "$p_result" != "0" ];do
        echoEmptyLine
        if [ "$p_result" != "never_input" ];then
            echoRed "[ERROR]请输入正确的序号! "
        fi
        echoCyan "$p_prompt"
        typeset p_seq=0
        typeset p_para=""
        for p_para in $p_paraArr;do
            printf "    "
            echoCyanUnderline "$p_seq" -n
            echo ":$p_para"
            p_seq=$((p_seq+1))
        done
        echoGreen ">>>选择多项请使用空格隔开：" -n
        read -e p_multi_select_input
        checkMultiSelectInput "$p_multi_select_input" "$p_paraArr"
        p_result=$?
    done

    typeset p_unique_input=($(awk -v RS=' ' '!a[$1]++' <<< ${p_multi_select_input[@]}))
    p_paraArr=($p_paraArr)
    p_result=""
    typeset p_input=""
    for p_input in ${p_unique_input[@]};do
        # echo "$p_input:${p_paraArr[$input]}"
        p_result="$p_result ${p_paraArr[$p_input]}"
    done
    GLOBAL_INPUT_RESULT="$p_result"
}

###输入一行字符串####################################
####$1 输入提示文本。例如"请输入提交信息："
messageInput()
{
    typeset p_prompt="$1"

    typeset p_result=$GLOBAL_NEVER_INPUT
    while [ "$p_result" != "0" ];do
        echoEmptyLine
        if [ "$p_result" != $GLOBAL_NEVER_INPUT ];then
            echoRed "[ERROR]输入不可以为空，请认真填写！ "
        fi
        echoGreen ">>>$p_prompt" -n
        read -e p_message_input
        if [[ ! "$p_message_input" ]];then
            p_result="1"
        else
            p_result="0"
        fi
    done
    # p_message_input=${p_message_input// /_}
    GLOBAL_INPUT_RESULT="$p_message_input"
}

###输入单个序号####################################
####$1 选项字符串，多选项用空格隔开。例如"select1 select2"。第一个选项为默认值
####$2 输入提示文本。例如"请选择本地分支："
singleSelectInput()
{
    typeset p_paraArr="$1"
    typeset p_prompt="$2"

    typeset p_result=$GLOBAL_NEVER_INPUT
    while [ "$p_result" != "0" ];do
        echoEmptyLine
        if [ "$p_result" != $GLOBAL_NEVER_INPUT ];then
            echoRed "[ERROR]请输入正确的序号！"
        fi
        echoCyan ">>>$p_prompt"
        typeset p_seq=0
        for p_para in $p_paraArr;do
            printf "    "
            echoCyanUnderline "$p_seq" -n
            if [ $p_seq == "0" ];then
                echoNormal ":$p_para 默认"
            else
                echoNormal ":$p_para"
            fi
            p_seq=$((p_seq+1))
        done
        echoGreen ">>>只可以选择一项：" -n
        read -e p_single_select_input
        if [ ! $p_single_select_input ];
        then
            p_single_select_input="0"
        fi
        checkSingleSelectInput "$p_single_select_input" "$p_paraArr"
        p_result=$?
    done

    # echo "$input"
    p_paraArr=($p_paraArr)
    # echo "$input:${paraArr[$input]}"
    GLOBAL_INPUT_RESULT="${p_paraArr[$p_single_select_input]}"
}