#!/bin/bash

MAC_DEVICE="$1"
INTERFACE="$2"

temp_target_ip_address=$(arp -a | grep $MAC_DEVICE | awk '{print $2}')
echo $temp_target_ip_address
let len=${#temp_target_ip_address}-1
IP_DEVICE=$(cut -c 2-$len <<< $temp_target_ip_address)
iptables -I FORWARD 1 -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP
iptables -I FORWARD 2 -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE
trap 'iptables -D FORWARD -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP; iptables -D  FORWARD -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE' SIGINT

