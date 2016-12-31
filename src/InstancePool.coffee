
emptyFunction = require "emptyFunction"
assertType = require "assertType"
Type = require "Type"

InstancePool = do ->

  type = Type "InstancePool"

  type.defineOptions
    size: Number.withDefault Infinity
    onRetain: Function.withDefault emptyFunction
    onRelease: Function.withDefault emptyFunction

  type.defineValues (options) ->

    # The maximum size of `_pool`
    _size: options.size

    # Reuses an instance from the pool, applying an `options` object
    _onRetain: options.onRetain

    # Cleans an instance that will be reused
    _onRelease: options.onRelease

    # The array of available instances
    _instances: []

  type.defineMethods

    retain: (constructor, options) ->
      if count = @_instances.length
        instance = @_instances.pop()
        @_onRetain.call instance, options
        return instance
      return constructor options

    release: (instance) ->
      if @_instances.length < @_size
        @_onRelease.call instance
        @_instances.push instance
      return

  return type.build()

module.exports = (type, config) ->
  assertType config, Object

  instancePool = InstancePool
    size: config.size
    onRetain: config.onRetain
    onRelease: config.onRelease

  assertType config.createInstance, Function.Maybe
  unless constructor = config.createInstance
    type.didBuild (createInstance) ->
      constructor = createInstance

  type.defineMethods
    release: ->
      instancePool.release this

  type.defineStatics
    retain: (options = {}) ->
      instancePool.retain constructor, options
