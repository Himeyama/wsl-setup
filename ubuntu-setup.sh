#!/usr/bin/env bash

# 対話なし
export DEBIAN_FRONTEND=noninteractive
pyenv_version=3.10.4

# apt のデータ取得元を理研に変更
sudo sed -i.bak "s%http://[^ ]\+%http://ftp.riken.go.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

# 日本語パッケージの追加
wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -
distrib_codename=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | sed "s/.*=//")
sudo wget https://www.ubuntulinux.jp/sources.list.d/$distrib_codename.list -O /etc/apt/sources.list.d/ubuntu-ja.list
sudo apt update
sudo apt install -y ubuntu-defaults-ja

# man ページを日本語に
sudo apt install -y language-pack-ja manpages-ja
echo "export LANG=ja_JP.UTF8" | tee -a $HOME/.bashrc
. $HOME/.bashrc

# 言語の変更
sudo sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
locale-gen --keep-existing

# rbenv
# https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
sudo apt install -y \
    autoconf \
    bison \
    build-essential \
    libssl-dev \
    libyaml-dev \
    libreadline6-dev \
    zlib1g-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm6 \
    libgdbm-dev \
    libdb-dev
if test ! -d "$HOME/.rbenv"; then
    wget -q https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer -O- | bash
    rbenv_bashrc=$(cat $HOME/.bashrc | grep rbenv)
    if [[ -z $rbenv_bashrc ]]; then
        echo -e "\n# rbenv" | tee -a $HOME/.bashrc
        echo export PATH=\$PATH:\$HOME/.rbenv/bin | tee -a $HOME/.bashrc
        echo 'eval "$(rbenv init -)"' | tee -a $HOME/.bashrc
    fi
    . $HOME/.bashrc
    ruby_version=$(rbenv install -l 2>/dev/null | grep "^[0-9]" | tail -n 1)
    RUBY_CONFIGURE_OPTS="--enable-shared" MAKE_OPTS="-j" rbenv install $ruby_version -v
    rbenv global $ruby_version
fi


# pyenv
# https://github.com/pyenv/pyenv/wiki
sudo apt install -y make \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev

if test ! -d "$HOME/.pyenv"; then
    wget -q https://pyenv.run -O- | bash
    pyenv_bashrc=$(cat $HOME/.bashrc | grep pyenv)
    if [[ -z $pyenv_bashrc ]]; then
        echo -e "\n# pyenv" | tee -a $HOME/.bashrc
        echo export PATH=\$PATH:\$HOME/.pyenv/bin | tee -a $HOME/.bashrc
        echo 'eval "$(pyenv init --path)"' | tee -a $HOME/.bashrc
        echo 'eval "$(pyenv virtualenv-init -)"' | tee -a $HOME/.bashrc
    fi
    . $HOME/.bashrc
    PYTHON_CONFIGURE_OPTS="--enable-shared" MAKE_OPTS="-j" pyenv install $pyenv_version -v
    pyenv global $pyenv_version
fi


# cargo & rust
wget -q https://sh.rustup.rs -O- | sh -s -- -y
source $HOME/.bashrc

# 追加パッケージ
sudo apt install -y nmap neofetch htop openssh-server git whois gcc

sudo apt upgrade -y
sudo apt autoremove -y

mkdir -p $HOME/.ssh
if test ! -f $HOME/.ssh/id_ed25519; then
    ssh-keygen -f $HOME/.ssh/id_ed25519 -t ed25519 -N ""
    cat $HOME/.ssh/id_ed25519.pub
fi
