egg.model = (klass)->

  klass.init (opts)->
    @_attrs = opts.attrs || {}
    klass.instances().add(@)
    klass.emit 'add', instance: @

  klass.destroy (opts)->
    klass.instances().remove(@)
    klass.emit 'remove', instance: @

  klass.extend

    instances: ->
      @classInstanceVars().instances ?= new egg.Set

    loadFrom: (storage, opts={})->
      storage.load(@, opts).done (instances) =>
        @emit('load', from: storage, instances: instances, opts: opts)

    where: (attrs)->
      index = egg.Index.for(@, Object.keys(attrs))
      if index
        index.where(attrs)
      else
        @filter (model)->
          for key, value of attrs
            return false if model.get(key) != value
          return true

    find: (attrs)->
      @where(attrs).first()
    
    findOrCreate: (attrs)->
      @find(attrs) || @create(attrs: attrs)

    all: -> @classInstanceVars().all ?= egg.Scope.create(parent: @)
    
    destroyAll: ->
      @instances().forEach (model)-> model.destroy()

    index: (attrNames...)->
      egg.Index.create(modelClass: @, attrNames: attrNames)

  klass.delegateTo 'instances', [
    'filter'
    'count'
  ]

  klass.include
  
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
      @emit "change.#{attr}", instance: @, from: from, to: value

    update: (args...)->
      @set(args...)
      @save()

    save: ->
      @emit('save', instance: @)

    toJSON: ->
      Object.extend {}, @_attrs
