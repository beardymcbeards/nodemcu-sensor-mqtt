dofile("config.lua")
state = {}
mqtt_connected = 0

-- init mqtt client
m = mqtt.Client(HOSTNAME, 120)
m:lwt(topic_prefix..HOSTNAME, "offline", 0, 1)

function connect_mqtt()
  m:connect(MQTT_HOST, MQTT_PORT, 0, 0, function(client)
    mqtt_connected = 1
    print(topic_prefix..HOSTNAME.." online")
    m:publish(topic_prefix..HOSTNAME, "online", 0, 1)
    -- mqtt offline handler
    m:on("offline", function(client)
      mqtt_connected = 0
      print(topic_prefix..HOSTNAME.." offline")
    end)
    -- publish initial states
    publish_states()
  end,
  function(client, reason) print("mqtt connect failed: "..reason)
  end)
end

function publish_states()
  for p,v in pairs(map) do
    s = gpio.read(p)
    state[p] = s
    print(topic_prefix..map[p], payload[s])
    m:publish(topic_prefix..map[p], payload[s], 0, 1)
  end
end

-- on gpio interupts compare pin states to last known
function onChange()
  for p,v in pairs(map) do
    s = gpio.read(p)
    if s ~= state[p] then
      state[p] = s
      print(topic_prefix..map[p], payload[s])
      if mqtt_connected == 1 then
        m:publish(topic_prefix..map[p], payload[s], 0, 1)
      end
    end
  end
end

-- setup the gpio pins and triggers
for p,v in pairs(map) do
  gpio.mode(p, gpio.INT, gpio.PULLUP)
  gpio.trig(p, 'both', onChange)
end

-- setup a timer to check the mqtt connection and publish sensor status
tmr.alarm(2, 60000, tmr.ALARM_AUTO, function()
  print("checking mqtt")
  if mqtt_connected == 0 then
    connect_mqtt()
  else
    m:publish(topic_prefix..HOSTNAME, "online", 0, 1)
  end
end)

-- connect now
connect_mqtt()