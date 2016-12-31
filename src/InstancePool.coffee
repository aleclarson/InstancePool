
emptyFunction = require "emptyFunction"
assertType = require "assertType"
Type = require "Type"

InstancePool = ->

  type = Type "InstancePool"

  type.defineOptions
    minCount: Number.withDefault 0
    maxCount: Number.withDefault Infinity
    destructor: Function.withDefault emptyFunction

  type.defineValues (options) ->

    # The minimum length of `_instances`
    _minCount: options.minCount

    # The maximum length of `_instances`
    _maxCount: options.maxCount

    # Performs clean-up before old instances are added back into `_instances`
    _destructor: options.destructor

    # The array of allocated instances not being used
    _instances: []

  type.defineMethods

    allocate: (constructor, options) ->
      if length = @_instances.length
        instance = @_instances.pop()
        if length <= @_minCount
          instance = constructor options
          @_instances.push instance
        return instance

    release: (instance, args) ->
      if @_instances.length < @_maxCount
        @_destructor.apply instance, args
        @_instances.push instance
      return

  return type.build()

module.exports = (type, config) ->
  assertType config, Object

  instancePool = InstancePool
    minCount: config.minCount
    maxCount: config.maxCount
    destructor: config.destructor

  assertType config.constructor, Function.Maybe
  unless constructor = config.constructor
    type.didBuild (type) ->
      constructor = type

  type.defineMethods
    release: ->
      instancePool.release this, arguments

  type.defineStatics
    allocate: (options) ->
      instancePool.allocate constructor, options
