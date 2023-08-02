
import sys
import time
import pyshark

interface = str(sys.argv[1])
mac_app = str(sys.argv[2])
mac_device = str(sys.argv[3])



filter = '(ether src ' + mac_device + ' and ether dst ' + mac_app + ') or (ether src ' + mac_app + ' and ether dst ' + mac_device + ')'
capture = pyshark.LiveCapture(interface=interface, bpf_filter=filter)


for packet in capture.sniff_continuously():
    try:
        if packet.transport_layer == None:  # ASSUNZIONE: I PACCHETTI SCAMBIATI CON IL DEVICE HANNO UN LIVELLO DI TRASPORTO
            continue
        payload = ''
        if str(packet.transport_layer) == 'UDP':
            if packet.udp._all_fields.get("udp.payload") == None:
                continue
            payload = packet.udp._all_fields["udp.payload"].replace(":", "")
        if str(packet.transport_layer) == 'TCP':
            if packet.tcp._all_fields.get("tcp.payload") == None:
                continue
            payload = packet.tcp._all_fields["tcp.payload"].replace(":", "")
        if payload == '':
            print('ERROR')

        if len(payload) == 0:
            continue

        payload = bytes.fromhex(payload).decode('ISO-8859-1')

        print(payload)
    except AttributeError as e:
        print(e)
        continue
