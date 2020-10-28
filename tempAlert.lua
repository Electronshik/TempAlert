local function tempAlert ()
    if t0 >= temp.thr or t1 >= temp.thr then
    	http.get(set.send_request_1..(t0 > -99 and string.format("%2.1f", t0) or "N/C")..set.send_request_4..(t1 > -99 and string.format("%2.1f", t1) or "N/C"), nil, function(code, data)
    	    if (code < 0) then
    	      print("HTTP request failed")
    	    else
    	      print(code, data)
              temp.thr = t0
              if temp.thr < t1 then
                temp.thr = t1
              end
              temp.thr = math.floor(temp.thr) + set.alarm_step
              print(temp.thr)
    	    end
    	  end)
        temp.alert_was_flag = true
        print("alert was")
    end
end

local function tempOk ()
    print("temp ok!")
        http.get(set.send_request_2..(t0 > -99 and string.format("%2.1f", t0) or "N/C")..set.send_request_4..(t1 > -99 and string.format("%2.1f", t1) or "N/C"), nil, function(code, data)
            if (code < 0) then
              print("HTTP request failed")
            else
              print(code, data)
              temp.alert_was_flag = false
              temp.thr = -99
            end
          end)
end

local function tempErr ()
    print("temp error!")
        http.get(set.send_request_3..(t0 > -99 and string.format("%2.1f", t0) or "N/C")..set.send_request_4..(t1 > -99 and string.format("%2.1f", t1) or "N/C"), nil, function(code, data)
            if (code < 0) then
              print("HTTP request failed")
            else
              print(code, data)
              temp.error_flag = true
            end
          end)
end

M = {
    tempAlert = tempAlert,
    tempOk = tempOk,
    tempErr = tempErr
}
return M
