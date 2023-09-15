#!/bin/bash
NAME_PLUG=$1

python3 kasa-off.py --plugid $NAME_PLUG --username iotlabUCL@gmail.com --password IoTlabUCL
sleep 5s
python3 kasa-on.py --plugid $NAME_PLUG --username iotlabUCL@gmail.com --password IoTlabUCL
