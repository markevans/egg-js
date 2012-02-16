ancestorChain = (obj)->
  if obj.constructor.ancestors then [obj, obj.constructor.ancestors()...] else [obj]

class egg.Subscription
  
  constructor: (eventChannel, callback, filter)->
    @eventChannel = eventChannel
    @callback = callback
    @filter = filter
    @index = eventChannel.length
    @enable()

  enable: ->
    @eventChannel[@index] = @

  cancel: ->
    delete @eventChannel[@index]

class egg.Event
  
  constructor: (name, params, sender)->
    @name = name
    @params = params
    @sender = sender
    @shouldBubble = true
  
  preventBubbling: ->
    @shouldBubble = false

class egg.Publisher

  constructor: ->
    @globalChannel = {}
    @channels = {}
    @silent = false
  
  silently: (callback, context)=>
    @silent = true
    callback.call(context)
    @silent = false
  
  emit: (name, params, sender)=>
    if @silent
      false
    else
      event = new egg.Event(name, params, sender)
      if sender
        for obj in ancestorChain(sender)
          break if !event.shouldBubble
          @runChannelCallbacks(@channels[obj.eventsID()], event)
      @runChannelCallbacks(@globalChannel, event) if event.shouldBubble
      true
    
  on: (name, callback, filter, sender)=>
    channel = if sender
      @channels[sender.eventsID()] ?= {}
    else
      @globalChannel
    channel[name] ?= []
    new egg.Subscription(channel[name], callback, filter)
  
  runChannelCallbacks: (channel, event)->
    if channel
      @runCallbacks(channel[event.name], event)
      @runCallbacks(channel['*'], event)

  runCallbacks: (subscriptions, event)->
    if subscriptions
      for sub in subscriptions
        if sub && (!sub.filter || sub.filter(event))
          sub.callback(event.params, event, sub)

egg.publisher = new egg.Publisher
egg.emit     = egg.publisher.emit
egg.on       = egg.publisher.on
egg.silently = egg.publisher.silently
