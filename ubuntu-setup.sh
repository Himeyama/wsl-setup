#!/usr/bin/env bash

python_version=3.9.12

# 対話なし
export DEBIAN_FRONTEND=noninteractive
export LANG=ja_JP.UTF8

# apt のデータ取得元を理研に変更
sudo sed -i.bak "s%http://[^ ]\+%http://ftp.riken.go.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

# 日本語パッケージの追加
wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -
distrib_codename=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | sed "s/.*=//")
wget -q https://www.ubuntulinux.jp/sources.list.d/${distrib_codename}.list -O- | sudo tee /etc/apt/sources.list.d/ubuntu-ja.list
sudo http_proxy=$http_proxy apt update
sudo http_proxy=$http_proxy apt install -y ubuntu-defaults-ja

# man ページを日本語に
sudo http_proxy=$http_proxy apt install -y language-pack-ja manpages-ja

if [[ -z $(cat $HOME/.bashrc | grep LANG=ja_JP) ]]; then
    echo "export LANG=ja_JP.UTF8" | tee -a $HOME/.bashrc
fi

# 言語の変更
sudo sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
locale-gen --keep-existing

# rbenv
# https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
sudo http_proxy=$http_proxy apt install -y \
    autoconf \
    bison \
    build-essential \
    libssl-dev \
    libyaml-dev \
    libreadline-dev \
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
        echo export PATH=\$HOME/.rbenv/bin:\$PATH | tee -a $HOME/.bashrc
        echo 'eval "$(rbenv init -)"' | tee -a $HOME/.bashrc
    fi
    ruby_version=$(rbenv install -l 2>/dev/null | grep "^[0-9]" | tail -n 1)
    RUBY_CONFIGURE_OPTS="--enable-shared" MAKE_OPTS="-j" $HOME/.rbenv/bin/rbenv install $ruby_version -v
    $HOME/.rbenv/bin/rbenv global $ruby_version
fi


# pyenv
# https://github.com/pyenv/pyenv/wiki
sudo http_proxy=$http_proxy apt install -y make \
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
        echo export PATH=\$HOME/.pyenv/bin:\$PATH | tee -a $HOME/.bashrc
        echo 'eval "$(pyenv init --path)"' | tee -a $HOME/.bashrc
        echo 'eval "$(pyenv virtualenv-init -)"' | tee -a $HOME/.bashrc
    fi
    PYTHON_CONFIGURE_OPTS="--enable-shared" MAKE_OPTS="-j" $HOME/.pyenv/bin/pyenv install $python_version -v
    $HOME/.pyenv/bin/pyenv global $python_version
fi
python -m pip install -U pip setuptools poetry ipykernel

# cargo & rust
curl -m 10 --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 追加パッケージ
sudo http_proxy=$http_proxy apt install -y nmap neofetch htop openssh-server git whois gcc

sudo http_proxy=$http_proxy apt upgrade -y
sudo http_proxy=$http_proxy apt autoremove -y

mkdir -p $HOME/.ssh
if test ! -f $HOME/.ssh/id_ed25519; then
    ssh-keygen -f $HOME/.ssh/id_ed25519 -t ed25519 -N ""
    cat $HOME/.ssh/id_ed25519.pub
fi

sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

echo -e "[network]\ngenerateResolvConf = false" | sudo tee /etc/wsl.conf
echo nameserver 1.1.1.1 | sudo tee /etc/resolv.conf
