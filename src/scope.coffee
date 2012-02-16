class egg.Scope extends egg.Base

  @use egg.Events

  @init (opts={})->
    @sorter = opts.sorter
    @filter = opts.filter || -> true
    @modelClass = opts.modelClass
    throw("Scope needs a modelClass") unless @modelClass
    
    @instances = {}
    @_populateInstances()

    # Events
    @subs = []
    @subs.push @modelClass.on 'init', (params) =>
      @_add(params.instance) if @filter(params.instance)
      
    @subs.push @modelClass.on 'change', (params) =>
      model = params.instance
      
      if @filter(model)
        if @has(model)
          @emit 'change', params
        else
          @_add(model)
      else
        if @has(model)
          @_remove(model)
      
    @subs.push @modelClass.on 'destroy', (params) =>
      @_remove(params.instance) if @has(params.instance)

  @destroy ->
    sub.cancel() for sub in @subs

  _populateInstances: ->
    for id, model of @modelClass.instances
      @instances[id] = model if @filter(model)

  _add: (model)->
    @instances[model.id] = model
    @emit 'add', instance: model

  _remove: (model)->
    delete @instances[model.id]
    @emit 'remove', instance: model

  has: (model)->
    @instances[model.id]

  forEach: (callback)->
    callback(model) for model in @toArray()

  toArray: ->
    array = []
    for id, model of @instances
      array.push model
    array.sort(@sorter) if @sorter
    array

  orderBy: (attr)->
    sorter = (a, b)-> if a.get(attr) > b.get(attr) then 1 else -1
    @constructor.create(modelClass: @modelClass, sorter: sorter, filter: @filter)
  
  indexOf: (i)->
    @toArray().indexOf(i)

  first: ->
    @toArray()[0]

  last: ->
    array = @toArray()
    array[array.length-1]

  pluck: (attr)->
    @toArray().map (model) -> model.get(attr)

  sample: (attr)->
    array = @toArray()
    index = Math.floor(Math.random() * array.length)
    model = array[index]
    if attr then model.get(attr) else model

  count: ->
    @toArray().length

  toJSON: ->
    array = []
    @forEach (model) ->
      array.push model.toJSON()
    array
