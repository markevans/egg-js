eventsIDCounter = 0

instanceMethods =

  emit: (name, params)->
    egg.publisher.emit(name, params, @)

  on: (args...)->
    if args.length == 1
      for name, callback of args[0]
        egg.publisher.on(name, callback, null, @)
    else
      [name, callback, filter] = args
      egg.publisher.on(name, callback, filter, @)

  silently: (callback)->
    egg.silently(callback, @)

  eventsID: ()->
    if @constructor.name == 'Function' && @name.length
      @name
    else
      @_eventsID ?= "#{@constructor.name}-#{eventsIDCounter++}"

egg.Events = (klass)->
  klass.include(instanceMethods)
  klass.extend(instanceMethods)
