#!/bin/bash

#Wlan2
#KETTLE-BOSE SPEAKER
#BOSE-->OK
#sleep 5s
#kettle
#./Test_device_Restart.sh 93PAY0E1MW fc:67:1f:a9:a7:8d wlan2 com.tuya.smartlife 58:cb:52:3c:16:f1 tapo_plug110_12


#./switch_network 93PAY0E1MW wlan0

#WLAN 0
#YEELIGHT-GOOVE-LEPRO-SONOS SPEAKER

chmod 777 *

./Govee_Test_device_Restart.sh 93PAY0E1MW d4:ad:fc:60:43:9a wlan0 com.govee.home 28:e3:47:8e:cf:a8 tapo_plug110_25

./Sonos_Test_device_Restart.sh 93PAY0E1MW 38:42:0b:68:76:30 wlan0 com.sonos.acr2 28:e3:47:8e:cf:a8 tapo_plug110_33

./Test_device_Restart.sh 93PAY0E1MW cc:8c:bf:cb:e1:df wlan0 com.lampux.ledbrighter 92:a3:f9:fe:6c:e9 tapo_plug110_25

./Test_device_Restart.sh 93PAY0E1MW ec:4d:3e:16:9b:e9 wlan0 com.yeelight.cherry 92:a3:f9:fe:6c:e9 tapo_plug110_4


./Test_device_Restart.sh 93PAY0E1MW fc:67:1f:a9:a7:8d wlan0 com.tuya.smartlife 92:a3:f9:fe:6c:e9 tapo_plug110_25
#WLAN 3
#EUFI MEROS

#WLAN1
#LIFX

#WLAN 4
#WIZ



