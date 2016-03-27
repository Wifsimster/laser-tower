require('config')

-- Setup wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(AP,PWD)

-- Duty values
RIGHT = 1
CENTER = 510
LEFT = 1020

-- Declare servo motor
servo = {}
servo.pin = 4 -- GPIO_2
servo.clock = 500 -- PWM frequency (1 to 1000)
servo.duty = 512 -- PWM duty cycle (0 to 1023)

function delay_ms(milli_secs)
   local ms = milli_secs * 1000
   local timestart = tmr.now()
   while(tmr.now() - timestart < ms) do
      tmr.wdclr()
   end
end

function rotate(duty)
    pwm.setup(servo.pin, servo.clock, servo.duty)
    pwm.start(servo.pin)
    pwm.setduty(servo.pin, duty)
    delay_ms(500)
    pwm.stop(servo.pin)
    pwm.close(servo.pin)
end

rotate(CENTER)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        
        if(_GET.rotate == "LEFT")then
            print('Rotate to left')
            rotate(LEFT)
        elseif(_GET.rotate == "CENTER")then
            print('Rotate to center')
            rotate(CENTER)
        elseif(_GET.rotate == "RANDOM")then
            rd = math.random(RIGHT, LEFT)
            print('Random: '.. rd)
            rotate(rd)
        elseif(_GET.rotate == "RIGHT")then
            print('Rotate to right')
            rotate(RIGHT)
        elseif(_GET.rotate == "VALUE")then
            print('Rotate: '.. _GET.value)
            rotate(_GET.value)
        elseif(_GET.rotate == "RESET")then
              node.restart();
        end
        
        -- Close session
        local response = "HTTP/1.1 200 OK\r\n\r\nOK"
        conn:send(response, function()
            conn:close()
        end)
        collectgarbage();
    end)
end)
