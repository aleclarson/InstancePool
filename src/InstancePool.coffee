
emptyFunction = require "emptyFunction"
assertType = require "assertType"
Type = require "Type"

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

InstancePool = do ->

  type = Type "InstancePool"

  type.defineArgs ->

    types:
      size: Number
      onRetain: Function
      onRelease: Function

    defaults:
      size: Infinity
      onRetain: emptyFunction
      onRelease: emptyFunction

  type.defineValues (options) ->

    # The array of available instances
    _instances: []

    # The maximum size of `_instances`
    _size: options.size

    # Reuses an instance from the pool, applying an `options` object
    _onRetain: options.onRetain

    # Cleans an instance that will be reused
    _onRelease: options.onRelease

  type.defineMethods

    # Prepares an instance using the given `options` object.
    # If the pool isnt empty, a recycled instance is returned.
    retain: (constructor, options) ->
      if count = @_instances.length
        instance = @_instances.pop()
        @_onRetain.call instance, options
        return instance
      return constructor options

    # Recycles an old instance (if the pool isnt full).
    release: (instance) ->
      if @_instances.length < @_size
        @_onRelease.call instance
        @_instances.push instance
      return

  return type.build()
