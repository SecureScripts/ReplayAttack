import sys
import time

from libsoundtouch import soundtouch_device
from libsoundtouch.utils import Source, Type

from libsoundtouch import discover_devices

devices = discover_devices(timeout=2)  # Default timeout is 5 seconds


for device in devices:
    print(device.config.name + " - " + device.config.type)


time.sleep(2)

stat=str(sys.argv[1])

device = soundtouch_device('10.12.0.27')




if(stat=="on"):
  device.power_on()

if(stat=="off"):
  device.power_off()


time.sleep(2)
# Status object
# device.status() will do an HTTP request. Try to cache this value if needed.
status = device.status()
print(status.source)
#print(status.artist+ " - "+ status.track)
#device.pause()
#device.next_track()
#device.play()
