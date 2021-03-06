dofile("credentials.lua")
print("main")
sleeptime = 600000000 -- 600 seconds
numdata = 100
t=-999
h=-999


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
    
    tmr.delay(100000)
    if t ~= -999 then
        break
    end
end

if t ~= -999 then
  
  if rtcfifo.ready() == 0 then
    print("prepare")
    rtcfifo.prepare({storage_begin=21, storage_end=128})
  end
  
  local tm, usec = rtctime.get()
  if tm==0 then
    print("set time")
    rtctime.set(1483228800)
  end
  
  rtcfifo.put(tm, t, 0, "t")
  rtcfifo.put(tm, h, 0, "h")
  
  local count = rtcfifo.count()
  print("put", t, h, count)
  if count >= numdata then
    print("do http")
  
    local tabl = {}
    local n = 1
    while rtcfifo.count() > 0 do
      local timestamp, val, neg_e, vname = rtcfifo.pop()
      tabl[n] = val
      n = n + 1
    end
    print("tabl[1]", tabl[1])
  
    jsok, vjson = pcall(cjson.encode, tabl)
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
                http.post(APPENGINE_SERVER,
                  'Content-Type: application/json\r\n',
                  vjson,
                  function(code, data)
                    if (code < 0) then
                      print("HTTP request failed")
                    else
                      print(code, data)
                    end
                    -- turn off
                    node.dsleep(sleeptime)
                  end)
            end
        end)

    else
      -- json is not ok
      node.dsleep(sleeptime)
    end
  else
    -- count < numdata
    print("sleep")
    node.dsleep(sleeptime)
  end
else
  print("no DHT connection")
  node.dsleep(sleeptime)
end

