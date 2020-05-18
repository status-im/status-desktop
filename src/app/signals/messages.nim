import json
import signalSubscriber

proc fromEvent*(event: JsonNode): Signal = 
  result = Message()