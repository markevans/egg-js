class egg.View extends egg.Base
  
  # Class methods
  
  @onDOM: (selector, domEvent, handlerMethod, paramsFunc)->
    @delegatedEvents()["#{domEvent}-#{selector}"] =
      domEvent: domEvent
      selector: selector
      handlerMethod: handlerMethod
      paramsFunc: paramsFunc

  @delegatedEvents: ->
    @_delegatedEvents ?= {}

  @listen: (eventName, callback)->
    @presenterSubscriptions()[eventName] =
      eventName: eventName
      callback: callback

  @presenterSubscriptions: ->
    @_presenterSubscriptions ?= {}

  # init and destroy
  
  constructor: (opts)->
    @elem = if opts.elem then $(opts.elem)[0] else throw("Missing elem!")
    @presentedObjects = opts.present
    @_presenter = opts.presenter
    @_handler = opts.handler
    @delegateEvents()
    @subscribeToPresenter()
    @setClassName()
    super

  destroy: (opts)->
    @unsetClassName()
    @undelegateEvents()
    super
  
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
          e.stopPropagation()
          e.preventDefault()
          params = e.data.paramsFunc.call(@, e) if e.data.paramsFunc
          @[e.data.handlerMethod]?(e)                 # Call method on self if it exists
          @handler()?[e.data.handlerMethod]?(params)  # Call method on handler if it exists

  undelegateEvents: ->
    @delegatedEventsEnabled = false

  # classname stuff

  setClassName: ->
    if @constructor.className
      $(@elem).addClass(@constructor.className)

  unsetClassName: ->
    if @constructor.className
      $(@elem).removeClass(@constructor.className)

  # Presenter stuff

  presenter: ->
    @_presenter ?= @presenterClass().create objects: @presentedObjects

  presenterClass: ->
    egg.global[@className().replace(/View$/, 'Presenter')] || egg.Presenter

  subscribeToPresenter: ->
    for key, s of @constructor.presenterSubscriptions()
      f = ->
        cb = s.callback
        callback = if typeof cb == 'string'
          (args...) => @[cb](args...)
        else
          (args...) => cb.apply(@, args)
        @subscribe(@presenter(), s.eventName, callback)
      f.call(@)

  # Handler stuff

  handler: ->
    @_handler ?= @handlerClass()?.create(objects: @presentedObjects)

  handlerClass: ->
    egg.global[@className().replace(/View$/, 'Handler')]
