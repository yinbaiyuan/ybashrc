#!/bin/bash

main()
{
    . $HOME/ybashrc/git-detect.sh $@
    if [ $? != "0" ]; then return; fi
    if [ -f "ybc-git-gc-pre.sh" ];then
        . $PWD/ybc-git-gc-pre.sh $@
        if [ $? != "0" ]; then return; fi
    fi
    . $HOME/ybashrc/git-add.sh $@
    if [ $? != "0" ]; then return; fi
    . $HOME/ybashrc/git-commit.sh $@
    if [ $? != "0" ]; then return; fi
    . $HOME/ybashrc/git-push.sh $@
    if [ $? != "0" ]; then return; fi
    if [ -f "ybc-git-gc-post.sh" ];then
        . $PWD/ybc-git-gc-post.sh $@
        if [ $? != "0" ]; then return; fi
    fi
}

main $@


