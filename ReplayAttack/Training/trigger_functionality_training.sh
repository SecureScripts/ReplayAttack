#!/bin/bash

PHONE="smartphoneGoogle"
CAPT_DIR="$3"

function waitphone {
    while [ -z "$PHONE_FOUND" ]; do
        echo "Phone not found, waiting for $PHONE/$ANDROID_SERIAL"
        sleep 5
       PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL`
    done
}

ANDROID_SERIAL="$1"
echo Phone is: $PHONE/$ANDROID_SERIAL
PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL | grep device`
waitphone
echo Phone ready, proceeding...

package="$2"

#while IFS=";" read name name_exp phone_exp package sleep1 function_1 function_2 function_3 function_4 function_5 function_6 function_7 function_8 function_9
#do
crop="$4"
file_path="$5"
#crop="850x120+70+1520" #"850x120+70+1936"

#function_1="tap 220 1945" #ON LAMPADINA
#function_2="tap 860 1962" #OFF LAMPADINA


echo "Starting experiment"


end=$((SECONDS+300))
while  [ $SECONDS -lt $end ]; do
sleep 3s
 

waitphone
adb -s $ANDROID_SERIAL shell -n monkey -p $package -c android.intent.category.LAUNCHER 1

sleep 5s

while read -r function
do
waitphone
adb -s $ANDROID_SERIAL shell -n input $function
sleep 5s
done < "$file_path"

 #capture screenshot
waitphone
adb -s $ANDROID_SERIAL shell -n screencap -p /sdcard/screen_exp.png
waitphone
adb -s $ANDROID_SERIAL pull /sdcard/screen_exp.png $CAPT_DIR/screen_exp.png
waitphone
adb -s $ANDROID_SERIAL shell -n rm /sdcard/screen_exp.png
 #comparing screenshot

COMP=$(convert $CAPT_DIR/reference.png $CAPT_DIR/screen_exp.png -crop $crop +repage miff:- | compare -verbose -metric MAE  - $CAPT_DIR/result.png 2>&1 | grep all | awk '{print $2}')
  if [ $COMP = "0" ]; then
       echo "Comparison ok"
	rm $CAPT_DIR/screen_exp.png
	rm $CAPT_DIR/result.png
  else
  echo "Error comparison"      
  fi

waitphone
adb -s $ANDROID_SERIAL shell am force-stop $package

done
