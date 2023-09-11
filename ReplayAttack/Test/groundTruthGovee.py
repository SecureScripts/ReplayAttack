import json,time,socket,struct
import sys



message = {
    "msg":{
        "cmd":"scan",
        "data":{
            "account_topic":"reserve",
        }
    }
}

statusMessage= {
  "msg": {
    "cmd": "devStatus",
    "data": {
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

jsonResultStatus = json.dumps(statusMessage)







MCAST_GRP = "239.255.255.250"
MCAST_PORT = 4002

sockClient = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sockClient.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sockClient.bind(('', MCAST_PORT))
mreq = struct.pack("4sl", socket.inet_aton(MCAST_GRP), socket.INADDR_ANY)

sockClient.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)


try:
    sock.bind(("10.10.0.1", 60000))
    sock.sendto(bytes(jsonResult, "utf-8"), (group, port))
    while True:
        if sockClient.recv:
            break
    sockClient.sendto(bytes(jsonResultStatus, "utf-8"), ("10.10.0.22", 4003))
    while True:
        if sockClient.recv:
            r=sockClient.recv(10240)
            status=json.loads(sockClient.recv(10240).decode("utf-8"))["data"]["onOff"]
            if(str(status)=="0"):
                print("Replay Attack NOT working")
            else:
                print("Replay Attack working")
            break

finally:
    sock.close()



