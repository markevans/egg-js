class egg.Scope extends egg.Base

  @init (opts={})->
    @sorter = opts.sorter
    @filter = opts.filter || -> true
    @parent = opts.parent
    throw("Scope needs a parent") unless @parent
    
    @_instances = new egg.Set
    @_populateInstances()

    # Events
    @subs = []
    @subs.push @parent.on 'add', (params) =>
      @_add(params.instance) if @filter(params.instance)
      
    @subs.push @parent.on 'change', (params) =>
      instance = params.instance
      if @filter(instance)
        if @has(instance)
          @emit 'change', params
        else
          @_add(instance)
      else
        if @has(instance)
          @_remove(instance)
      
    @subs.push @parent.on 'remove', (params) =>
      @_remove(params.instance) if @has(params.instance)

  @destroy ->
    sub.cancel() for sub in @subs

  instances: -> @_instances

  _populateInstances: ->
    @parent.instances().forEach (instance)=>
      @instances().add instance if @filter(instance)

  _add: (instance)->
    @emit 'add', instance: instance if @instances().add instance

  _remove: (instance)->
    @emit 'remove', instance: instance if @instances().remove instance

  @delegateTo 'instances', [
    'has'
    'toArray'
    'count'
    'forEach'
    'one'
    'pluck'
    'sample'
    'toJSON'
  ]

  # orderBy: (attr)->
  #   sorter = (a, b)-> if a.get(attr) > b.get(attr) then 1 else -1
  #   TODO
