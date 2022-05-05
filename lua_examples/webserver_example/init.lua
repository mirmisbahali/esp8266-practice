--nodemcu_test_startup
-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("credentials.lua")
dofile("LEDBlinkn.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        LEDBlinkStop()
        file.close("LEDBlinkn.lua")
        -- the actual application is stored in 'application.lua'
        dofile("application.lua")
    end
end

-- Define WiFi station event callbacks
wifi_connect_event = function(T)
    -- print("Connection to AP("..T.SSID..") established!")
    -- print("Waiting for IP address...")
    -- if disconnect_ct ~= nil then disconnect_ct = nil end
    -- LEDBlinkN(1,100,200) -- faster blinks
    print(wifi.ap.getbroadcast())
end

wifi_got_ip_event = function(T)
    -- Note: Having an IP address does not mean there is internet access!
    -- Internet connectivity can be determined with net.dns.resolve().
    print("Wifi connection is ready! IP address is: "..T.IP)
    print("Startup will resume momentarily, you have 3 seconds to abort.")
    print("Waiting...")
    startUpTimer = tmr.create() -- JFM mod to allow abort
    startUpTimer:alarm(3000, tmr.ALARM_SINGLE, startup)
    LEDBlinkN(3,50,550) -- fast warning 3, delay
end

function stopWiFi() -- JFM
    LEDBlinkStop()
    startUpTimer:stop()
    startUpTimer:unregister()
end

wifi_disconnect_event = function(T)
    LEDBlinkN(2,100,700) -- double flash with delay = error
    if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
    --the station has disassociated from a previously connected AP
    return
end

-- total_tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
local total_tries = 75
print("\nWiFi connection to AP("..T.SSID..") has failed!")
--There are many possible disconnect reasons, the following iterates through
--the list and returns the string corresponding to the disconnect reason.

for key,val in pairs(wifi.eventmon.reason) do
    if val == T.reason then
        print("Disconnect reason: "..val.."("..key..")")
        break
    end
end

if disconnect_ct == nil then
    disconnect_ct = 1
else
    disconnect_ct = disconnect_ct + 1
end

if disconnect_ct < total_tries then
    print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")")
else
    wifi.sta.disconnect()
    print("Aborting connection to AP!")
    disconnect_ct = nil
end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, wifi_connect_event)
-- wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
-- wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, wifi_disconnect_event)

LEDBlinkN(1,200,400) -- Idle

print("Connecting to WiFi access point...")
wifi.setmode(wifi.SOFTAP)
wifi.ap.config({ssid=SSID, pwd=PASSWORD})
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default