#!/bin/bash

if (( $EUID != 0 )); then
	echo "\e[1;31mPlease run as root\e[m"
	exit
fi

echo "[\e[1;32m*\e[m] \e[0;32mUpdating...\e[m"
apt update && apt upgrade -y

echo "[\e[1;32m*\e[m] \e[0;32mInstalling standard tools...\e[m"
# Terminal
apt install -y terminator

# CRT 
apt install -y rsh-client ipcalc finger nbtscan-unixwiz
# ... need an old version of rsh-client
curl -O http://http.us.debian.org/debian/pool/main/n/netkit-rsh/rsh-client_0.17-17+b1_amd64.deb
dpkg -i rsh-client_0.17-17+b1_amd64.deb
rm rsh-client_0.17-17+b1_amd64.deb
# Others
apt install -y seclists

echo "[\e[1;32m*\e[m] Config Changes..."
# Set default terminal
#TODO Find out how to do this one!
# Remove the default SSH keys
cd /etc/ssh
rm ssh_host_*
dpkg-reconfigure openssh-server
/etc/init.d/ssh restart
cd ~

echo "[\e[1;32m*\e[m] Tools..."
apt install -y python3-pip

# EyeWitness
git clone https://github.com/ChrisTruncer/EyeWitness.git /opt/EyeWitness
/opt/EyeWitness/Python/setup/setup.sh
# PCredz
apt install python3-pip && apt install libpcap-dev && pip3 install Cython && pip3 install python-libpcap
git clone https://github.com/lgandx/PCredz.git /opt/PCredz

# Crackmapexec
apt install crackmapexec

# Docker
apt install -y docker.io

# Syncthing
apt install -y syncthing
# Setup - see https://www.tylerburton.ca/2016/02/setting-up-syncthing-to-share-files-on-linux/
# ... syncthing user service
mkdir -p ~kali/.config/systemd/user
cp /usr/lib/systemd/user/syncthing.service ~kali/.config/systemd/user/
chown kali:kali ~kali/.config/systemd/user
chown kali:kali ~kali/.config/systemd/user/syncthing.service

echo "[\e[1;32m*\e[m] .zshrc Functions & Aliases..."
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
		mkdir by-ip;
		mkdir by-hostname;
		mkdir ntlm
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
		ln -s "../by-ip/$result" "../../by-hostname/\$1";
		echo -n \$1 > hostname
	else
		echo 'Wrong Directory';
	fi
}
EOT
# Do the same for root
# TODO

echo "[\e[1;32m*\e[m] Done!"

echo "[\e[1;31m!\e[m] Syncthing - run following as standard user to enable service"
echo "systemctl --user enable syncthing.service"
echo "systemctl --user start syncthing.service"
echo "[\e[1;31m!\e[m] Keyboard - change layout"
echo "sudo dpkg-reconfigure keyboard-configuration"
echo "[\e[1;31m!\e[m] Don't forget to change your password"
