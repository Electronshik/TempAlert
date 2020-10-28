local function sets_read()
    file.open("settings.txt","r")
    for _,key in ipairs(set_index) do
        set[key] = string.gsub(file.readline(),"\n", "")
    end
    file.close()
    collectgarbage()
end

local function sets_write()
    file.open("settings.txt","w")
    for _, key in ipairs(set_index) do
        file.writeline(set[key])
    end
    file.close()
    collectgarbage()
end
M = {
sets_read = sets_read,
sets_write = sets_write }
return M