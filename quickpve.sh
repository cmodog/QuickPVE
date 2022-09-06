#!/bin/bash

echo "1. 创建LXC容器"
echo "2. 销毁LXC容器"
echo "3. 管理LXC容器" 
echo "4. 查看LXC容器"
echo "5. 配置iptables转换"
read -p "请选择功能: " choice

if (($choice == 1)); then
    echo "启动下载服务，确保18080端口不被占用"
    python3 -m http.server 18080 &
    pveam list local
    read -p "请选择需要使用的镜像(只支持debian系)(例:local:vztmpl/debian.tar.zst): " ostemplate
    pvesh get /nodes/pve/lxc
    read -p "请输入vmid(例:101): " vmid
    read -p "请输入要分配的CPU核心: " cores
    read -p "请输入要分配的内存(单位M): " memory
    read -p "请输入要分配的磁盘大小(单位G): " size
    pvesh get /nodes/pve/network
    read -p "请输入要桥接的网卡: " bridge
    read -p "请输入IP: " ip
    read -p "请输入需要分配的ssh端口(例如10022): " port
    read -p "请输入密码: " password

    pvesh create nodes/pve/lxc --vmid ${vmid} --ostemplate ${ostemplate} --features nesting=1  --onboot 1 --password ${password} --cores ${cores} --memory ${memory} --net0 name=eth0,bridge=${bridge},ip=${ip}/24,gw=192.168.1.1

    echo "创建成功"
    echo "调整容量......"

	pct resize ${vmid} rootfs ${size}G
    pvesh create /nodes/pve/lxc/${vmid}/status/start
    echo "正在启动......"
    echo "准备初始化LXC容器"
    read -p "请输入允许IP转发的端口(例10022:10030): " ports
    iptables -t nat -A PREROUTING -p tcp -m multiport --dport ${ports}  -j DNAT --to-destination ${ip}
    lxc-attach ${vmid} -- apt install iptables curl wget -y

    lxc-attach ${vmid} -- wget http://192.168.1.1:18080/iptables.sh -o /root/iptables.sh
    lxc-attach ${vmid} -- mv iptables.sh /root/iptables.sh
    lxc-attach ${vmid} -- wget http://192.168.1.1:18080/.openssh.sh -o /root/.openssh.sh
    lxc-attach ${vmid} -- mv .openssh.sh /root/.openssh.sh
    lxc-attach ${vmid} -- chmod +x /root/.openssh.sh
    lxc-attach ${vmid} -- /root/.openssh.sh
    lxc-attach ${vmid} -- rm /root/.openssh.sh

    lxc-attach ${vmid} -- chmod +x /root/iptables.sh
    echo "net.ipv4.ip_forward = 1" | lxc-attach ${vmid} -- tee /etc/sysctl.conf
    lxc-attach ${vmid} -- sysctl -p
    lxc-attach ${vmid} -- iptables -t nat -A PREROUTING -p tcp --dport ${port} -j REDIRECT --to-ports 22
    kill `ps aux | grep http.server | awk '{print $2}' | sed -n '1p'`


elif (($choice == 2)); then
    pvesh get /nodes/pve/lxc
    read -p "请输入要销毁的vmid(例:101): " vmid
    pvesh create /nodes/pve/lxc/${vmid}/status/stop
    pvesh delete /nodes/pve/lxc/${vmid}

elif (($choice == 3)); then
    echo "1. 开机"
    echo "2. 关机"
    read -p "请选择功能: " manage
    if (($manage == 1)); then
        pvesh get /nodes/pve/lxc
        read -p "请输入要开机的vmid: " vmid
        pvesh create /nodes/pve/lxc/${vmid}/status/start
    elif (($manage == 2)); then
        pvesh get /nodes/pve/lxc
        read -p "请输入要关机的vmid: " vmid
        pvesh create /nodes/pve/lxc/${vmid}/status/stop
    fi
elif (($choice == 4)); then
    pvesh get /nodes/pve/lxc

elif (($choice == 5)); then
    ./iptables.sh
fi
