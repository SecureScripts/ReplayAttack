import os
import sys
import time
import pyshark
from sklearn.covariance import EllipticEnvelope
from sklearn.ensemble import IsolationForest
from sklearn.metrics import accuracy_score
from sklearn.svm import OneClassSVM

from nltk.tokenize import word_tokenize
from sklearn.feature_extraction.text import HashingVectorizer, CountVectorizer, TfidfTransformer
from sklearn.neighbors import LocalOutlierFactor
import pickle

from CustomClassifier import CustomClassifier

interface = str(sys.argv[1])
mac_app = str(sys.argv[2])
mac_device = str(sys.argv[3])
training_time = int(sys.argv[4])
model_path = str(sys.argv[5])

filter = '(ether src ' + mac_device + ' and ether dst ' + mac_app + ')'

import nltk
nltk.download('punkt')

capture = pyshark.LiveCapture(interface=interface, bpf_filter=filter)


def tokenizeText(sample):
    return list(set(word_tokenize(sample)))


start_time = time.time()
payload_set = []
max_features = 0
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
        elapsed_time = time.time() - start_time
        if (elapsed_time > training_time):
            break

        if (elapsed_time % 30 < 3):
            print("Elapsed time:" + str(elapsed_time))
        payload = bytes.fromhex(payload).decode('ISO-8859-1')

        if '{"error_code":9999}' in payload:
            print(
                '###########################################################################################################################################################')
            print('ERROR CODE!!!')
            print(
                '###########################################################################################################################################################')

        payload = payload.replace("/", "").replace("+", "")
        payload_set.append(payload)
        l = len(tokenizeText(payload))
        if l > max_features:
            max_features = l
    except AttributeError as e:
        print(e)
        continue
print('END SNIFFING')

vectorizer = HashingVectorizer(n_features=max_features, tokenizer=tokenizeText)
training_Set = vectorizer.fit_transform(payload_set).toarray()

real_labels = [1 for _ in range(len(payload_set))]

clf_svm = OneClassSVM(nu=0.001, kernel="rbf", gamma='auto')
clf_svm.fit(training_Set)
predicted_labels = clf_svm.predict(training_Set)
print("Accuracy SVM:")
print(accuracy_score(real_labels, predicted_labels))

clf_if = IsolationForest(contamination=0.01)
clf_if.fit(training_Set)
predicted_labels = clf_if.predict(training_Set)
print("Accuracy IF:")
print(accuracy_score(real_labels, predicted_labels))

clf_ee = EllipticEnvelope(contamination=0.01)
clf_ee.fit(training_Set)
predicted_labels = clf_ee.predict(training_Set)
print("Accuracy EE:")
print(accuracy_score(real_labels, predicted_labels))

clf_lo = LocalOutlierFactor(contamination=0.01, novelty=True)
clf_lo.fit(training_Set)
predicted_labels = clf_lo.predict(training_Set)
print("Accuracy LO:")
print(accuracy_score(real_labels, predicted_labels))

clf_cc = CustomClassifier()
clf_cc.fit(payload_set)
predicted_labels = clf_cc.predict(payload_set)
print("Accuracy CC:")
print(accuracy_score(real_labels, predicted_labels))


print("ThresholdsClusters:"+str(clf_cc.thresholdsCluster))


f = open(model_path+ "/feature_num.txt", "w")
f.write(str(max_features))
f.close()

pickle.dump(clf_svm, open(model_path + "/svm.sav", 'wb'))
pickle.dump(clf_if, open(model_path + "/if.sav", 'wb'))
pickle.dump(clf_ee, open(model_path + "/ee.sav", 'wb'))
pickle.dump(clf_lo, open(model_path + "/lo.sav", 'wb'))
pickle.dump(clf_cc, open(model_path + "/cc.sav", 'wb'))
