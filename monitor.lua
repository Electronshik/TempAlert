-- a simple HTTP server
srv = net.createServer(net.TCP)
srv:listen(80,function(conn) 
    conn:on("receive",function(sck,request) 
        print(request)
        local req = string.sub(request,1,70)
        if string.find(req, "GET ") then
            request = req
            if string.find(request, "GET /auth ") then
                dofile("monitor_pages.lua").monitor_auth(sck)
            elseif string.find(request, "GET /monitor_auth.css") then
                file.open("monitor_auth.css", "r")
                sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-type: text/css\r\n\r\n")
                sck:send(file.read())
                file.close()
            elseif string.find(request, "GET /monitor.css") then
                file.open("monitor.css", "r")
                sck:send("HTTP/1.1 200 OK\r\nContent-type: text/css\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n")
                sck:send(file.read())
                file.close()
            elseif string.find(request, "GET / HTTP") then
            print("other request")
                sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-type: text/html\r\n\r\n")
                sck:send("<!DOCTYPE html><html lang=\"en\"><head>")
                sck:send("<link rel=\"stylesheet\" href=\"monitor.css\"><meta charset=\"UTF-8\"><title>Monitor</title></head><body>")
                sck:send("<div class=\"temp-container\">")
                sck:send("<p class=\"temp-ind\">"..(t0 > -99 and string.format("%2.1f", t0).." &degC" or "n/c").."</p>")
                sck:send("<p class=\"temp-ind\">"..(t1 > -99 and string.format("%2.1f", t1).." &degC" or "n/c").."</p>")
                tm = rtctime.epoch2cal(rtctime.get())
                sck:send("<p class=\"temp-ind alarm\">Температура предупреждения:&nbsp "..set.alarm_temp.." &degC<span class=\"time\">")
                sck:send(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]).."</span></p>")
                sck:send("<p class=\"temp-ind\" style=\"background: none;\"><a href=\"/auth\" class=\"temp-set\">Settings</a></p>")
                print(node.heap())
--                sck:send("</div><script type=\"text/javascript\">setInterval(function() {location.reload();}, 11500);</script></body></html>")
                sck:send("</div></body></html>")
            end
            print(node.heap())
        elseif string.find(req, "POST ") then
            local login = ""
            local pass = ""
            local temp_alarm = false
            local temp_step = false
            local restart = false
            if string.find(request, "login=") then
                login = string.match(request, "login=([^&]+)&")
                print("login = "..login)
            end
            if string.find(request, "&pass=") then
                pass = string.match(request, "&pass=([^&]+)")
                print("pass = "..pass)
            end
            if string.find(request, "&temp_alarm=") then
                temp_alarm = string.match(request, "&temp_alarm=([^&]+)")
                print("temp_alarm = "..temp_alarm)
            end
            if string.find(request, "&temp_step=") then
                temp_step = string.match(request, "&temp_step=([^&]+)")
                print("temp_step = "..temp_step)
            end
            if string.find(request, "&restart=") then
                restart = string.match(request, "&restart=([^&]+)")
                print("restart = "..restart)
            end
            if login == set.admin_login and pass == set.admin_pass then
                if temp_alarm then
                    set.alarm_temp = temp_alarm
                    dofile("settings.lua").sets_write()
                end
                if temp_step then
                    set.alarm_step = temp_step
                    dofile("settings.lua").sets_write()
                end
                if restart == "true" then
                    print("Restart...")
                    sck:close()
                    node.restart()
                end
                dofile("monitor_pages.lua").monitor_settings(sck, login, pass)
            end
        end
        req = nil
        request = nil
    end)
    conn:on("sent", function(sk)
        sk:close()
        sk = nil
    end)
end)
tmr.alarm(0, 1000, 1, function() dofile("getTemp.lua") end )
tmr.alarm(1, 15000, 1, function() dofile("tempDisplay.lua") end)
tmr.alarm(2, 20000, 1, function() dofile("tempAlert.lua") end)
--https://maker.ifttt.com/trigger/temp_alert/with/key/hd0t_bPRoxGVQgvt6ag72U0ae7Nyu11W0fliyM1evjs?value1=54&value2=51
