import sys

from nanoleafapi import Nanoleaf
nl = Nanoleaf("10.11.0.41")

command=sys.argv[1]

if(command=="on"):
    nl.power_on()
if(command=="off"):
    nl.power_off()
if(command=="ground"):
    if(nl.get_power()):
        print("Replay Attack working")
    else:
        print("Replay Attack NOT working")


