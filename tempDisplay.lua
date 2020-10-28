    local lcd = dofile("lcd.lua")
    local tm = rtctime.epoch2cal(rtctime.get())
    print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    if tm["year"] < 2018 then
        sntp.sync(nil,
          function(sec, usec, server, info)
            print('sync', sec, usec, server)
            local timezone = rtctime.get()
            timezone = timezone + 10801
            rtctime.set(timezone, 0)
            local tm = rtctime.epoch2cal(rtctime.get())
            print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])) 
            tm = nil
          end,
          function()
           print('failed!')
          end
        )
    end
    print("Temp_1: "..(t0 > -99 and string.format("%2.1f", t0).." C" or "n/c"))
        lcd.lcdprint("Temp 1: "..(t0 > -99 and string.format("%2.1f", t0).." C     " or "n/c     "), 1, 0)
    print("Temp_2: "..(t1 > -99 and string.format("%2.1f", t1).." C" or "n/c"))
        lcd.lcdprint("Temp 2: "..(t1 > -99 and string.format("%2.1f", t1).." C     " or "n/c     "), 2, 0)
    lcd = nil
    temp.display_count = 0
    tm = nil
