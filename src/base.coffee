eggIDCounter = 0

class egg.Base

  @include: (obj)->
    Object.extend @::, obj

  @extend: (obj)->
    Object.extend @, obj
  
  @use: (plugin, args...)->
    plugin(@, args...)
  
  @use egg.Events

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

  @create: (opts={})->
    new @(opts)

  @init: (callback)->
    @on 'init', (params)->
      callback.call(params.instance, params.opts)

  @destroy: (callback)->
    @on 'destroy', (params)->
      callback.call(params.instance, params.opts)

  constructor: (opts={})->
    @emit('init', opts: opts, instance: @)

  destroy: (opts={})->
    @emit('destroy', opts: opts, instance: @)

  className: ->
    @constructor.name

  @eggID: ->
    @name

  eggID: ->
    @_eggID ?= "#{@constructor.name}-#{eggIDCounter++}"
