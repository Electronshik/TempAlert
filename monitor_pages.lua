local function monitor_settings(sck, login, pass)
    sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n")
    sck:send("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\">")
    sck:send("<link rel=\"stylesheet\" href=\"monitor_auth.css\"><meta charset=\"UTF-8\"><title>Monitor</title></head><body>")
    sck:send("<div class=\"temp-container\">")
    sck:send("<form action=\"/auth-settings\" method=\"post\">")
    sck:send("<input type=\"hidden\" name=\"login\" value=\""..login.."\">")
    sck:send("<input type=\"hidden\" name=\"pass\" value=\""..pass.."\">")
    sck:send("<p>Температура предупреждения: &degC</p>")
    sck:send("<input type=\"text\" name=\"temp_alarm\" required value=\""..set.alarm_temp.."\">")
    sck:send("<p>Шаг предупреждения: &degC</p>")
    sck:send("<input type=\"text\" name=\"temp_step\" required value=\""..set.alarm_step.."\">")
    sck:send("<button type=\"submit\">Сохранить</button>")
    sck:send("<p><a href=\"/\" class=\"temp-set\">Назад</a></p>")
    sck:send("<button type=\"submit\" name=\"restart\" value=\"true\">Перезагрузка</button>")
    sck:send("</form></div></body></html>")
end

local function monitor_auth(sck)
    sck:send("HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-type: text/html\r\n\r\n")
    sck:send("<!DOCTYPE html><html lang=\"en\"><head>")
    sck:send("<link rel=\"stylesheet\" href=\"monitor_auth.css\"><meta charset=\"UTF-8\"><title>Monitor</title></head><body>")
    sck:send("<div class=\"temp-container\">")
    sck:send("<form action=\"/auth\" method=\"post\">")
    sck:send("<input type=\"text\" name=\"login\" required>")
    sck:send("<input type=\"password\" name=\"pass\" required>")
    sck:send("<button type=\"submit\">Войти</button>")
    sck:send("</form></div></body></html>")
end

M = {
    monitor_settings = monitor_settings,
    monitor_auth = monitor_auth
}

return M
