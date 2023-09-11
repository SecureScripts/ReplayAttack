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


MCAST_GRP = "239.255.255.250"
MCAST_PORT = 4002

sockClient = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sockClient.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sockClient.bind(('', MCAST_PORT))
mreq = struct.pack("4sl", socket.inet_aton(MCAST_GRP), socket.INADDR_ANY)

sockClient.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)



try:
    # Send data to the multicast group
    print('sending "%s"' % message)
    sent = sock.sendto(message.encode("UTF-8"), multicast_group)
    while True:
        print("Listening on {}".format(MCAST_PORT))
        if sockClient.recv:
            print(sockClient.recv(10240))
            break
finally:
    print('closing socket')
    sock.close()



