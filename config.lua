-- Map the GPIO pin number to a MQTT topic
map = {}
map[1] = "zone1"
map[2] = "zone2"
map[5] = "zone3"
map[6] = "zone4"
map[7] = "zone5"

-- MQTT config
topic_prefix = "house/sensors/"

-- Map MQTT value payloads
payload = {}
payload[0] = "closed"
payload[1] = "open"
