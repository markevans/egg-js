rootKeyFor = (attrNames)->
  attrNames.sort().join('-')

class egg.Index extends egg.Base
  
  @indexes = {}
  
  @for: (parent, attrNames)->
    @indexes[parent.eggID()]?[rootKeyFor(attrNames)]
  
  @init (opts)->
    @parent = opts.parent
    @attrNames = opts.attrNames.sort()
    @sets = {}
    
    # Add to store of indexes
    @constructor.indexes[@parent.eggID()] ?= {}
    @constructor.indexes[@parent.eggID()][rootKeyFor(@attrNames)] = @
  
    # Bind to model changes
    @parent.on 'add', (params)=>
      @setFor(params.instance.attrs()).add(params.instance)
    
    @parent.on 'change', (params)=>
      oldSet = @setFor(params.from)
      newSet = @setFor(params.to)
      
      if oldSet == newSet
        oldSet.notifyChanged(params.instance, params.from, params.to)
      else
        oldSet.remove(params.instance)
        newSet.add(params.instance)

    @parent.on 'remove', (params)=>
      @setFor(params.instance.attrs()).remove(params.instance)

  keyFor: (attrs)->
    values = []
    for key in @attrNames
      values.push attrs[key]
    values.join('-')
  
  setFor: (attrs)->
    @sets[@keyFor(attrs)] ?= new egg.Set
