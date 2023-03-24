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
      OS='FreeBSD'
      ;;
    'Darwin') 
      OS='macOS'
      ;;	
    *)
      error "Unknown operation system. Exiting..."
      exit 3
      ;;
  esac
  info "$OS was found"
}


function GetDistro () {
  CheckOS
  if [[ $OS = "Linux" ]]; then
    if command -v apt-get >/dev/null; then
      info "Debian-based OS found"
      Distro="deb"
    elif command -v yum >/dev/null; then
      info "RedHat-based OS found"
      Distro="rpm"
    else
      error "Not possible to understand Linux package manager type..."
    fi
  fi
}


function InstallFansy () {
  CheckOS
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
    command -v brew >/dev/null && brew install diff-so-fancy || error "No Homebrew found. Install it first"
  else
    warn "$OS is not supported yet"
  fi

  info "Enabling Diff So Fancy in git config..."
  git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  git config --global interactive.diffFilter "diff-so-fancy --patch"
}

function InstallDelta () {
  GetDistro
  if [[ $OS = "Linux" ]]; then
    case $Distro in
      'deb')
	tmp_file="/tmp/delta.deb"
        url=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | \
		          grep browser_download_url | \
		          grep '64[.]deb' | \
		          head -n 1 | \
		          cut -d '"' -f 4)
	wget -q --show-progress -O $tmp_file $url && \
		          sudo dpkg -i $tmp_file && \
		          rm -v $tmp_file
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
  #### Core config ####
  git config --global core.pager delta
  git config --global core.editor "vim"
  git config --global core.compression 9
  git config --global core.excludesfile "~/.gitignore_global"
  git config --global core.filemode false
}

function Aliases () {
  git config --global alias.cm "commit -m"
  git config --global alias.b "branch"
  git config --global alias.cl "clone"
  git config --global alias.cld "clone --depth 1"
  git config --global alias.d "diff"
  git config --global alias.g "grep -p"
  git config --global alias.l "log --oneline"
  git config --global alias.lg "log --oneline --graph --decorate"
  git config --global alias.g "!git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
  git config --global alias.details "log -n1 -p --format=fuller"
  git config --global alias.unstage "reset HEAD --"
  git config --global alias.ps "push"
  git config --global alias.psf "push -f"
  git config --global alias.psu "push -u"
  git config --global alias.pst "push --tags"
  git config --global alias.psom "push origin master"
  git config --global alias.r "!git ls-files -z --deleted | xargs -0 git rm"
  git config --global alias.root "rev-parse --show-toplevel"
  git config --global alias.pl "pull"
  git config --global alias.in "pull --dry-run"
  git config --global alias.pb "pull --rebase"
  git config --global alias.s "status"
  git config --global alias.sb "status -s -b"
  git config --global alias.st "!git stash list | wc -l 2>/dev/null | grep -oEi '[0-9][0-9]*'"
}

function Other () {
  #### Credentinals config ####
  git config --global credential.helper osxkeychain
  git config --global credential.https://github.com.username keedhost

  #### Replace proto to URL ####
  git config --global url.https://github.com.insteadOf "gh:"
  git config --global url.https://bitbucket.org.insteadOf "bb:"
  git config --global url.https://gist.github.com.insteadOf "gist:"

  ### Style config ####
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.side-by-side true
  git config --global delta.line-numbers true
  git config --global delta.line-numbers-left-format " "
  git config --global delta.line-numbers-right-format "│ "
  git config --global delta.plus-color "#012800"
  git config --global delta.minus-color "#340001"
  #git config --global delta.minus-style red bold ul "#ffeeee"     ???
  #git config --global delta.syntax-theme "Monokai Extended"
  git config --global delta.syntax-theme "Dracula"
  git config --global delta.navigate true
  git config --global delta.light true
  git config --global merge.conflictstyle diff3
  git config --global diff.colorMoved default
  #git config --global quotepath false
  git config --global delta.collared-trogon.commit-decoration-style "bold box ul"
  git config --global delta.collared-trogon.dark true
  git config --global delta.collared-trogon.file-decoration-style none
  git config --global delta.collared-trogon.file-style omit
  #git config --global delta.collared-trogon.hunk-header-decoration-style "#022b45" box ul
  git config --global delta.collared-trogon.hunk-header-file-style "#999999"
  git config --global delta.collared-trogon.hunk-header-style "file line-number syntax"
  git config --global delta.collared-trogon.line-numbers true
  git config --global delta.collared-trogon.line-numbers-left-style "#022b45"
  git config --global delta.collared-trogon.line-numbers-minus-style "#80002a"
  git config --global delta.collared-trogon.line-numbers-plus-style "#003300"
  git config --global delta.collared-trogon.line-numbers-right-style "#022b45"
  git config --global delta.collared-trogon.line-numbers-zero-style "#999999"
  git config --global delta.collared-trogon.syntax-theme Nord

  git config --global fetch.prune true
}

GeneralConfig
Aliases
#InstallFansy
InstallDelta
Other
