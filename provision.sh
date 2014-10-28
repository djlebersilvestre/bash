#!/bin/bash

RETVAL=0
PROV_HOME_DIR=/home/dani

first() {
  if [ "$PROV_FIRST_ROOT_PASS" = true ]; then
    echo "A senha do root já foi configurada"
  else
    exit_code=1
    while [ $exit_code != 0 ]; do
      echo "Por favor, configure a senha do root"
      sudo passwd root
      exit_code=$?
    done

    export PROV_FIRST_ROOT_PASS=true
    echo 'export PROV_FIRST_ROOT_PASS=true' >> $PROV_HOME_DIR/.bash_profile
  fi

  if [ "$PROV_FIRST_UPDATE" = true ]; then
    echo "Os pacotes da distro já foram autalizados"
  else
    echo "Primeira execução. Atualizando todos os pacotes da distro"
    sudo apt-get update
    sudo apt-get --yes --force-yes upgrade

    export PROV_FIRST_UPDATE=true
    echo 'export PROV_FIRST_UPDATE=true' >> $PROV_HOME_DIR/.bash_profile

    echo "Reiniciando para aplicar todas atualizações"
    sudo reboot
  fi
}

git() {
  echo "Atualizando e instalando o git"
  sudo apt-get update
  sudo apt-get --yes --force-yes install git meld gitk

  echo "Configurando o git"
  sudo rm -f /usr/local/bin/git-diff.sh
  echo '#!/bin/bash' >> git-diff.sh
  echo 'meld "$2" "$5" > /dev/null 2>&1' >> git-diff.sh
  sudo mv git-diff.sh /usr/local/bin/
  sudo chmod +x /usr/local/bin/git-diff.sh

  rm -f ~/.gitconfig
  git config --global user.name "Daniel Silvestre"
  git config --global user.email daniel.silvestre@locaweb.com.br
  git config --global color.ui true
  git config --global diff.external /usr/local/bin/git-diff.sh

  echo "Configurando o bash e vimrc"
  git clone https://github.com/djlebersilvestre/vim ~/.vim
  git clone https://github.com/djlebersilvestre/bash ~/.bash
  rm -f ~/.bashrc ~/.bash_profile ~/.profile ~/.vimrc
  ln -s ~/.bash/bashrc ~/.bashrc
  ln -s ~/.bash/bash_profile ~/.bash_profile
  ln -s ~/.vim/vimrc ~/.vimrc
}

grive() {
  if [ -e "/etc/apt/sources.list.d/thefanclub-grive-tools-trusty.list" ]; then
    echo "Repositório para instalação do Grive já existe. Pulando sua inclusão"
  else
    echo "Adicionando repositório para instalação do Grive (Google Drive Client)"
    sudo apt-add-repository ppa:thefanclub/grive-tools
  fi

  sudo apt-get update
  sudo apt-get --yes --force-yes install grive-tools

  echo "Agora configure o Grive (Grive Setup no launcher) e faça o sync completo da nuvem..."
}

gdrive() {
  if [ -e "/etc/apt/sources.list.d/alessandro-strada-ppa-precise.list" ]; then
    echo "Repositório para instalação do Gdrive já existe. Pulando sua inclusão"
  else
    echo "Adicionando repositório para instalação do Gdrive (Google Drive Client)"
    sudo apt-add-repository ppa:alessandro-strada/ppa
  fi

  sudo apt-get update
  sudo apt-get --yes --force-yes install grive-tools

  mkdir -p ~/googledrive
  sudo usermod -a -G fuse daniel
  exec su -l $USER
  echo "Agora configure o Gdrive (google-drive-ocamlfuse) e monte na pasta (google-drive-ocamlfuse ~/gdrive). Para desmontar (fusermount -u ~/gdrive)"
  echo "Mais detalhes tais como automount em http://xmodulo.com/2013/10/mount-google-drive-linux.html"
}

ssh() {
  echo "Copiando chaves ssh e configurando pasta no home (depende do sync do Drive)"
  mkdir -p ~/.ssh
  cp -R ~/gdrive/ssh/* ~/.ssh
  chmod 600 ~/.ssh/vpn/*
  chmod 600 ~/.ssh/*
  chmod 700 ~/.ssh/vpn/
}

packages() {
  if [ -e "/etc/apt/sources.list.d/werner-jaeger-ppa-werner-vpn-trusty.list" ]; then
    echo "Repositório para instalação da VPN já existe. Pulando sua inclusão"
  else
    echo "Adicionando repositório para instalação da VPN"
    sudo apt-add-repository ppa:werner-jaeger/ppa-werner-vpn
  fi

  if [ -e "/etc/apt/sources.list.d/pipelight-stable-precise.list" ]; then
    echo "Repositório para instalação do Netflix Desktop já existe. Pulando sua inclusão"
  else
    echo "Adicionando repositório para instalação do Netflix Desktop"
    sudo apt-add-repository ppa:pipelight/stable
    # Se falhar por causa das fontes, chamar o comando abaixo
    # sudo apt-get --purge --reinstall install ttf-mscorefonts-installer
  fi

  if [ -e "/lib/x86_64-linux-gnu/libudev.so.0" ]; then
    echo "Lib já linkada, pulando fix do popcorn time"
  else
    echo "Aplicando fix do popcorn time"
    sudo ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0
  fi

  echo "Atualizando e instalando todos os pacotes desejados"
  sudo apt-get update
  sudo apt-get --yes --force-yes install vim xbacklight powertop curl screen radiotray filezilla l2tp-ipsec-vpn pdfshuffler planner gimp nfs-kernel-server nfs-common portmap
}

rvm() {
  echo "Instalando o rvm"
  \curl -L https://get.rvm.io | bash -s stable
  rm -f ~/.profile
  source ~/.bash_profile
  type rvm | head -n 1
  rvm install 1.9.2
  rvm use 1.9.2 --default

  echo "Instalando plugins do vim"
  cd  ~/googledrive/vim/
  chmod +x  update_bundles
  ./update_bundles
}

virtualbox() {
  if grep -q "download.virtualbox.org" /etc/apt/sources.list; then
    echo "Repositório do VirtualBox já existe no sources. Pulando sua inclusão"
  else
    echo "Adicionando VirtualBox como sources no apt"
    wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
    sudo bash -c "echo deb http://download.virtualbox.org/virtualbox/debian trusty contrib >> /etc/apt/sources.list"
  fi

  sudo apt-get update
  sudo apt-get --yes --force-yes install virtualbox-4.3

  mkdir ~/vbox
  #mv ~/Área\ de\ Trabalho/debian_7.0.0-amd64-base/ ~/vbox/
  #mv ~/Área\ de\ Trabalho/debian-wheezy-amd64-base.box ~/vbox/

  echo "Agora configure o VirtualBox (baixar e instalar os additionals e importar as VMs base)..."
}

vagrant() {
  echo "Após iniciar o VirtualBox e colocar a VM base nele, executar este para instalar o Vagrant"
  VAGRANT_VERSION=vagrant_1.5.4_x86_64.deb
  wget https://dl.bintray.com/mitchellh/vagrant/$VAGRANT_VERSION
  sudo dpkg -i ~/$VAGRANT_VERSION
  rm ~/$VAGRANT_VERSION
  cd ~/vbox/
  vagrant box add debian-wheezy-amd64-base debian-wheezy-amd64-base.box
}

case "$1" in
  first)
    first
    ;;
  git)
    git
    ;;
  gdrive)
    gdrive
    ;;
  bash)
    bash
    ;;
  ssh)
    ssh
    ;;
  packages)
    packages
    ;;
  rvm)
    rvm
    ;;
  virtualbox)
    virtualbox
    ;;
  vagrant)
    vagrant
    ;;
  setup)
    bash
    ssh
    packages
    git
    rvm
    ;;
  *)
    echo "Usage: $0 {first|git|gdrive|bash|ssh|packages|rvm|virtualbox|vagrant}"
    echo ""
#    echo "Details"
#    echo "  first:     first update on packages"
#    echo "  copy:      copy basic files such as ssh keys and virtual box debian image (used by vagrant). Must have the dirs 'googledrive/ssh' and 'Área de Trabalho/debian...'"
#    echo "  bash:      config bash scripts and vim. Must have finished the Grive sync so the dirs 'googledrive/bash' and 'googledrive/vim' exists"
#    echo "  packages:  install all basic packages such as virtual box, git, vim and so on"
#    echo "  git:       configure git, merger etc"
#    echo "  rvm:       install and set rvm to use ruby"
#    echo "  vagrant:   manually install vagrant. Must have VirtualBox configured with extensions pack and debian base VM. Also, must have the vagrant '.deb' package in your home dir"
#    echo "  setup:     triggers copy|bash|packages|git|rvm"
#    echo ""
    echo "Flow"
    echo "  (1)first > (2)[copy files to desktop, setup Grive and wait for sync] > (3)setup > (4)[configure VirtualBox manually] > (5)vagrant"
    echo "  copy:      copy basic files such as ssh keys and virtual box debian image (used by vagrant). Must have in desktop the dirs 'chave' and 'debian...'"
    echo "  bash:      config bash scripts and vim. Must have finished the Grive sync so the dirs 'googledrive/bash' and 'googledrive/vim' exists"
    echo "  packages:  install all basic packages such as virtual box, git, vim and so on"
    echo "  git:       configure git, merger etc"
    echo "  rvm:       install and set rvm to use ruby"
    echo "  vagrant:   manually install vagrant. Must have VirtualBox configured with extensions pack and debian base VM. Also, must have the vagrant '.deb' package in desktop"
    echo ""
    RETVAL=1
esac

exit $RETVAL

