-- ESP8266 webserver
-- This allows control of the builtin LED - On/Off/Blink/Blink Off.
--
local outpin=4
local state = false

function init()
  gpio.mode(outpin,gpio.OUTPUT)
  gpio.write(outpin,gpio.HIGH) -- LED is pulled so HIGH = off
  blinkOFF()
end

function togLED()
  if state==false then gpio.write(outpin,gpio.HIGH)
  else gpio.write(outpin,gpio.LOW) end
  state = not state;
end

function blkinkON()
  if mytimer~=nil then return end -- Timer already on.
  mytimer = tmr.create()
  mytimer:alarm(200, tmr.ALARM_AUTO, function() togLED() end)
end

function blinkOFF()
  if mytimer==nil then return end -- Timer already off.
  mytimer:unregister() mytimer=nil
end

srv=net.createServer(net.TCP)

init()

srv:listen(80, function(conn)
conn:on("receive",function(conn,payload)
print(payload) -- View the received data,

function controlLED()
  control = string.sub(payload,fnd[2]+1) -- Data is at end already.
  if control == "ON" then gpio.write(outpin,gpio.LOW); blinkOFF() return end
  if control == "OFF" then gpio.write(outpin,gpio.HIGH); blinkOFF() return end
  if control == "Blink" then blkinkON() return end
  if control == "Blinkoff" then blinkOFF() return end
end

--get control data from payload
fnd = {string.find(payload,"ledbi=")}
if #fnd ~= 0 then controlLED() end -- Is there data in payload? - Take action if so.
  conn:send('<!DOCTYPE HTML>\n')
  conn:send('<html>\n')
  conn:send('<head><meta http-equiv="content-type" content="text/html; charset=UTF-8">\n')
  -- Scale the viewport to fit the device.
  conn:send('<meta name="viewport" content="width=device-width, initial-scale=1">')
  -- Title
  conn:send('<title>ESP8266 Wifi LED Control</title>\n')
  -- CSS style definition for submit buttons
  conn:send('<style>\n')
  conn:send('input[type="submit"] {\n')
  conn:send('color:#050; width:70px; padding:10px;\n')
  conn:send('font: bold 84% "trebuchet ms",helvetica,sans-serif;\n')
  conn:send('background-color:lightgreen;\n')
  conn:send('border:1px solid; border-radius: 12px;\n')
  conn:send('transition-duration: 0.4s;\n')
  conn:send('}\n')
  conn:send('input[type="submit"]:hover {\n')
  conn:send('background-color:lightblue;\n')
  conn:send('color: white;\n')
  conn:send('}')
  conn:send('</style></head>\n')
  -- HTML body Page content.
  conn:send('<body>')
  conn:send('<h1>Control of nodeMCU<br>(ESP8266-E12) Built in LED.</h1>\n')
  conn:send('<p>The built in LED for NodeMCU V3 is on D4</p>\n')
  -- HTML Form (POST type) and buttons.
  conn:send('<form action="" method="POST">\n')
  conn:send('<input type="submit" name="ledbi" value="ON" > Turn Built in LED on<br><br>\n')
  conn:send('<input type="submit" name="ledbi" value="OFF"> Turn Built in LED off<br><br>\n')
  conn:send('<input type="submit" name="ledbi" value="Blink"> Blink LED<br><br>\n')
  conn:send('<input type="submit" name="ledbi" value="Blinkoff"> Stop LED Blink</form>\n')
  conn:send('</body></html>\n')
  conn:on("sent",function(conn) conn:close() end)
  end)
end)