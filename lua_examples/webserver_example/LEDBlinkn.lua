local LEDpin = 4
local LEDState = false
local n = 0
local _nStart = 0
local _togDelay
local _interval
local blinkTimer = tmr.create()
local blinkInterval = tmr.create()
gpio.mode(4,gpio.OUTPUT)
gpio.write(LEDpin,gpio.HIGH) -- high is off for builtin LED.
-- Blink n times with delay between on-off then wait interval - repeat
function LEDBlinkN(numTog,togDelay,interval) -- Get round not having statics
if blinkTimer:state() ~= nil then LEDBlinkStop() end-- Stop if was previously started.
_nStart = numTog
_togDelay = togDelay
_interval = interval
doInterval()
end
function LEDBlinkStop()
if blinkTimer:state() ~= nil then
blinkTimer:unregister()
blinkInterval:unregister()
end
gpio.write(LEDpin,gpio.HIGH)
LEDState = false
n = 0
end
function toggleLEDbuiltin()
if blinkTimer:state() ~= nil and n <=0 then blinkTimer:unregister() return end
if (LEDstate) then
gpio.write(LEDpin,gpio.LOW)
else
gpio.write(LEDpin,gpio.HIGH) -- high is off for builtin LED.
n = n -1
end
LEDstate = not LEDstate
end
-- Fast toggle
function LEDBlinkNStart()
n = _nStart -- Initialise the toggle number
blinkTimer:alarm(_togDelay, tmr.ALARM_AUTO, function () toggleLEDbuiltin() end)
end
-- Interval timer
function doInterval()
LEDBlinkNStart() -- Start with the led toggle before the interval
blinkInterval:alarm(_interval, tmr.ALARM_AUTO, function () LEDBlinkNStart() end)
end
--test
--LEDBlinkN_setNumBlinks(50,4)
--LEDBlinkN(3,50,1500)