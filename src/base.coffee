eggIDCounter = 0

delegate = (object, ownMethod, methods)->
  for method in methods
    (->
      meth = method
      object[meth] = (args...)->
        @[ownMethod]()[meth](args...)
    )()

class egg.Base

  ### Class methods ###
  
  @include: (obj)->
    Object.extend @::, obj

  @extend: (obj)->
    Object.extend @, obj
  
  @use: (plugin, args...)->
    (@classInstanceVars().plugins ?= []).push plugin
    plugin(@, args...)
  
  @uses: (plugin)->
    plugins = @classInstanceVars().plugins
    res = !!plugins && plugins.indexOf(plugin) != -1
    res
  
  @sub: (name, definition)->
    throw("invalid class name '#{name}'") unless name.match(/^[A-Z]\w+$/)
    eval("var childClass = function #{name}(){ #{name}.__super__.constructor.apply(this, arguments) }")
    childClass extends @
    definition.call(childClass, childClass) if definition
    childClass

  @parentClass: ->
    @__super__?.constructor

  @allClassInstanceVars = {}
  
  @classInstanceVars: ->
    @allClassInstanceVars[@name] ?= {}
  
  @ancestors: ->
    @classInstanceVars().ancestors ?= (
      parent = @parentClass()
      if parent
        [@].concat parent.ancestors()
      else
        [@]
    )
  
  @delegateInstanceMethodsTo: (ownMethod, methods)->
    delegate(@::, ownMethod, methods)

  @delegateTo: (ownMethod, methods)->
    delegate(@, ownMethod, methods)

  @create: (opts={})->
    new @(opts)

  @init: (callback)->
    @on 'init', (params)->
      callback.call(params.instance, params.opts)

  @destroy: (callback)->
    @on 'destroy', (params)->
      callback.call(params.instance, params.opts)

  @eggID: ->
    @name

  ### Instance methods ###

  constructor: (opts={})->
    @emit('init', opts: opts, instance: @)

  destroy: (opts={})->
    @emit('destroy', opts: opts, instance: @)

  className: ->
    @constructor.name

  eggID: ->
    @_eggID ?= "#{@constructor.name}-#{eggIDCounter++}"

  subscriptions: ->
    @_subscriptions ?= []

  subscribe: (object, args...)->
    @subscriptions().push object.on(args...)

  ### Use some modules ###

  @use egg.Events
  
  @destroy ->
    sub.cancel() for sub in @subscriptions()
