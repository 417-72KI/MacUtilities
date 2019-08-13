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
alias relogin='exec $SHELL -l'
alias merged_branch='git branch --merged | grep -vE '\''^\*|master$'\'''
alias rmmerged_branch='merged_branch | xargs -I % git branch -d %'
alias rmderived='rm -rf ~/Library/Developer/Xcode/DerivedData/*'
alias gb='git branch'
alias gba='git branch -a'
alias grc='git rebase --continue'
alias gf='git fetch -p'
alias gp='git pull --rebase -p'
EOS

# ネットワークドライブで.DS_Storeを作成しないようにする
defaults write com.apple.desktopservices DSDontWriteNetworkStores True

# 隠しファイルを表示するようにする
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# Xcodeでビルド時間を表示する
defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

# Homebrewインストール
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# rbenvインストール
brew install rbenv rbenv-communal-gems

cat << EOS >> ~/.bashrc
if which rbenv > /dev/null; then eval "\$(rbenv init -)"; fi
export PATH="\$HOME/.rbenv/bin:\$PATH"
eval "\$(rbenv init -)"
EOS

relogin

# Rubyを最新版に
RUBY_LATEST_VERSION = $(rbenv install -l | grep -v - | tail -1)
rbenv install $RUBY_LATEST_VERSION 
rbenv global $RUBY_LATEST_VERSION

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

# ghq & pecoインストール
brew install ghq
brew install peco

# ghq & peco向けエイリアス
cat << EOS >> ~/.bashrc
alias gout='git checkout \$(gba | grep -v "HEAD" | peco | tr -d '"'"' '"'"' | tr -d '"'"'*'"'"')'
alias glook='ghq look \$(ghq list | peco)'
alias grb='SKIP_POST_CHECKOUT=1 git rebase \$(gba | grep -v "HEAD" | peco | tr -d '"'"' '"'"' | tr -d '"'"'*'"'"')'
alias grm='SKIP_POST_CHECKOUT=1 gf && git rebase origin/master'
EOS
