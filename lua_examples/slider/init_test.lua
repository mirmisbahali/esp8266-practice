function connected()
    print("Nodemcu connected to wifi")
    
end

function disconnected() 
    print("Nodemcu disconnected")
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, connected)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, disconnected)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function() print("IP: " .. wifi.sta.getip()) end)
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid = "esp-guest", pwd = "12345678!"})



srv = net.createServer(net.TCP)

srv:listen(80, function(conn) 

    conn:on('receive', function(client, request) 

        print(request)
        

        
        find = {string.find(request, 'slider')}
        if #find ~= 0 then
            print(find[1], find[2])
            value = string.sub(request, find[2]+2, #request)
            print("value=", value)
            
        end
        

        

        
        client:send([[
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta http-equiv="X-UA-Compatible" content="IE=edge">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Slider</title>
            </head>
            <body>
                <input onchange="slider(this)" type="range" name="clawServo" id="clawServo" min="0" max="180">
                <input onchange="slider(this)" type="range" name="leftServo" id="leftServo" min="0" max="180">
                <input onchange="slider(this)" type="range" name="rightSerervo" id="rightSerervo" min="0" max="180">
                <input onchange="slider(this)" type="range" name="baseServo" id="baseServo" min="0" max="180">
                <script>
                function slider(el) {
                    console.log(`Name: ${el.name}`)
                    console.log(`Value: ${el.value}`)
                    const xhttp = new XMLHttpRequest();
                    xhttp.onload = function() {
                        console.log(el);
                    }
                    xhttp.open("GET", `/slider?${el.name}=${el.value}`, true);
                    xhttp.send();
                }
                </script>
            </body>
            </html>
        ]])


        conn:on("sent", function(c) c:close() end)
    end)
end)