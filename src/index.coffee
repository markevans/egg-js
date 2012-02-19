rootKeyFor = (attrNames)->
  attrNames.sort().join('-')

class egg.Index extends egg.Base
  
  @indexes = {}
  
  @for: (modelClass, attrNames)->
    @indexes[modelClass.name]?[rootKeyFor(attrNames)]
  
  @init (opts)->
    @modelClass = opts.modelClass
    @attrNames = opts.attrNames.sort()
    @models = {}
    
    # Add to store of indexes
    @constructor.indexes[@modelClass.name] ?= {}
    @constructor.indexes[@modelClass.name][rootKeyFor(@attrNames)] = @
  
    # Bind to model changes
    @modelClass.on 'add', (params)=>
      @add(params.instance, params.instance.attrs())
    
    @modelClass.on 'change', (params)=>
      @remove(params.instance, params.from)
      @add(params.instance, params.to)

    @modelClass.on 'remove', (params)=>
      @remove(params.instance, params.instance.attrs())

  modelKey: (attrs)->
    values = []
    for key in @attrNames
      values.push attrs[key]
    values.join('-')
  
  find: (attrs)->
    @where(attrs).one()

  where: (attrs)->
    @models[@modelKey(attrs)] ?= new egg.Set

  add: (model, attrs)->
    set = @models[@modelKey(attrs)] ?= new egg.Set
    set.add(model)
  
  remove: (model, attrs)->
    set = @models[@modelKey(attrs)]
    set.remove(model) if set
