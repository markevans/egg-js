class egg.Model extends egg.Base

  constructor: (opts)->
    @_attrs = opts.attrs || {}
    @constructor.instances().add(@)
    super

  destroy: (opts)->
    @constructor.instances().remove(@)
    super

  # Class methods

  @instances: ->
    vars = @classInstanceVars()
    unless vars.instances
      vars.instances = new egg.Set
      @on 'change', (params) ->
        vars.instances.notifyChanged(params.instance, params.from, params.to)
    vars.instances

  @loadFrom: (storage, opts={})->
    storage.load(@, opts).done (instances) =>
      @emit('load.many', from: storage, instances: instances, opts: opts)

  @load: (opts={})->
    model = @create(opts)
    @emit('load', instance: model)

  @where: (attrs)->
    index = egg.Index.for(@instances(), Object.keys(attrs))
    if index
      index.setFor(attrs)
    else
      @filter (model)->
        for key, value of attrs
          return false if model.get(key) != value
        return true

  @find: (attrs)->
    @where(attrs).first()
  
  @findOrCreate: (attrs)->
    @find(attrs) || @create(attrs: attrs)

  @all: -> @instances()
  
  @destroyAll: ->
    @instances().forEach (model)-> model.destroy()

  @index: (attrNames...)->
    egg.Index.create(parent: @instances(), attrNames: attrNames)

  @delegateTo 'instances', [
    'has'
    'toArray'
    'forEach'
    'first'
    'map'
    'pluck'
    'asc'
    'desc'
    'filter'
    'sample'
    'count'
  ]

  # Instance methods

  get: (attr)->
    @_attrs[attr]

  attrs: (keys...)->
    if keys.length
      Object.slice(@_attrs, keys)
    else
      Object.extend({}, @_attrs)

  set: (args...)->
    from = @attrs()
    if args.length == 1
      for attr, value of args[0]
        @setOne(attr, value)
    else
      [attr, value] = args
      @setOne(attr, value)
    to = @attrs()
    @emit 'change', instance: @, from: from, to: to
  
  setOne: (attr, value)->
    from = @get(attr)
    @_attrs[attr] = value
    @emit "change:#{attr}", instance: @, from: from, to: value

  update: (args...)->
    @set(args...)
    @save()

  save: ->
    @emit('save', instance: @)

  toJSON: ->
    Object.extend {}, @_attrs
