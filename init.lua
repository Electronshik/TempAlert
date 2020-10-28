--init.lua
print("Init...")
tmr.delay(300000)
print(node.heap())
set_index = {"ap_ssid","ap_pass","sta_ssid","sta_pass","admin_login","admin_pass","alarm_temp","alarm_step","send_request_1","send_request_2","send_request_3","send_request_4"}
set_req = {"apname","appass","staname","stapass","admlogin","admpass","altemp","alstep","sendreq1","sendreq2","sendreq3","sendreq3"}
set = {
    ap_ssid = "Esp8266-"..node.chipid(),
    ap_pass = "***",
    sta_ssid = "WiFi Name",
    sta_pass = "WiFi Pass",
    admin_login = "***",
    admin_pass = "***",
    alarm_temp = "32",
    alarm_step = "1",
    send_request_1 = "http://maker.ifttt.com/trigger/temp_alert/with/key/***?value1=",
    send_request_2 = "http://maker.ifttt.com/trigger/temp_ok/with/key/***?value1=",
    send_request_3 = "http://maker.ifttt.com/trigger/temp_err/with/key/***?value1=",
    send_request_4 = "&value2=",
    }

resetted = false

temp = {
    delayed = false,
    addr_1 = 0,
    addr_2 = 0,
    pin_1 = 5,
    pin_2 = 1,
    display_count = 0,
    thr = -99,
    alert_was_flag = false,
    error_flag = false,
}
t0 = -99
t1 = -99

local lcd = dofile("lcd.lua")
lcd.cls()
lcd.home()
lcd.cursor(0)
lcd.lcdprint("Hello!", 1, 2)

--button
gpio.mode(7, gpio.INPUT, gpio.PULLUP)
--default settings button
gpio.mode(6, gpio.INPUT, gpio.PULLUP)

--require("settings")
    if gpio.read(6) == 0 then
        dofile("settings.lua").sets_write()
        print("Default settings is written!")
        resetted = true
        lcd.lcdprint("Defaults written", 1, 0)
    end
dofile("settings.lua").sets_read()
--    dofile("settings.lua").sets_write()
    --print(set[set_index[1]])
    --print(set[set_index[2]])
    
if gpio.read(7) == 1 and resetted == false then
    print("Station mode")
    station_cfg={}
    station_cfg.ssid = set.sta_ssid
    station_cfg.pwd = set.sta_pass
    wifi.sta.config(station_cfg)
    print("Setting up WIFI...")
    lcd.cls()
    lcd.lcdprint("Connecting...", 1, 0)
    gpio.write(8, gpio.HIGH)
    wifi.setmode(wifi.STATION)
    --modify according your wireless router settings
    --wifi.sta.config(set.sta_ssid, set.sta_pass)
    wifi.sta.connect()
    tmr.alarm(1, 2000, 1,
    function()
        if wifi.sta.getip()== nil then 
            print("IP unavaiable, Waiting...")
            lcd.cls()
            lcd.lcdprint("IP unavaiable...", 1, 0)
            lcd.lcdprint("Waiting...", 2, 0)
        else 
            tmr.stop(1)
            print("Config done, IP is "..wifi.sta.getip())
            lcd.cls()
            lcd.lcdprint("Done   IP is:", 1, 0)
            lcd.lcdprint(wifi.sta.getip(), 2, 0)
        
            l = file.list();
            for k,v in pairs(l) do
              print("name:"..k..", size:"..v)
            end
            lcd = nil
        
    -- Use the nodemcu specific pool servers
        -- Set time to 2017 Jan 11, 00:00:00
            rtctime.set(1484092800, 0)
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
            print("Time: "..rtctime.get())
            dofile("monitor.lua")
        end 
    end)
else
    print("Ap mode")
    l = file.list();
    for k,v in pairs(l) do
      print("name:"..k..", size:"..v)
    end
    
    wifi.setmode(wifi.STATIONAP)
    wfconfig = {}
    wfconfig.ssid = set.ap_ssid
    wfconfig.pwd = set.ap_pass
    wifi.ap.config(wfconfig)
    print(wifi.ap.getip())
    lcd.lcdprint(wifi.ap.getip(), 2, 0)
    lcd = nil
    print(node.heap())
    dofile("server.lua")
end
