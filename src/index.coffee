rootKeyFor = (attrNames)->
  attrNames.sort().join('-')

class egg.Index extends egg.Base
  
  @indexes = {}
  
  @for: (modelClass, attrNames)->
    @indexes[modelClass.name]?[rootKeyFor(attrNames)]
  
  @init (opts)->
    @modelClass = opts.modelClass
    @attrNames = opts.attrNames.sort()
    @sets = {}
    
    # Add to store of indexes
    @constructor.indexes[@modelClass.name] ?= {}
    @constructor.indexes[@modelClass.name][rootKeyFor(@attrNames)] = @
  
    # Bind to model changes
    @modelClass.on 'add', (params)=>
      @setFor(params.instance.attrs()).add(params.instance)
    
    @modelClass.on 'change', (params)=>
      @setFor(params.to).add(params.instance)
      @setFor(params.from).remove(params.instance)

    @modelClass.on 'remove', (params)=>
      @setFor(params.instance.attrs()).remove(params.instance)

  keyFor: (attrs)->
    values = []
    for key in @attrNames
      values.push attrs[key]
    values.join('-')
  
  setFor: (attrs)->
    @sets[@keyFor(attrs)] ?= new egg.Set
