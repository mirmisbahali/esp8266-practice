wifi.setmode(wifi.SOFTAP)
wifi.ap.config({ssid = "esp", pwd = "123456789", auth = wifi.WPA2_PSK})

ledPin = 0
gpio.mode(ledPin, gpio.OUTPUT)

function control(res)
    print(res)
    
    if res == 'ON' then gpio.write(ledPin, gpio.LOW)
    else gpio.write(ledPin, gpio.HIGH)
    end

    return
end

srv = net.createServer(net.TCP)

srv:listen(80, function(conn) 

    conn:on('receive', function(client, request) 

        find = {string.find(request, 'ledState=')}
        if #find ~= 0 then control(string.sub(request, find[2] + 1)) end

        client:send('<!DOCTYPE html><html lang="en"><head> <meta charset="UTF-8"> <meta http-equiv="X-UA-Compatible" content="IE=edge"> <meta name="viewport" content="width=device-width, initial-scale=1.0"> <title>Document</title></head><body> <form action="" method="POST"> <input name="ledState" type="submit" value="OFF"> <input name="ledState" type="submit" value="ON"> </form></body></html>')


        conn:on("sent", function(c) c:close() end)
    end)
end)