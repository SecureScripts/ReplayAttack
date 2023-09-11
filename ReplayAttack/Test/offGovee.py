import json,time,socket,struct


message = {
    "msg":{
        "cmd":"scan",
        "data":{
            "account_topic":"reserve",
        }
    }
}

group = "239.255.255.250"
port = 4001
# 2-hop restriction in network
ttl = 2
sock = socket.socket(socket.AF_INET,
                     socket.SOCK_DGRAM,
                     socket.IPPROTO_UDP)
sock.setsockopt(socket.IPPROTO_IP,
                socket.IP_MULTICAST_TTL,
                ttl)
jsonResult = json.dumps(message)







MCAST_GRP = "239.255.255.250"
MCAST_PORT = 4002

sockClient = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sockClient.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sockClient.bind(('', MCAST_PORT))
mreq = struct.pack("4sl", socket.inet_aton(MCAST_GRP), socket.INADDR_ANY)

sockClient.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)


try:
    print("Sending: " + jsonResult)
    sock.sendto(bytes(jsonResult, "utf-8"), (group, port))
    while True:
        print("Listening on {}".format(MCAST_PORT))
        if sockClient.recv:
            print(sockClient.recv(10240))
            break
finally:
    print('closing socket')
    sock.close()


