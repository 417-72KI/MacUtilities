#!/bin/sh

# .bash_profileを作成
if [ ! -f ~/.bash_profile ]; then
    cat << EOS > ~/.bash_profile
    if [ -f ~/.bashrc ]; then
    . ~/.bashrc
    fi
EOS
fi

# エイリアスを登録する
cat << EOS > ~/.bashrc
alias ls='ls -G'
alias ll='ls -la'
EOS

# 隠しファイルを表示するようにする
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# Homebrewインストール
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Node.jsインストール
brew install nodebrew
mkdir -p ~/.nodebrew/src
nodebrew install-binary latest
echo 'export PATH=$PATH:~/.nodebrew/current/bin' >> ~/.bashrc

# ssh公開鍵作成
ssh-keygen

# .ssh/config作成
cat << EOS > ~/.ssh/config
Host github.com
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_rsa

Host *
    UseKeychain yes
EOS
