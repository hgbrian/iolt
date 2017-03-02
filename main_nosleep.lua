dofile("credentials.lua")
print("main")
sleeptime = 600000000 -- 1000000 per second
numdata = 10
t=-999
h=-999

_rtcfifo = {}

function main()
    for i=1,3 do
        pcall(function()
            _status, t, h, _temp_dec, _humi_dec = dht.read(4)
        end
        )
    
        print( "status", _status, t, h, _temp_dev, _humi_dec )
        if _status == dht.OK then
            print( "DHT OK." )
        elseif _status == dht.ERROR_CHECKSUM then
            print( "DHT Checksum error." )
        elseif _status == dht.ERROR_TIMEOUT then
            print( "DHT timed out." )
        end
    
        --tmr.delay(100000)
        if _status == dht.OK then
            if t ~= -999 then
                break
            end
        end
    end


    if t ~= -999 then  
      local tm, usec = rtctime.get()
      if tm==0 then
        print("set time")
        rtctime.set(1483228800)
      end
  
      table.insert(_rtcfifo, t)
      table.insert(_rtcfifo, h)
  
      print("put", t, h, #_rtcfifo)
      if #_rtcfifo >= numdata then
        print("do http")
    
        jsok, vjson = pcall(cjson.encode, _rtcfifo)
        _rtcfifo = {}
        if jsok then
            ----------------------------------------------------------------------------------
            -- Connect to wifi and POST data
            --
            print("Connecting to WiFi access point..."..WIFI_SSID)
            wifi.setmode(wifi.STATION)
            wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)
            -- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
            tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
                if wifi.sta.getip() == nil then
                    print("Waiting for IP address...")
                else
                    tmr.stop(1) -- also tmr.unregister(1) ?
                    http.post(APPENGINE_SERVER.."/dht22",
                      'Content-Type: application/json\r\n',
                      vjson,
                      function(code, data)
                        if (code < 0) then
                          print("HTTP request failed")
                        else
                          print(code, data)
                        end
                        -- turn off
                        --tmr.delay(sleeptime)
                      end)
                end
            end)

        else
          -- json is not ok
          --tmr.delay(sleeptime)
        end
      else
        -- count < numdata
        print("nosleep")
        --tmr.delay(sleeptime)
      end
    else
      print("no DHT connection")
      --tmr.delay(sleeptime)
    end

end

main()
tmr.create():alarm(sleeptime/1000, tmr.ALARM_AUTO, main)
