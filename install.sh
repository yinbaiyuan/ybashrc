#!/bin/bash

SOURCE_PATH=$HOME/ybashrc
CURRENT_PATH=$PWD

bashString="\n\
#Add By ybashrc install program \n\
if [ -f \\\"$SOURCE_PATH/.ybashrc\\\" ]; then\n\
    . \\\"$SOURCE_PATH/.ybashrc\\\"\n\
fi\n"

if [ ! -d "$SOURCE_PATH" ]; then
    ln -sf $CURRENT_PATH $SOURCE_PATH
fi

existDetect=$(grep "#Add By ybashrc install program" $HOME/.bashrc)
if [ -z "$existDetect" ]; then
    sh -c "echo \"$bashString\" >> $HOME/.bashrc"
    echo "[   OK   ] $HOME/.bashrc target information added"
else
    echo "[Warning] $HOME/.bashrc target information exist"
fi

sudo rm -rf /root/ybashrc
sudo ln -sf $CURRENT_PATH /root/ybashrc

rootBashString="\n\
#Add By ybashrc install program \n\
if [ -f \\\"/root/ybashrc/.ybashrc\\\" ]; then\n\
    . \\\"/root/ybashrc/.ybashrc\\\"\n\
fi\n"

existDetect=$(sudo grep "#Add By ybashrc install program" /root/.bashrc)
if [ -z "$existDetect" ]; then
    sudo sh -c "echo \"$rootBashString\" >> /root/.bashrc"
    echo "[   OK   ] /root/.bashrc target information added"
else
    echo "[Warning] /root/.bashrc target information exist"
fi