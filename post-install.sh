#!/bin/bash

if (( $EUID != 0 )); then
	echo "Please run as root"
	exit
fi

echo "[*] Updating..."
apt update && apt upgrade -y

echo "[*] Installing standard tools..."
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

echo "[*] Config Changes..."
# Set default terminal
#TODO Find out how to do this one!
# Remove the default SSH keys
cd /etc/ssh
rm ssh_host_*
dpkg-reconfigure openssh-server
/etc/init.d/ssh restart
cd ~

echo "[*] Tools..."
apt install -y python3-pip
# EyeWitness
git clone https://github.com/ChrisTruncer/EyeWitness.git /opt/EyeWitness
/opt/EyeWitness/Python/setup/setup.sh
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

echo "[*] .zshrc Functions & Aliases..."
cp ~kali/.zshrc ~kali/.zshrc.orig
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

echo "[*] Done!"

echo "[!] Syncthing - run following as standard user to enable service"
echo "systemctl --user enable syncthing.service"
echo "systemctl --user start syncthing.service"
