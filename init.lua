-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("credentials.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        dofile("main.lua")
    end
end

--tmr.stop(1)
print("You have 1 second to abort")
tmr.alarm(0, 100, tmr.ALARM_SINGLE, startup)
