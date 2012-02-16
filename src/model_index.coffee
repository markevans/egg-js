rootKeyFor = (attrNames)->
  attrNames.sort().join('-')

class egg.ModelIndex extends egg.Base
  
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
    @modelClass.on 'init', (params)=>
      @addToIndex(params.instance, params.instance.attrs())
    
    @modelClass.on 'change', (params)=>
      @removeFromIndex(params.instance, params.from)
      @addToIndex(params.instance, params.to)

    @modelClass.on 'destroy', (params)=>
      @removeFromIndex(params.instance, params.instance.attrs())

  modelKey: (attrs)->
    values = []
    for key in @attrNames
      values.push attrs[key]
    values.join('-')
  
  find: (attrs)->
    @models[@modelKey(attrs)]
  
  addToIndex: (model, attrs)->
    @models[@modelKey(attrs)] = model
  
  removeFromIndex: (model, attrs)->
    delete @models[@modelKey(attrs)]
