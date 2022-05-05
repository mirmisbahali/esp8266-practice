cfg = {}
cfg.ssid = "esp"
cfg.pwd = "123456789"

client_connected = function(T)
    print("New Device Connected!")
    print("MAC: " .. T.MAC)
    print(wifi.ap.getbroadcast())

end

client_disconnected = function(T)
    print("MAC: " .. T.MAC .. " Disconnected")
end

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, client_connected)
wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, client_disconnected)




wifi.setmode(wifi.SOFTAP)
if wifi.ap.config(cfg) then
    srv = net.createServer(net.TCP)
    print(srv:getaddr())
        srv:listen(80, function(conn)
            print(wifi.ap.getbroadcast())
            conn:on("receive", function(conn, request)
                conn:send('<!DOCTYPE HTML>\n')
                conn:send('<html>\n')
                conn:send('<head><meta http-equiv="content-type" content="text/html; charset=UTF-8">\n')
                -- Scale the viewport to fit the device.
                conn:send('<meta name="viewport" content="width=device-width, initial-scale=1">')
                -- Title
                conn:send('<title>ESP8266 Wifi LED Control</title>\n')
                
                -- HTML body Page content.
                conn:send('<body>')
                conn:send('<h1>hello</h1>')
                conn:send('</body></html>\n')
                conn:on("sent",function(conn) conn:close() end)
            end)
        end) 
end
