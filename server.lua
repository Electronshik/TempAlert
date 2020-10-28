srv = net.createServer(net.TCP)
srv:listen(80,function(conn) 
    conn:on("receive",function(sck,request) 
        print(request)
        local req = string.sub(request,1,70)
        if string.find(req, "GET ") then
            request = req
            if string.find(request, "/settings ") then
                dofile("pages.lua").settings(sck)
                print(node.heap())
            elseif string.find(request, "/settings/[%w]+ ") then
                local setreq = string.match(request,"/settings/([%S]+)")
                print("setreq: "..setreq)
                local param = nil
                for i,key in ipairs(set_req) do
                    if setreq == key then
                        param = set[set_index[i]]
                    end
                end
                if param then
                    sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-type: text/html\r\n\r\n")
                    sck:send("<!DOCTYPE html><html lang=\"en\"><head><link rel=\"stylesheet\" href=\"style.css\"><meta charset=\"UTF-8\"><title>Monitor</title></head><body>")
                    sck:send("<a href=\"/\">Показания</a><a class=\"active\" href=\"/settings\">Настойки</a><p class=\"set\">Изменить параметр</p><form method=\"post\" action=\"/settings\">")
                    sck:send("<input required name=\"setvalue\" id=\"in\" type=\"text\" value=\""..param.."\"><input type=\"hidden\" name=\"setparam\" value=\""..setreq.."\">")
                    sck:send("<input type=\"submit\"></form></body></html>")
                end
            elseif string.find(request, "/style.css") then
                file.open("style.css", "r")
                sck:send("HTTP/1.1 200 OK\r\nContent-type: text/css\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n")
                sck:send(file.read())
                file.close()
            elseif string.find(request, "GET / HTTP") then
                dofile("pages.lua").index(sck)
            end
        elseif string.find(req, "POST ") then
            local value = ""
            local param = ""
            if string.find(request, "setvalue=") then
                value = string.match(request, "setvalue=([%S]+)&")
                print(value)
            end
            if string.find(request, "setparam") then
                param = string.match(request, "&setparam=([%S]+)")
                print(param)
            end
            print("post is here!")
            for i,key in ipairs(set_req) do
                if param == set_req[i] then
                    set[set_index[i]] = value
                end
            end
            dofile("settings.lua").sets_write()
            dofile("pages.lua").back(sck)
        end
        req = nil
        request = nil
    end) 
    conn:on("sent", function(sk)
        sk:close()
        sk = nil
    end)
end)
tmr.alarm(0, 3000, 1, function() dofile("getTemp.lua") end )
