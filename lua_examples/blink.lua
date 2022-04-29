print("====================BLINK LED================")

local pin = 0
gpio.mode(pin, gpio.OUTPUT)
flag = 0

tmr.create():alarm(1000, tmr.ALARM_AUTO, function()
    if flag == 0 then
        flag = 1
        gpio.write(pin, gpio.HIGH)
    else
        flag = 0
        gpio.write(pin, gpio.LOW)
    end
end)

