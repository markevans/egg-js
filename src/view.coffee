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
          params = Object.extend({}, @presentedObjects)
          params.arg = e.data.paramsFunc.call(@, e) if e.data.paramsFunc
          @emit(e.data.eventName, params)

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
