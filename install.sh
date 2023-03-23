#!/bin/bash

### By Andrii Kondratiev ###

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

CheckOS
echo 
