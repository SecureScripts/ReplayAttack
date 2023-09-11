#!/bin/bash
ANDROID_SERIAL="$1"
MAC_DEVICE="$2"
INTERFACE="$3"
PACKAGE="$4"


training_times=5
tap_time="5s"
open_time="10s"


tshark_time=$((40))
tshark_time=$((tshark_time*2))
echo $tshark_time
#temp=$(./switch_network.sh $ANDROID_SERIAL $INTERFACE)
#MAC_SMARTPHONE="${temp##*$'\n'}"
MAC_SMARTPHONE=$5
#echo $MAC_SMARTPHONE

#temp_target_ip_address=$(arp -a | grep $MAC_DEVICE | awk '{print $2}')
#let len=${#temp_target_ip_address}-1
#IP_DEVICE=$(cut -c 2-$len <<< $temp_target_ip_address)
#iptables -I FORWARD 1 -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP
#iptables -I FORWARD 2 -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE
#trap 'iptables -D FORWARD -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP; iptables -D  FORWARD -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE' SIGINT


filter="(ether src  $MAC_DEVICE and dst host 10.10.0.1)"

for i in 1
do
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Experiment_$i"
   mkdir -p "$EXP_FOLDER"
   
   sleep 2s
    tshark -i "$INTERFACE" -f "$filter" -w "$EXP_FOLDER/capture.pcap" -a duration:"$tshark_time" &
    sleep 20s

python3 ../Test/statusGoove.py "0"
    sleep 5s
    python3 ../Test/statusGoove.py "1"
sleep 5s
python3 ../Test/statusGoove.py "0"
    sleep 5s
    python3 ../Test/statusGoove.py "1"
sleep 5s
python3 ../Test/statusGoove.py "0"
    sleep 5s
    python3 ../Test/statusGoove.py "1"
sleep 5s
python3 ../Test/statusGoove.py "0"
    sleep 5s
    python3 ../Test/statusGoove.py "1"
sleep 5s
python3 ../Test/statusGoove.py "0"
    sleep 5s
    python3 ../Test/statusGoove.py "1"
sleep 5s

   wait
   chmod +r "$EXP_FOLDER"/capture.pcap
   python3 TrainingReplay.py "$EXP_FOLDER/capture.pcap" "$EXP_FOLDER"  > $EXP_FOLDER/accuracy.txt
done

chmod -R 777 Result


#iptables -D FORWARD -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP
#iptables -D  FORWARD -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE
