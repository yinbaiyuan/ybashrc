#!/bin/bash

main()
{
    . $HOME/ybashrc/git-detect.sh $@
    if [ $? != "0" ]; then return; fi
    if [ -f "git-gf-pre.sh" ];then
        . $PWD/git-gf-pre.sh $@
        if [ $? != "0" ]; then return; fi
    fi
    . $HOME/ybashrc/git-restore.sh $@
    if [ $? != "0" ]; then return; fi
    . $HOME/ybashrc/git-clean.sh $@
    if [ $? != "0" ]; then return; fi
    . $HOME/ybashrc/git-fetch.sh $@
    if [ $? != "0" ]; then return; fi
    . $HOME/ybashrc/git-merge.sh $@
    if [ $? != "0" ]; then return; fi
    if [ -f "git-gf-post.sh" ];then
        . $PWD/git-gf-post.sh $@
        if [ $? != "0" ]; then return; fi
    fi
}

main $@


