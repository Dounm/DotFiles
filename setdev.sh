#!/bin/bash

set -x
set -e

INSTALL_PATH="${HOME}/install"
CURRENT_PATH=`pwd`
if ! [ -d $INSTALL_PATH ]
then
    mkdir ${INSTALL_PATH}
fi
PACKAGE_CMD=$1

#Install tmux
echo Y > tmp.file
if ! type 'tmux' > /dev/null
then
  cat ~/.passwd | sudo -S ${PACKAGE_CMD} install tmux < tmp.file
fi

##Install zsh and oh-my-zsh and zsh-plugins
if ! type 'zsh' > /dev/null
then
  cat ~/.passwd | sudo -S ${PACKAGE_CMD} install zsh < tmp.file
  cat ~/.passwd | sudo -S chsh -s /bin/zsh
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

if ! [ -d $HOME/.autojump ]
then
  git clone git://github.com/joelthelion/autojump.git ${INSTALL_PATH}/autojump
  cd ${INSTALL_PATH}/autojump && ./install.py
  cd ${CURRENT_PATH}
fi

rm tmp.file

#Install ctags
if ! type 'ctags' > /dev/null
then
  wget http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz -O ctags-5.8.tar.gz
  tar -xzvf ctags-5.8.tar.gz -C $INSTALL_PATH
  cd ${INSTALL_PATH}/ctags-5.8
  cat ~/.passwd | sudo -S ./configure 
  cat ~/.passwd | sudo -S make 
  cat ~/.passwd | sudo -S make install
  cd ${CURRENT_PATH}
  rm ctags-5.8.tar.gz
fi

#Set the dotfiles

backup_date=`date +%F`
TryBackupExistedDotFiles() {
  if [ -f $1 ]
  then
    mv $1 $1-${backup_date}
  fi
}


absolute_path=`pwd`/dotfiles

TryBackupExistedDotFiles ~/.vimrc
TryBackupExistedDotFiles ~/.zshrc
TryBackupExistedDotFiles ~/.tmux.conf
TryBackupExistedDotFiles ~/.octaverc.conf
TryBackupExistedDotFiles ~/.mytmuxlayout
TryBackupExistedDotFiles ~/.octaverc


ln -s ${absolute_path}/.zshrc ~/.zshrc
ln -s ${absolute_path}/.tmux.conf ~/.tmux.conf
ln -s ${absolute_path}/.mytmuxlayout ~/.mytmuxlayout
ln -s ${absolute_path}/.octaverc ~/.octaverc
ln -s ${absolute_path}/.vimrc ~/.vimrc
ln -s `pwd`/recycle.py ~/.recycle.py

echo > ~/.specific_zshrc

#Generate SSH key
if ! [ -d ~/.ssh ]
then
  ssh-keygen
fi

#Config ~/.gitconfig
set +e
grep '\[color\]' $HOME/.gitconfig
grep_res=$?
set -e
if [ $grep_res != 0 ]
then
  echo -e "[color]\n  diff = auto\n  status = auto\n  branch = auto\n  interactive = auto\n  ui = true\n  pager = true" >> ~/.gitconfig
fi
