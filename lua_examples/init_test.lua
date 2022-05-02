cfg = {}
cfg.ssid = "esp"
cfg.pwd = "12345678!"

client_connected = function(T)
    print("New Device Connected!")
    print("MAC: " .. T.MAC)
end

client_disconnected = function(T)
    print("MAC: " .. T.MAC .. " Disconnected")
end

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, client_connected)
wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, client_disconnected)



print("Setting up Wifi Access Point")
print(wifi.setmode(wifi.SOFTAP))
if wifi.ap.config(cfg) then
    print("Setup successful")
    print("http://" .. wifi.ap.getbroadcast())
    
end