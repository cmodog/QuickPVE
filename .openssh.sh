sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "        post-up iptables-restore < /etc/iptables" >> /etc/network/interfaces
systemctl restart ssh
