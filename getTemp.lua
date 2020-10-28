-- Measure temperature and post data to thingspeak.com
-- 2014 OK1CDJ
--- Tem sensor DS18B20 is connected to GPIO0
--- 2015.01.21 sza2 temperature value concatenation bug correction

--ow.setup(pin)

function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end

function owInit()

    ow.setup(temp.pin_1)
    local addr = ow.reset_search(temp.pin_1)
    tmr.wdclr()
    repeat
        if (addr ~= nil) then
            local crc = ow.crc8(string.sub(addr,1,7))
            if (crc == addr:byte(8)) then
                if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                    temp.addr_1 = addr
                    print("addr_1: "..addr)
                end
            end
        end
        addr = ow.search(temp.pin_1)
    until(addr == nil)

    ow.setup(temp.pin_2)
    addr = ow.reset_search(temp.pin_2)
    tmr.wdclr()
    repeat
        if (addr ~= nil) then
            local crc = ow.crc8(string.sub(addr,1,7))
            if (crc == addr:byte(8)) then
                if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                    temp.addr_2 = addr
                    print("addr_2: "..addr)
                end
            end
        end
        addr = ow.search(temp.pin_2)
    until(addr == nil)
end

--- Get temperature from DS18B20
function getTemp()
    if temp.delayed == false then
        ow.setup(temp.pin_1)
        if temp.addr_1 ~= 0 then
                    ow.reset(temp.pin_1)
                    ow.select(temp.pin_1, temp.addr_1)
                    ow.write(temp.pin_1, 0x44, 0)
        end
    
        ow.setup(temp.pin_2)
        if temp.addr_2 ~= 0 then
                    ow.reset(temp.pin_2)
                    ow.select(temp.pin_2, temp.addr_2)
                    ow.write(temp.pin_2, 0x44, 0)
        end

        temp.delayed = true
    else
--        tmr.delay(750000)
        t0 = -99
        t1 = -99
        if temp.addr_1 ~= 0 then
            local data = nil
            present = ow.reset(temp.pin_1)
            ow.select(temp.pin_1, temp.addr_1)
            ow.write(temp.pin_1,0xBE, 1)
            data = string.char(ow.read(temp.pin_1))
            for i = 1, 8 do
                data = data .. string.char(ow.read(temp.pin_1))
            end
            crc = ow.crc8(string.sub(data,1,8))
            if (crc == data:byte(9)) then
                local t = (data:byte(1) + data:byte(2) * 256)
                if (t > 32768) then
                t = (bxor(t, 0xffff)) + 1
                t = (-1) * t
                end
                t = t * 625
                t0 = t
                t0 = t0 / 10000
            end                
            tmr.wdclr()
        end

        if temp.addr_2 ~= 0 then
            local data = nil
            present = ow.reset(temp.pin_2)
            ow.select(temp.pin_2, temp.addr_2)
            ow.write(temp.pin_2,0xBE, 1)
            data = string.char(ow.read(temp.pin_2))
            for i = 1, 8 do
                data = data .. string.char(ow.read(temp.pin_2))
            end
            crc = ow.crc8(string.sub(data,1,8))
            if (crc == data:byte(9)) then
                local t = (data:byte(1) + data:byte(2) * 256)
                if (t > 32768) then
                t = (bxor(t, 0xffff)) + 1
                t = (-1) * t
                end
                t = t * 625
                t1 = t
                t1 = t1 / 10000
            end                
            tmr.wdclr()
        end
        temp.delayed = false
    end
end

if temp.addr_1 == 0 or temp.addr_2 == 0 then
    owInit()
end
getTemp()
if t0 >= tonumber(set.alarm_temp) or t1 >= tonumber(set.alarm_temp) then
    dofile("tempAlert.lua").tempAlert()
else
    if temp.alert_was_flag then
        dofile("tempAlert.lua").tempOk()
    end
end
if (t0 == -99 or t1 == -99) and (temp.delayed == false) then
    if temp.error_flag == false then
        dofile("tempAlert.lua").tempErr()
    end
elseif temp.delayed == false then
    temp.error_flag = false
end
