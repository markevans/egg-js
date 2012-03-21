instanceMethods =

  emit: (name, params)->
    egg.publisher.emit(name, params, @)

  on: (args...)->
    unless @hasSubscribers
      @_onFirstSubscribeCallback?()
      @hasSubscribers = true
    if args.length == 1
      for name, callback of args[0]
        egg.publisher.on(name, callback, null, @)
    else
      [name, callback, filter] = args
      egg.publisher.on(name, callback, filter, @)

  onFirstSubscribe: (callback)->
    @_onFirstSubscribeCallback = callback

  silently: (callback)->
    egg.silently(callback, @)

egg.Events = (klass)->
  klass.include(instanceMethods)
  klass.extend(instanceMethods)
