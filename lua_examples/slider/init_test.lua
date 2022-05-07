function connected()
    print("Nodemcu connected to wifi")
    
end

function disconnected() 
    print("Nodemcu disconnected")
end

function mysplit (inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, connected)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, disconnected)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function() print("IP: " .. wifi.sta.getip()) end)
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid = "esp-guest", pwd = "12345678!"})

baseServoPin = 1
leftServoPin = 2
rightServoPin = 3
clawServoPin = 4

pwm.setup(clawServoPin, 50, 20)
pwm.setup(leftServoPin, 50, 100)
pwm.setup(rightServoPin, 50, 100)
pwm.setup(baseServoPin, 50, 40)

pwm.start(clawServoPin)
pwm.start(leftServoPin)
pwm.start(rightServoPin)
pwm.start(baseServoPin)

srv = net.createServer(net.TCP)

srv:listen(80, function(conn) 

    conn:on('receive', function(client, request) 

        print(request)
        

        
        find = {string.find(request, 'slider')}

        
        if #find ~= 0 then
            args = string.sub(request, find[2]+2, #request)
            
            local servo = {}
            
            sl = mysplit(args, "&")
            servo.name = mysplit(sl[1], "=")[2]
            
            if (sl[2] ~= nil) then
                local n = 0
                for k, v in string.gmatch(sl[2], "(%w+)=(%w+)") do
                    if string.match(k, "value") then
                        servo.pos = tonumber(v)
                    end
                end
            end

            
            
            function setServoPos(pin, pos)
                print("servoPin = " .. pin) 
                print("servoPos = " .. pos)
                dc = ((100/180)*pos) + 20
                print("Duty Cycle = " .. dc)
                pwm.setduty(pin, dc)
                return
            end

            if (servo.name == "clawServo") then
                setServoPos(clawServoPin, servo.pos)
            elseif (servo.name == "leftServo") then
                setServoPos(leftServoPin, servo.pos)
            elseif (servo.name == "rightServo") then
                setServoPos(rightServoPin, servo.pos)
            elseif (servo.name == "baseServo") then
                setServoPos(baseServoPin, servo.pos)
            else
              print("No servo changed")
            end

        end
        
        client:send([[
          <!DOCTYPE html>
          <html lang="en">
          
          <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Slider</title>
            <style>
              * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
              }
          
              body {
                width: 100vw;
                height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
              }
              .form-group {
                padding: 1.2rem 0;
                display: flex;
                justify-content: space-between;
                align-items: center;
              }
          
              .form-group label {
                padding: 0 0.5rem;
              }
            </style>
          </head>
          
          <body>
            <div class="form-group">
              <label for="clawServo">Claw</label>
              <input onchange="slider(this)" type="range" name="clawServo" id="clawServo" min="0" max="180">
            </div>
            <div class="form-group">
              <label for="leftServo">Left</label>
              <input onchange="slider(this)" type="range" name="leftServo" id="leftServo" min="0" max="180">
            </div>
            <div class="form-group">
              <label for="rightServo">Right</label>
              <input onchange="slider(this)" type="range" name="rightServo" id="rightServo" min="0" max="180">
            </div>
            <div class="form-group">
              <label for="baseServo">Base</label>
              <input onchange="slider(this)" type="range" name="baseServo" id="baseServo" min="0" max="180">
            </div>
            <script>
              function slider(el) {
                console.log(`Name: ${el.name}`)
                console.log(`Value: ${el.value}`)
                const xhttp = new XMLHttpRequest();
                xhttp.onload = function () {
                  console.log(el);
                }
                xhttp.open("GET", `/slider?name=${el.name}&value=${el.value}`, true);
                xhttp.send();
              }
            </script>
          </body>
          
          </html>
        ]])


        conn:on("sent", function(c) c:close() end)
    end)
end)