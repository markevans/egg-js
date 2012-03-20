class egg.View extends egg.Base
  
  # Class methods
  
  @onDOM: (selector, domEvent, eventName, paramsFunc)->
    @delegatedEvents()["#{domEvent}-#{selector}"] =
      domEvent: domEvent
      selector: selector
      eventName: eventName
      paramsFunc: paramsFunc

  @delegatedEvents: ->
    @_delegatedEvents ?= {}

  @onModel: (eventName, callback)->
    @modelSubscriptionSpecs()[eventName] =
      eventName: eventName
      callback: callback

  @modelSubscriptionSpecs: ->
    @_modelSubscriptionSpecs ?= {}

  # init and destroy
  
  constructor: (opts)->
    @elem = if opts.elem then $(opts.elem)[0] else throw("Missing elem!")
    @model = opts.model
    @delegateEvents()
    @subscribeToModel() if @model
    @setClassName()
    super

  destroy: (opts)->
    @unsetClassName()
    @unsubscribeToModel() if @model
    @undelegateEvents()
    super

  # Instance methods
  
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
          params = {model: @model}
          Object.extend(params, e.data.paramsFunc.call(@, e)) if e.data.paramsFunc
          @emit(e.data.eventName, params)
          e.stopPropagation()
          e.preventDefault()

  undelegateEvents: ->
    @delegatedEventsEnabled = false

  subscribeToModel: ->
    for key, s of @constructor.modelSubscriptionSpecs()
      f = ->
        cb = s.callback
        callback = if typeof cb == 'string'
          (args...) => @[cb](args...)
        else
          (args...) => cb.apply(@, args)
        @modelSubscriptions().push @model.on(s.eventName, callback)
      f.call(@)

  unsubscribeToModel: ->
    sub.cancel() for sub in @modelSubscriptions()

  modelSubscriptions: ->
    @_modelSubscriptions ?= []

  setClassName: ->
    if @constructor.className
      $(@elem).addClass(@constructor.className)

  unsetClassName: ->
    if @constructor.className
      $(@elem).removeClass(@constructor.className)
