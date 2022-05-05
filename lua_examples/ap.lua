wifi.setmode(wifi.SOFTAP)
wifi.ap.config({ ssid = "test",  auth = wifi.OPEN})


srv = net.createServer(net.TCP)

print("Visit http://" .. wifi.ap.getip()) -- Get the IP address

srv:listen(80, function(conn)
    
    print("connection made")
    
    conn:on('receive', function(client, request)
    client:send('<h1>hello world</h1>')
    end) 

    conn:on("sent", function(c) c:close() end)
end)