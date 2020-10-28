local function settings(sck)
    sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-type: text/html\r\n\r\n")
    sck:send("<!DOCTYPE html><html lang=\"en\"><head><link rel=\"stylesheet\" href=\"style.css\"><meta charset=\"UTF-8\"><title>Monitor</title></head><body>")
    sck:send("<a href=\"/\">Показания</a><a class=\"active\" href=\"/settings\">Настойки</a>")
    sck:send("<p class=\"set\">Имя сети ESP:</p><a class=\"set\" href=\"/settings/apname\">"..set.ap_ssid.."</a><p class=\"set\">Пароль сети ESP:</p><a class=\"set\" href=\"/settings/appass\">"..set.ap_pass.."</a>")
    sck:send("<p class=\"set\">Имя сети роутера:</p><a class=\"set\" href=\"/settings/staname\">"..set.sta_ssid.."</a><p class=\"set\">Пароль сети роутера:</p><a class=\"set\" href=\"/settings/stapass\">"..set.sta_pass.."</a>")
    sck:send("<p class=\"set\">Логин доступа к настройкам:</p><a class=\"set\" href=\"/settings/admlogin\">"..set.admin_login.."</a>")
    sck:send("<p class=\"set\">Пароль доступа к настройкам:</p><a class=\"set\" href=\"/settings/admpass\">"..set.admin_pass.."</a>")
    sck:send("<p class=\"set\">Температура предупреждения:</p><a class=\"set\" href=\"/settings/altemp\">"..set.alarm_temp.."</a>")
    sck:send("<p class=\"set\">Шаг температуры предупреждения:</p><a class=\"set\" href=\"/settings/alstep\">"..set.alarm_step.."</a>")
    sck:send("<p class=\"set\">Запрос 1:</p><a class=\"set\" href=\"/settings/sendreq1\">"..set.send_request_1.."</a>")
    sck:send("<p class=\"set\">Запрос 2:</p><a class=\"set\" href=\"/settings/sendreq2\">"..set.send_request_2.."</a>")
    sck:send("<p class=\"set\">Запрос 2:</p><a class=\"set\" href=\"/settings/sendreq2\">"..set.send_request_3.."</a>")
    sck:send("<p class=\"set\">Доп параметр:</p><a class=\"set\" href=\"/settings/sendreq3\">"..set.send_request_4.."</a></body></html>")
end

local function index(sck)
    sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-type: text/html\r\n\r\n")
    sck:send("<!DOCTYPE html><html lang=\"en\"><head><link rel=\"stylesheet\" href=\"style.css\"><meta charset=\"UTF-8\"><title>Monitor</title></head><body>")
    sck:send("<a class=\"active\" href=\"/\">Показания</a><a href=\"settings\">Настойки</a><p>Temp 1: ")
    sck:send(string.format("%2.1f", t0).."</p><p>Temp 2: ")
    sck:send(string.format("%2.1f", t1).."</p></body></html>")
end

local function back(sck)
    sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-type: text/html\r\n\r\n")
    sck:send("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"><script type=\"text/javascript\">")
    sck:send("window.location.href = \"/settings\"</script><title>Monitor</title>")
    sck:send("<meta http-equiv=\"refresh\" content=\"1\"; url=\"/settings\"></head><body>OK!</body></html>")
end

M = {
    settings = settings,
    index = index,
    back = back,
}

return M
