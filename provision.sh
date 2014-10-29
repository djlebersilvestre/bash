#!/bin/bash

RETVAL=0

is_gdrive_working() {
  if [ ! -d "~/gdrive" ] || [ ! -d "~/gdrive/ssh" ] || [ ! -d "~/gdrive/ssh/vpn" ]; then
    return 1
  else
    return 0
  fi
}

check_gdrive() {
  if ! is_gdrive_working; then
    echo "O Gdrive não está configurado ou inicializado. Abortando o processo"
    exit 1
  fi
}

update_pkgs() {
  force_update=$1

  if [ "$force_update" = true ] || [ "$PROV_APT_UPDATED" != true ]; then
    echo "Atualizando lista de pacotes"
    sudo apt-get update
    export PROV_APT_UPDATED=true
  fi
}

install_pkgs() {
  pkgs=$1

  if [ -z "$pkgs" ]; then
    echo "É necessário passar os pacotes separados por espaço como argumento"
    exit 1
  fi

  update_pkgs

  echo "Instalando pacotes $pkgs"
  sudo apt-get --yes --force-yes install $pkgs
}

first_step_done() {
  if [ "$PROV_FIRST_ROOT_PASS" != true ] && [ "$PROV_FIRST_UPDATE" = true ]; then
    echo 'first_step_done...true'
    return 0
  else
    echo 'first_step_done...false'
    return 1
  fi
}

first_step() {
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
    echo 'export PROV_FIRST_ROOT_PASS=true' >> ~/.bash_profile
  fi

  if [ "$PROV_FIRST_UPDATE" = true ]; then
    echo "Os pacotes da distro já foram autalizados"
  else
    echo "Primeira execução. Atualizando todos os pacotes da distro"
    sudo apt-get update
    sudo apt-get --yes --force-yes upgrade

    export PROV_FIRST_UPDATE=true
    echo 'export PROV_FIRST_UPDATE=true' >> ~/.bash_profile

    echo "Reiniciando para aplicar todas atualizações"
    sudo reboot
  fi
}

git_step_done() {
  if false; then
    echo 'git_step_done...true'
    return 0
  else
    echo 'git_step_done...false'
    return 1
  fi
}

git_step() {
  echo "Atualizando e instalando o git"
  install_pkgs 'git meld gitk'

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

# grive() {
#   if [ -e "/etc/apt/sources.list.d/thefanclub-grive-tools-trusty.list" ]; then
#     echo "Repositório para instalação do Grive já existe. Pulando sua inclusão"
#   else
#     echo "Adicionando repositório para instalação do Grive (Google Drive Client)"
#     sudo apt-add-repository ppa:thefanclub/grive-tools
#   fi
# 
#   sudo apt-get update
#   sudo apt-get --yes --force-yes install grive-tools
# 
#   echo "Agora configure o Grive (Grive Setup no launcher) e faça o sync completo da nuvem..."
# }

gdrive_step_done() {
  if false; then
    echo 'gdrive_step_done...true'
    return 0
  else
    echo 'gdrive_step_done...false'
    return 1
  fi
}

gdrive_step() {
  if [ -e "/etc/apt/sources.list.d/alessandro-strada-ppa-trusty.list" ] || [ -d "~/gdrive" ]; then
    echo "Repositório para instalação do Gdrive já existe. Pulando sua inclusão"
  else
    echo "Adicionando repositório para instalação do Gdrive (google-drive-ocamlfuse)"
    sudo apt-add-repository ppa:alessandro-strada/ppa
  fi

  install_pkgs 'google-drive-ocamlfuse'

  mkdir -p ~/gdrive
  sudo usermod -a -G fuse $USER
  echo "Agora configure o Gdrive (google-drive-ocamlfuse) e monte na pasta (google-drive-ocamlfuse ~/gdrive). Para desmontar (fusermount -u ~/gdrive)"
  echo "Mais detalhes tais como automount em http://xmodulo.com/2013/10/mount-google-drive-linux.html"
  exec su -l $USER
}

ssh_step_done() {
  if false; then
    echo 'ssh_step_done...true'
    return 0
  else
    echo 'ssh_step_done...false'
    return 1
  fi
}

ssh_step() {
  check_gdrive

  echo "Copiando chaves ssh e configurando pasta no home"
  mkdir -p ~/.ssh
  cp -R ~/gdrive/ssh/* ~/.ssh
  chmod 600 ~/.ssh/vpn/*
  chmod 600 ~/.ssh/*
  chmod 700 ~/.ssh/vpn/
}

packages_step_done() {
  if false; then
    echo 'packages_step_done...true'
    return 0
  else
    echo 'packages_step_done...false'
    return 1
  fi
}

packages_step() {
  #TODO: find alternatives to locaweb VPN
  # if [ -e "/etc/apt/sources.list.d/werner-jaeger-ppa-werner-vpn-trusty.list" ]; then
    # echo "Repositório para instalação da VPN já existe. Pulando sua inclusão"
  # else
    # echo "Adicionando repositório para instalação da VPN"
    # sudo apt-add-repository ppa:werner-jaeger/ppa-werner-vpn
    # update_pkgs true
  # fi

  should_update_pkgs=false
  if [ -e "/etc/apt/sources.list.d/pipelight-stable-trusty.list" ]; then
    echo "Repositório para instalação do Netflix Desktop já existe. Pulando sua inclusão"
  else
    echo "Adicionando repositório para instalação do Netflix Desktop"
    sudo apt-add-repository ppa:pipelight/stable
    should_update_pkgs=true

    # sudo apt-get --purge --reinstall install ttf-mscorefonts-installer
  fi

  if [ -e "/etc/apt/sources.list.d/google.list" ]; then
    echo "Repositório para instalação do Google Chrome já existe. Pulando sua inclusão"
  else
    echo "Adicionando repositório para instalação do Google Chrome"
    wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O- | sudo apt-key add -
    sudo bash -c "echo deb http://dl.google.com/linux/chrome/deb/ stable main >> /etc/apt/sources.list.d/google.list"
    should_update_pkgs=true
  fi

  if [ -e "/lib/x86_64-linux-gnu/libudev.so.0" ]; then
    echo "Lib já linkada, pulando fix do popcorn time"
  else
    echo "Aplicando fix do popcorn time"
    sudo ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0
  fi

  if should_update_pkgs; then
    update_pkgs true
  fi

  echo "Atualizando e instalando todos os pacotes desejados"
  install_pkgs 'vim apache2-utils xbacklight powertop curl screen radiotray filezilla pdfshuffler gimp nfs-kernel-server nfs-common google-chrome-stable netflix-desktop'
  # install_pkgs 'l2tp-ipsec-vpn'

  # Dependencias para o Netflix Desktop
  sudo apt-get --purge --reinstall --yes --force-yes install ttf-mscorefonts-installer

  echo "Não esqueça de:"
  echo " - Setar em aplicativos de sessão o brilho do monitor (xbacklight -set 70)"
  echo " - Rodar a primeira vez o Netflix Desktop para configurá-lo"
  echo " - Adicionar apps no launcher: Chrome, Netflix"
}

rvm_step_done() {
  if false; then
    echo 'rvm_step_done...true'
    return 0
  else
    echo 'rvm_step_done...false'
    return 1
  fi
}

rvm_step() {
  echo "Instalando o rvm"
  \curl -L https://get.rvm.io | bash -s stable
  rm -f ~/.profile
  source ~/.bash_profile
  type rvm | head -n 1
  rvm install 1.9.2
  rvm install 1.9.3
  rvm install 2.1.2
  rvm install 2.1.4
  rvm use 2.1.2 --default

  echo "Instalando plugins do vim"
  cd  ~/googledrive/vim/
  chmod +x  update_bundles
  ./update_bundles
}

virtualbox_step_done() {
  if false; then
    echo 'virtualbox_step_done...true'
    return 0
  else
    echo 'virtualbox_step_done...false'
    return 1
  fi
}

virtualbox_step() {
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

vagrant_step_done() {
  if false; then
    echo 'vagrant_step_done...true'
    return 0
  else
    echo 'vagrant_step_done...false'
    return 1
  fi
}

vagrant_step() {
  echo "Após iniciar o VirtualBox e colocar a VM base nele, executar este para instalar o Vagrant"
  VAGRANT_VERSION=vagrant_1.6.5_x86_64.deb
  wget https://dl.bintray.com/mitchellh/vagrant/$VAGRANT_VERSION
  sudo dpkg -i ~/$VAGRANT_VERSION
  rm ~/$VAGRANT_VERSION
  cd ~/vbox/
  vagrant box add debian-wheezy-amd64-base debian-wheezy-amd64-base.box
}

check_flow() {
  echo "Missing implementation but I wish to list the status of the installation flow and point to what is missing"
  #TODO: each step must have a standard check with boolean response to say if the step is done or not
  first_step_done
}

case "$1" in
  first)
    first_step
    ;;
  packages)
    packages_step
    ;;
  gdrive)
    gdrive_step
    ;;
  ssh)
    ssh_step
    ;;
  git)
    git_step
    ;;
  rvm)
    rvm_step
    ;;
  virtualbox)
    virtualbox_step
    ;;
  vagrant)
    vagrant_step
    ;;
  check_flow)
    check_flow
    ;;
  setup)
    first_step
    packages_step
    ssh_step
    git_step
    rvm_step
    ;;
  *)
    echo "Usage: $0 {first|packages|gdrive|ssh|git|rvm|virtualbox|vagrant}"
    echo ""
#    echo "Details"
#    echo "  first:     first update on packages"
#    echo "  copy:      copy basic files such as ssh keys and virtual box debian image (used by vagrant). Must have the dirs 'googledrive/ssh' and 'Área de Trabalho/debian...'"
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

