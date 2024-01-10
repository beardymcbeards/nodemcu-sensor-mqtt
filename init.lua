--load credentials
dofile("secrets.lua")

function startup()
  if file.open("init.lua") == nil then
    print("init.lua deleted")
  else
    print("Running")
    file.close("init.lua")
    dofile("sensor.lua")
  end
end

--init.lua
print("Connecting to: "..WIFI_CONFIG.ssid)
wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_CONFIG)
wifi.sta.sethostname(HOSTNAME)
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function()
  if wifi.sta.getip()== nil then
    print("Waiting on dhcp...")
  else
    tmr.stop(1)
    print("Wifi connected. IP:"..wifi.sta.getip())
    print("You have 2 seconds to abort startup")
    print("Waiting...")
    tmr.alarm(0, 2000, 0, startup)
  end
end)
