# REPLIOT

REPLIOT is an automatic tool for testing replay attacks in a smart home environment. The tool is designed to be *agnostic* and works with any type of device that communicates with the companion app through the local network. REPLIOT includes a detection module that analyzes the device's responses to automatically determine the success of an attack.

## Usage in Home Environment
TODO

## Usage in the Laboratory

We utilized REPLIOT in a laboratory environment to assess replay attack vulnerabilities in 41 commercial IoT devices. To replicate our results, you need the physical device connected to an access point (AP) where the tool runs.

For each device under test, follow these steps:

### Setup
- Copy the ReplayAttack Folder on the AP. We used a laptop with Ubuntu 20.
- Install the companion app of the device on a smartphone (Google Pixel 3a was used in our tests).
- Create a folder named with the MAC address of the device inside "ReplayAttack/Test/Result."
- Within the above folder, create three files: `Fun_coordinates.txt`, `Reverse_coordinates.txt`, `Ground_coordinates.txt`. In `Fun_coordinates.txt`, insert the coordinates to lead the device into the OBVERSE state after the app is open. Similarly, insert coordinates into `Reverse_coordinates.txt` to lead the device into the REVERSE state after the app is open. Often, these two files have the same content. Finally, insert coordinates into `Ground_coordinates.txt` to lead the device into the screen before submitting the OBSERVE command. If you use a Google Pixel 3a, you can copy the coordinates from the folder of the device we used in our laboratory.
- Within the above folder, create the folder CAPTURE. Insert the screenshot of the smartphone as `Fun_reference.png` when it is in the OBSERVE state. Insert the screenshot of the smartphone as `Reverse_reference.png` when it is in the REVERSE state. If you use a Google Pixel 3a, you can copy the screenshot from the folder of the device we used in our laboratory.
- Connect the smartphone to the access point to control it via adb.

### Training Phase

Lunch the following command: 
```bash 
bash ReplayAttack/Training/Training_device.sh `SERIAL\_NUMBER` `MAC\_DEVICE` `INTERFACE` `PACKAGE` `MAC\_SMARTPHONE`
```
where:
  - SERIAL_NUMBER: Serial number of the phone in ADB.
  - MAC_DEVICE: MAC address of the IoT device.
  - INTERFACE: Network interface to sniff the traffic.
  - PACKAGE: Package name of the companion app.
  - MAC_SMARTPHONE: MAC address of the smartphone.

### Test Phase

Lunch the following command: 
```bash 
bash ReplayAttack/Test/test_device.sh `SERIAL\_NUMBER` `MAC\_DEVICE` `INTERFACE` `PACKAGE` `MAC\_SMARTPHONE`
```
where:
  - SERIAL_NUMBER: Serial number of the phone in ADB.
  - MAC_DEVICE: MAC address of the IoT device.
  - INTERFACE: Network interface to sniff the traffic.
  - PACKAGE: Package name of the companion app.
  - MAC_SMARTPHONE: MAC address of the smartphone.
