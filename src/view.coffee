egg.view = (klass)->

  klass.extend
    onDOM: (selector, domEvent, eventName, paramsFunc)->
      @delegatedEvents()["#{domEvent}-#{selector}"] =
        domEvent: domEvent
        selector: selector
        eventName: eventName
        paramsFunc: paramsFunc
  
    delegatedEvents: ->
      @_delegatedEvents ?= {}

    onObj: (eventName, callback)->
      @objectSubscriptionSpecs()[eventName] =
        eventName: eventName
        callback: callback
  
    objectSubscriptionSpecs: ->
      @_objectSubscriptionSpecs ?= {}

  klass.init (opts)->
    @elem = if opts.elem then $(opts.elem)[0] else throw("Missing elem!")
    @obj = opts.obj
    @delegateEvents()
    @subscribeToObj() if @obj
    @setClassName()

  klass.destroy (opts)->
    @unsetClassName()
    @unsubscribeToObj() if @obj
    @undelegateEvents()

  klass.include

    $: (selector)->
      $(@elem).find(selector)

    destroyWithElem: ->
      @destroy()
      $(@elem).remove()

    delegateEvents: ->
      @delegatedEventsEnabled = true
      for key, d of @constructor.delegatedEvents()
        $(@elem).on d.domEvent, d.selector, d, (e) =>
          if @delegatedEventsEnabled
            params = {obj: @obj}
            Object.extend(params, e.data.paramsFunc.call(@, e)) if e.data.paramsFunc
            @emit(e.data.eventName, params)
            e.stopPropagation()
            e.preventDefault()

    undelegateEvents: ->
      @delegatedEventsEnabled = false

    subscribeToObj: ->
      for key, s of @constructor.objectSubscriptionSpecs()
        f = ->
          cb = s.callback
          callback = if typeof cb == 'string'
            (args...) => @[cb](args...)
          else
            (args...) => cb.apply(@, args)
          @objectSubscriptions().push @obj.on(s.eventName, callback)
        f.call(@)

    unsubscribeToObj: ->
      sub.cancel() for sub in @objectSubscriptions()

    objectSubscriptions: ->
      @_objectSubscriptions ?= []

    setClassName: ->
      if @constructor.className
        $(@elem).addClass(@constructor.className)

    unsetClassName: ->
      if @constructor.className
        $(@elem).removeClass(@constructor.className)
