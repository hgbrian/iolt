Internet of lab things
======================
See http://blog.booleanbiotech.com/iolt.html for details.

The nodemcu firmware was compiled at https://nodemcu-build.com with the following modules (not all of these are necessary, for example, `ws2812` is for controlling LEDs):

	cjson, dht, file, gpio, http, mqtt, net, node, rtcfifo, rtcmem, rtctime, struct, tmr, uart, wifi, ws2812.

The firmware was flashed using [esptool](https://github.com/espressif/esptool) and the following command:

	esptool.py --port=/dev/cu.wchusbserial1420 write_flash -fm=dio -fs=32m 0x00000 nodemcu-master-9-modules-2016-12-31-01-53-36-float.bin

The --port parameter may be different depending on your USB serial driver. 
