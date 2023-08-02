function waitphone {
    while [ -z "$PHONE_FOUND" ]; do
        echo "Phone not found, waiting for $PHONE/$ANDROID_SERIAL"
        sleep 5
       PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL`
    done
}

ANDROID_SERIAL="954AY0U0EE"
echo Phone is: $PHONE/$ANDROID_SERIAL
PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL | grep device`
waitphone
echo Phone ready, proceeding...


waitphone
adb -s $ANDROID_SERIAL shell -n screencap -p /sdcard/reference.png
waitphone
adb -s $ANDROID_SERIAL pull /sdcard/reference.png ./reference.png
waitphone
adb -s $ANDROID_SERIAL shell -n rm /sdcard/screen_exp.png