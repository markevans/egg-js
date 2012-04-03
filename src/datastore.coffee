class egg.Datastore extends egg.Base

  @init (opts)->
    # Store should conform to the same api as localStorage
    @store = opts.store || throw("Need 'store' option in #{@class.name}")

  load: (klass)->
    deferred = $.Deferred()

    models = []
    data = @get(klass)
    if data
      models.push klass.load(attrs: attrs) for attrs in data
    deferred.resolve(models)

    deferred.promise()

  get: (klass)->
    JSON.parse @store.getItem(klass.name)

  save: (klass)->
    @store.setItem(klass.name, JSON.stringify(klass.all().map('attrs')))

  destroy: (klass)->
    @store.removeItem(klass.name)
