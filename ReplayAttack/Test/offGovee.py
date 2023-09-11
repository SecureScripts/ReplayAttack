import socket
import struct
import sys

message = '{"msg": {"cmd": "scan","data": {"account_topic": "reserve"}}}'
multicast_group = ('239.255.255.250', 4001)

# Create the datagram socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Set a timeout so the socket does not block indefinitely when trying
# to receive data.
sock.settimeout(2)
# Set the time-to-live for messages to 1 so they do not go past the
# local network segment.
ttl = struct.pack('b', 1)
sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, ttl)


UDP_IP = "10.10.0.1"
UDP_PORT = 4002
sockClient = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sockClient.bind((UDP_IP, UDP_PORT))

try:
    # Send data to the multicast group
    print('sending "%s"' % message)
    sent = sock.sendto(message.encode("UTF-8"), multicast_group)
    while True:
        data, addr = sockClient.recvfrom(1024)  # buffer size is 1024 bytes
        print("received message: %s" % data)

finally:
    print('closing socket')
    sock.close()



