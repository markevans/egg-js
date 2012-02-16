uidCounter = 0

egg.model = (klass)->

  klass.init (opts)->
    @_attrs = opts.attrs || {}
    @id = uidCounter++
    klass.instances[@id] = @

  klass.destroy (opts)->
    delete klass.instances[@id]

  klass.extend

    instances: {} # TODO: worry about inheritance

    loadFrom: (storage, opts={})->
      storage.load(@, opts).done (instances) =>
        @emit('load', from: storage, instances: instances, opts: opts)

    where: (attrs)->
      egg.Scope.create(
        modelClass: @
        filter: (model)->
          for key, value of attrs
            return false if model.get(key) != value
          return true
      )

    find: (attrs)->
      index = egg.ModelIndex.for(@, Object.keys(attrs))
      if index
        index.find(attrs)
      else
        @where(attrs).first()
    
    findOrCreate: (attrs)->
      @find(attrs) || @create(attrs: attrs)

    all: -> @classInstanceVars().all ?= egg.Scope.create(modelClass: @)
    
    destroyAll: ->
      @all().forEach (model)-> model.destroy()

    index: (attrNames...)->
      egg.ModelIndex.create(modelClass: @, attrNames: attrNames)

    count: ->
      @all().count()
    
    sample: (attr)->
      @all().sample(attr)

    orderBy: (attr)->
      @all().orderBy(attr)

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
