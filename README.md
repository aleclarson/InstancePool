
# InstancePool v1.0.1 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

```coffee
InstancePool = require "InstancePool"

# Add pooling to your type.
MyType = do ->
  Type = require "Type"

  type = Type()

  type.addMixin InstancePool,
    size: 5
    onRetain: (options) ->
      @foo = options.foo
    onRelease: ->
      @foo = null

  return type.build()


# Retain the first instance.
inst = MyType.retain {foo: 1}

inst.foo # => 1


# Release the instance when you no longer need it.
inst.release()

inst.foo # => null


# Retain an instance when the pool is *NOT* empty.
inst2 = MyType.retain {foo: 2}

inst is inst2 # => true


# Retain an instance when the pool is empty.
inst3 = MyType.retain {foo: 3}

inst2 is inst3 # => false
```

