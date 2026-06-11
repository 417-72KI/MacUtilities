#!/bin/zsh

set -eo pipefail

# ネットワークドライブで.DS_Storeを作成しないようにする
if [ "$(defaults read com.apple.desktopservices DSDontWriteNetworkStores)" != 1 ]; then
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool YES
fi

# Xcode13.2~でビルドを高速化する
if [ "$(defaults read com.apple.dt.XCBuild EnableSwiftBuildSystemIntegration)" != 1 ]; then
    defaults write com.apple.dt.XCBuild EnableSwiftBuildSystemIntegration -bool YES
fi

# 隠しファイルを表示するようにする
if [ "$(defaults read com.apple.finder AppleShowAllFiles)" != 1 ]; then
    defaults write com.apple.finder AppleShowAllFiles -bool YES
    echo 'Reboot Finder...'
    killall Finder
fi

# Xcodeでビルド時間を表示する
if [ "$(defaults read com.apple.dt.Xcode ShowBuildOperationDuration)" != 1 ]; then
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
fi

# Homebrewインストール
if which brew > /dev/null; then
    echo '\033[33mHomebrew already exists\033[m'
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# rbenvインストール
if which rbenv > /dev/null; then
    echo '\033[33mrbenv already exists\033[m'
else
    brew install rbenv rbenv-communal-gems
fi

# Rubyを最新版に
RUBY_LATEST_VERSION=$(rbenv install -l | grep -v - | tail -1)
if [ "$(rbenv versions | grep "$RUBY_LATEST_VERSION")" == '' ]; then
    rbenv install $RUBY_LATEST_VERSION
    rbenv global $RUBY_LATEST_VERSION
    rbenv rehash
fi

# Node.jsインストール
if which nodebrew > /dev/null; then
    echo '\033[33mnodebrew already exists\033[m'
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
if [ -f ~/.ssh/config ]; then
    echo '\033[33m~/.ssh/config already exists\033[m'
else
    cat << EOS > ~/.ssh/config
Host github.com
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_rsa

Host *
    UseKeychain yes
EOS
fi

# jqインストール
if which jq > /dev/null; then
    echo '\033[33mjq already installed\033[m'
else
    brew install jq
fi

# ghインストール
if which gh > /dev/null; then
    echo '\033[33mgh already installed\033[m'
else
    brew install gh
fi

# ghq & pecoインストール
if which ghq > /dev/null; then
    echo '\033[33mghq already installed\033[m'
else
    brew install ghq
fi
if which peco > /dev/null; then
    echo '\033[33mpeco already installed\033[m'
else
    brew install peco
fi

# .zprofileを作成
if [ -f ~/.zprofile ]; then
    if [[ ! -L ~/.zprofile ]]; then
        mv ~/.zprofile ~/.zprofile.bak
    else 
        rm ~/.zprofile
    fi
fi
ln -s $(pwd)/src/.zprofile ~/.zprofile

# .zshrc作成
if [ -f ~/.zshrc ]; then
    if [[ ! -L ~/.zshrc ]]; then
        mv ~/.zshrc ~/.zshrc.bak
    else 
        rm ~/.zshrc
    fi
fi
ln -s $(pwd)/src/.zshrc ~/.zshrc

exec /bin/zsh -l
