<?php
require __DIR__ . '/vendor/autoload.php';

use Sabinus\SoundTouch\SoundTouchApi;
use Sabinus\SoundTouch\Component\ContentItem;
use Sabinus\SoundTouch\Constants\Source;
use Sabinus\SoundTouch\Constants\Key;


// Initialize object API
$api = new SoundTouchApi('192.168.0.1');

// Get informations
$info = $api->getInfo();
print 'DeviceID : '.$info->getDeviceID()."\n";
print 'Nom : '.$info->getName()."\n";
?>
