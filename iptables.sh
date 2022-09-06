#!/bin/bash

echo "1. 主机端"
echo "2. 客户端"
read -p "请选择你是主机端还是客户端:" hg
while true
do
    if (($hg == 1)); then
        while true
        do
            echo "1. 添加PNAT转换"
            echo "2. 查看PNAT转换"
            echo "3. 删除PNAT转换"
            echo "0. 退出"
            read -p "输入数字选择功能: " choice

            if (($choice == 1)); then
                read -p "请输入需要被转发端口lxc容器的内网IP: " ip
                read -p "请输入你要分配给这个lxc的端口段(例如8000:9000): " ports
                iptables -t nat -A PREROUTING -p tcp -m multiport --dport ${ports}  -j DNAT --to-destination ${ip}
                iptables-save > /etc/iptables
            elif (($choice == 2)); then
                iptables -t nat --list --line-number
            elif (($choice == 3)); then
                iptables -t nat --list --line-number
                read -p "请输入要删除的编号: " num
                iptables -t nat -D PREROUTING ${num}
                iptables-save > /etc/iptables
            elif (($choice == 0)); then
                break 2
            else
                echo "输入有误，请重新输入: "
            fi
        done
    elif (($hg == 2)); then
        while true
        do
            echo "1. 添加PNAT转换"
            echo "2. 查看PNAT转换"
            echo "3. 删除PNAT转换"
            echo "0. 退出"
            read -p "输入数字选择功能: " choice
            if (($choice == 1)); then
                read -p "请输入你需要被转发的端口: " sport
                read -p "请输入你需要转发到公网IP的端口: " dport
                iptables -t nat -A PREROUTING -p tcp --dport ${dport} -j REDIRECT --to-ports ${sport}
                iptables-save > /etc/iptables
            elif (($choice == 2)); then
                iptables -t nat --list --line-number
            elif (($choice == 3)); then
                iptables -t nat --list --line-number
                read -p "请输入要删除的编号: " num
                iptables -t nat -D PREROUTING ${num}
                iptables-save > /etc/iptables
            elif (($choice == 0)); then
                break 2
            else
                echo "输入有误，请重新输入: "
            fi
        done
    else
        echo "输入有误，请重新输入"
    fi
done
