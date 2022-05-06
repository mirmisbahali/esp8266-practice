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
            args = string.sub(request, find[2]+2, #request)
            
            local servo = {}
            if (args ~= nil) then
                local n = 0
                for k, v in string.gmatch(args, "(%w+)=(%w+)") do
                    if string.match(k, "Servo") then
                        servo.name = k
                        servo.pos = tonumber(v)
                    end
                end
            end

            local clawServoPin = 1
            local leftServoPin = 2
            local rightServoPin = 3
            local baseServoPin = 4

            pwm.setup(clawServoPin, 50, 20)
            pwm.setup(leftServoPin, 50, 20)
            pwm.setup(rightServoPin, 50, 20)
            pwm.setup(baseServoPin, 50, 20)

            pwm.start(clawServoPin)
            pwm.start(leftServoPin)
            pwm.start(rightServoPin)
            pwm.start(baseServoPin)
            
            local 
            function setServoPos(pin, pos) 
                dc = ((100/180)*pos) + 20
                print("Duty Cycle = " .. dc)
                pwm.setduty(pin, dc)
                return
            end

            if servo.name == "clawServo" then
                setServoPos(clawServoPin, servo.pos)
            else if servo.name == "leftServo" then
                setServoPos(leftServoPin, servo.pos)
            else if servo.name == "rightServo" then
                setServoPos(rightServoPin, servo.pin)
            else if servo.name = "baseServo" then
                setServoPos(baseServoPin, servo.pin)


            
            
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