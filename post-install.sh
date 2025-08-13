#!/bin/bash

if (( $EUID != 0 )); then
	echo -e "\e[1;31mPlease run as root\e[m"
	exit
fi

echo -e "[\e[1;32m*\e[m] \e[0;32mUpdating...\e[m"
apt update && apt upgrade -y

echo -e "[\e[1;32m*\e[m] \e[0;32mInstalling additional tools...\e[m"
# Terminal
apt install -y terminator
# Useful tools
apt install -y ipcalc nbtscan-unixwiz
# Seclists wordlists
apt install -y seclists

echo -e "[\e[1;32m*\e[m] Config Changes..."
# Set default terminal
#TODO Find out how to do this one!
# Remove the default SSH keys
cd /etc/ssh
rm ssh_host_*
dpkg-reconfigure openssh-server
# /etc/init.d/ssh restart # Uncomment this line to start SSH service
cd ~

echo -e "[\e[1;32m*\e[m] Tools..."
apt install -y python3-pip
# PCredz
apt install -y python3-pip libpcap-dev && pip3 install Cython && pip3 install python-libpcap
git clone https://github.com/lgandx/PCredz.git /opt/PCredz
# MITM6
git clone https://github.com/dirkjanm/mitm6.git /opt/mitm6
# Docker
apt install -y docker.io

echo -e "[\e[1;32m*\e[m] .zshrc Functions & Aliases..."
cp ~kali/.zshrc ~kali/.zshrc.orig
mkdir ~kali/Client
chown kali:kali ~kali/Client
cat << EOT >> ~kali/.zshrc
# Functions & Aliases
alias stripcolours='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'

createclient(){
	result=\${PWD##*/} 
	if [ "\$result" == 'Client' ]; then
		mkdir "\$1";
		cd "\$1";
  		mkdir targets;
		mkdir by-ip;
		mkdir by-hostname;
		mkdir hashes
		mkdir loot
	else
		echo 'Wrong Directory';	
	fi
}

addip(){
	result=\${PWD##*/} 
	if [ "\$result" == 'by-ip' ]; then
		mkdir "\$1";
		cd \$1;
		echo -n "\$1"  > ip
	else
		echo 'Wrong Directory';
	fi
}  

addhost(){
	result=\${PWD##*/} 
	if [ "\$result" == 'by-hostname' ]; then
		if [ "\$2" != "" ]; then 
			ln -s "../by-ip/\$2" "\$1";
			cd "\$1"
			echo -n \$1  > hostname
		else
			echo 'Missing 2nd Parameter?'
		fi
	elif [[ \$result =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		# Assume we're in the folder they wanted, so don't care about the IP
		ln -s "../by-ip/\$result" "../../by-hostname/\$1";
		echo -n \$1 > hostname
	else
		echo 'Wrong Directory';
	fi
}
startlog(){
	script "$(date +%F-%R)-$1.log"
}
EOT
# Do the same for root
# TODO

echo -e "[\e[1;32m*\e[m] Done!"

echo -e "[\e[1;31m!\e[m] Keyboard - change layout"
echo -e "sudo dpkg-reconfigure keyboard-configuration"
echo -e "[\e[1;31m!\e[m] Don't forget to change your password"
