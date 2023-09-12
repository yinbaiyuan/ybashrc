#!/bin/bash

. $HOME/ybashrc/command-common.sh

gitFetchAction()
{
    echoEmptyLine
    cmdExecute "git fetch --all"
    
    echoEmptyLine
    echoCyan "所有远程分支如下"
    echoCyan "-----------------------------------------------------------------------"
    git show-branch -r
    echoCyan "======================================================================="
    
}

gitFetchAction $@


