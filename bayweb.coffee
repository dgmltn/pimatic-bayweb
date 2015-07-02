module.exports = (env) ->

  Promise = env.require 'bluebird'

  Thermostat = require "bayweb"

  class BayWeb extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("BayWebThermostat", {
        configDef: deviceConfigDef.BayWebThermostat,
        createCallback: (config) => new BayWebThermostat(config)
      })

  ###
  TODO: read/write:
  stat.activity;         // string 'occupied', 'away 1', 'away 2', or 'sleep'
  stat.mode;             // string 'off', 'heat', or 'cool'
  stat.hold;             // boolean true to hold temperature
  stat.fan;              // string 'auto' or 'on'
  stat.setPoint;         // integer value of the desired temperature set point
  ###

  class BayWebThermostat extends env.devices.Device
    attributes:
      insideTemp:
        description: 'Indoor temperature'
        type: 'number'
        unit: '°F'
        acronym: 'IAT'
      insideHum:
        description: 'Indoor humidity'
        type: 'number'
        unit: '%'
        acronym: 'IAH'
      activitySetPoint:
        description: 'Set Point of current activity'
        type: 'number'
        unit: '°F'
        acronym: 'ASP'
      outsideTemp:
        description: 'Outdoor temperature'
        type: 'number'
        unit: '°F'
        acronym: 'OAT'
      outsideHum:
        description: 'Outdoor humidity'
        type: 'number'
        unit: '%'
        acronym: 'OAH'
      windMph:
        description: 'Wind speed'
        type: 'number'
        unit: 'mph'
        acronym: 'wind'
      solarIndex:
        description: 'Solar index'
        type: 'number'
        acronym: 'SOL'

      activity:
        description: 'Current activity: occupied, away 1, away 2, or sleep'
        type: 'string'
        acronym: 'ACT'
      mode:
        description: 'Current mode: off, heat, or cool'
        type: 'string'
        acronym: 'MODE'
      hold:
        description: 'Flag to hold current temperature'
        type: 'boolean'
        acronym: 'HOLD'
      fan:
        description: 'State of fan: auto or on'
        type: 'string'
        acronym: 'FAN'
      setPoint:
        description: 'Desired set point'
        type: 'number'
        unit: '°F'
        acronym: 'SP'

    insideTemp: null
    insideHum: null
    activitySetPoint: null
    outsideTemp: null
    outsideHum: null
    windMph: null
    solarIndex: null

    activity: null
    mode: null
    hold: null
    fan: null
    setPoint: null

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      @deviceId = config.device_id
      @apiKey = config.api_key
      @timeout = config.timeout
      @thermostat = new Thermostat @deviceId, @apiKey
      super()
      @requestData()

    requestData: () =>
      fetch = Promise.promisify(@thermostat.fetch, @thermostat)
      request = fetch()
      .then( =>
        @_setAttribute "insideTemp", @thermostat.data.insideTemp
        @_setAttribute "insideHum", @thermostat.data.insideHum
        @_setAttribute "activitySetPoint", @thermostat.data.activitySetPoint
        @_setAttribute "outsideTemp", @thermostat.data.outsideTemp
        @_setAttribute "outsideHum", @thermostat.data.outsideHum
        @_setAttribute "windMph", @thermostat.data.windMph
        @_setAttribute "solarIndex", @thermostat.data.solarIndex
        @_setAttribute "activity", @thermostat.activity
        @_setAttribute "mode", @thermostat.mode
        @_setAttribute "hold", @thermostat.hold
        @_setAttribute "fan", @thermostat.fan
        @_setAttribute "setPoint", @thermostat.setPoint
        console.log("thermostat: " + JSON.stringify(@thermostat))
        console.log("inside temp: " + @thermostat.data.insideTemp)
        console.log("activity: " + @thermostat.activity)
        @_currentRequest = Promise.resolve()
        setTimeout(@requestForecast, @timeout)
      )
      .catch( (err) =>
        env.logger.error(err.message)
        env.logger.debug(err.stack)
        setTimeout(@requestForecast, @timeout)
      )
      request.done()
      @_currentRequest = request unless @_currentRequest?
      return request

    _setAttribute: (attributeName, value) ->
      unless @[attributeName] is value
        @[attributeName] = value
        @emit attributeName, value

    getInsideTemp: -> @_currentRequest.then(=> @insideTemp )
    getInsideHum: -> @_currentRequest.then(=> @insideHum )
    getActivitySetPoint: -> @_currentRequest.then(=> @activitySetPoint )
    getOutsideTemp: -> @_currentRequest.then(=> @outsideTemp )
    getOutsideHum: -> @_currentRequest.then(=> @outsideHum )
    getWindMph: -> @_currentRequest.then(=> @windMph )
    getSolarIndex: -> @_currentRequest.then(=> @solarIndex )
    getActivity: -> @_currentRequest.then(=> @activity )
    getMode: -> @_currentRequest.then(=> @mode )
    getHold: -> @_currentRequest.then(=> @hold )
    getFan: -> @_currentRequest.then(=> @fan )
    getSetPoint: -> @_currentRequest.then(=> @setPoint )

  plugin = new BayWeb
  return plugin
