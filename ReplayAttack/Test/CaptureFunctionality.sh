#!/bin/bash
#!/bin/bash
ANDROID_SERIAL="$1"
MAC_DEVICE="$2"
INTERFACE="$3"
PACKAGE="$4"

CROP_FUN=$(cat Result/$MAC_DEVICE/Capture/Fun_crop.txt)
CROP_REVERSE=$(cat Result/$MAC_DEVICE/Capture/Reverse_crop.txt)

tap_time="5s"
open_time="10s"
delay_time=10


#temp=$(./switch_network.sh $ANDROID_SERIAL $INTERFACE)
#MAC_SMARTPHONE="${temp##*$'\n'}"
MAC_SMARTPHONE=$5

#temp_target_ip_address=$(arp -a | grep $MAC_DEVICE | awk '{print $2}')
#let len=${#temp_target_ip_address}-1
#IP_DEVICE=$(cut -c 2-$len <<< $temp_target_ip_address)
#iptables -I FORWARD 1 -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP
#iptables -I FORWARD 2 -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE
#trap 'iptables -D FORWARD -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP; iptables -D  FORWARD -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE' SIGINT
PLUG_NAME=$6

tap_number=$(wc -l < Result/$MAC_DEVICE/Fun_coordinates.txt)
sniffing_time=$((tap_number*5+1+10+10))



filter="(ether src  $MAC_DEVICE and ether dst $MAC_SMARTPHONE) or (ether dst $MAC_DEVICE and ether src $MAC_SMARTPHONE)"


result="Experiment Failed"

while [[ $result != "Experiment Successfully" ]]
   do
  echo "CHECK THE INITIAL STATE"
    temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Ground_coordinates.txt Reverse True $tap_time $open_time)
    echo "THE INITIAL STATE IS ${temp##*$'\n'}"
    if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
    then
    	echo "REVERSING THE STATE"
    	 temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse True $tap_time $open_time)
        if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
        echo "Experiment Failed"
        result="Experiment Failed: Repeat"
        continue
        fi
    fi


    echo "#############################STARTING SNIFFING#####################################"
    tshark -i "$INTERFACE" -f "$filter" -w "Result/$MAC_DEVICE/Experiments/Delayed/capture.pcap" -a duration:"$sniffing_time" &
    sleep 10s

    temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_FUN Result/$MAC_DEVICE/Fun_coordinates.txt Fun True $tap_time $open_time)
    wait
    chmod +r "Result/$MAC_DEVICE/Experiments/Delayed/capture.pcap"/capture.pcap
        if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
        echo "Experiment Failed"
        result="Experiment Failed: Repeat"
        continue
        fi
    sleep 5s
   ./Restart_device.sh $PLUG_NAME
    sleep 30s
    result="Experiment Successfully"
    echo "Sniffing Successfully"
done