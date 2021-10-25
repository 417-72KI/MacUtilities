#!/bin/sh

set -eo pipefail

# .zprofileを作成
if [ ! -f ~/.zprofile ]; then
    read -p "Input your GitHub token: " github_token
    if [ "$github_token" == "" ]; then 
        echo 'abort.'
        exit 1
    fi
    cat ./zprofile_template | sed -e "s/{insert your GitHub Token}/$github_token/g" > ~/.zprofile

fi

# ネットワークドライブで.DS_Storeを作成しないようにする
defaults write com.apple.desktopservices DSDontWriteNetworkStores True

# 隠しファイルを表示するようにする
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# Xcodeでビルド時間を表示する
defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

# Homebrewインストール
if which brew > /dev/null; then
    echo 'Homebrew already exists'
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$(uname -m)" = "arm64" ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# rbenvインストール
if which rbenv > /dev/null; then
    echo 'rbenv already exists'
else
    brew install rbenv rbenv-communal-gems
fi

# Rubyを最新版に
RUBY_LATEST_VERSION=$(rbenv install -l | grep -v - | tail -1)
rbenv install $RUBY_LATEST_VERSION 
rbenv global $RUBY_LATEST_VERSION

# Node.jsインストール
if which nodebrew > /dev/null; then
    echo 'nodebrew already exists'
else
    brew install nodebrew
    mkdir -p ~/.nodebrew/src
    nodebrew install-binary latest
fi

# ssh公開鍵作成
if [[ ! -e ~/.ssh/id_rsa ]]; then
    ssh-keygen
fi

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

# ghq & pecoインストール
if which ghq > /dev/null; then
    echo 'ghq already installed'
else
    brew install ghq
fi
if which peco > /dev/null; then
    echo 'peco already installed'
else
    brew install peco
fi

# .zshrc作成
if [ ! -f ~/.zshrc ]; then
    cat ./zshrc_template > ~/.zshrc
fi
