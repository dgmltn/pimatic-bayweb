module.exports ={
  title: "pimatic-bayweb device config schemas"
  BayWebThermostat: {
    title: "BayWebThermostat config options"
    type: "object"
    properties: 
      device_id:
        description: "Device ID from your BAYweb Cloud EMS account"
        format: "string"
      api_key:
        description: "API Key generated from your BAYweb Cloud EMS account"
        format: "string"
  }
}
