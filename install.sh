#!/bin/bash

### By Andrii Kondratiev ###

# Colors
end="\033[0m"
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"


function info {
    echo -e "${green}— ${1}${end}"
}

function error {
    echo -e "${red}=== ${1} === ${end}"
}

function warn {
    echo -e "${yellow}=== ${1} === ${end}"
}

function create_dir {
		[ ! -d $1 ] && mkdir -p $1
}

function CheckOS () {
  OS="`uname`"
  case $OS in
    'Linux')
        OS='Linux'
        ;;
	  
    'FreeBSD')
        OS='FreeBSD' ;;

    'Darwin') 
        OS='macOS' ;;
  	
    *)
        error "Unknown operation system. Exiting..."
        exit 3
		;;
	esac
  info "$OS was found"
}


function GetDistro () {
  
  if command -v apt-get >/dev/null; then
    info "Debian-based OS found"
    Distro="deb"
  elif command -v yum >/dev/null; then
    info "RedHat-based OS found"
    Distro="rpm"
  else
    error "Not possible to understand Linux package manager type..."
  fi
}


function InstallFansy () {
  info "Installing Diff So Fansy on $OS..."
  if [[ $OS = "Linux" ]]; then
    InstallDir="$HOME/bin/diffsofancy"
    create_dir "$HOME/bin" || error "Cannot create folder because it exists." 
    # add ~/bin to your PATH (.bashrc or .zshrc)
    if [ ! -d "$InstallDir/.git" ]; then
        info "Previous installation not found. Creating new one..."
        git clone https://github.com/so-fancy/diff-so-fancy $InstallDir
        chmod +x $InstallDir/diff-so-fancy
    else
        info "Found previous installation. Trying to pull new version..."
        git -C $InstallDir pull && info "Success!" || error "Error happened!"
    fi
    ln -sf $InstallDir/diff-so-fancy $HOME/bin/diff-so-fancy
  elif [[ $OS = "macOS" ]]; then
    brew update
    brew install diff-so-fancy
  else
    warn "$OS is not supported yet"
  fi

  info "Enabling Diff So Fancy in git config..."
  git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  git config --global interactive.diffFilter "diff-so-fancy --patch"
}

function InstallDelta () {
  if [[ $OS = "Linux" ]]; then
    case $Distro in
      'deb')
	tmp_file="/tmp/delta.deb"
        url=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep browser_download_url | grep '64[.]deb' | head -n 1 | cut -d '"' -f 4)
	wget -q --show-progress -O $tmp_file $url && sudo dpkg -i $tmp_file && rm -v $tmp_file
	;;
      'rpm')
    	sudo yum install delta
	;;
    esac
  elif [[ $OS = "macOS" ]]; then
    brew install git-delta
  else
    warn "Distro not found. Delta will not be installed."
  fi
  
}

function GeneralConfig () {
  git config --global diff.tool vimdiff

}

CheckOS
GetDistro
InstallFansy
InstallDelta
