wifi.setmode(wifi.SOFTAP)
wifi.ap.config({ ssid = "test",  auth = wifi.OPEN})

srv = net.createServer(net.TCP)

srv:listen(80, function(conn)
    print("connection made")
    print(wifi.ap.getip())
    conn:on('receive', function(client, request)
    print("connection receive")
    print("request:\t" .. request)
    client:send('<h1>hellow world</h1>')

    end) 
    conn:on("sent", function(c) c:close() end)
end)