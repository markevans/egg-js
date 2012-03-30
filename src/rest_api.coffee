class egg.RestApi extends egg.Base

  commonAjaxOpts:
    dataType: 'json'

  @init (opts)->
    @commonAjaxOpts = Object.extend({
      headers: opts.headers
    }, @commonAjaxOpts)

  # Model related methods

  load: (klass, opts={})->
    url = opts.url || klass.url()
    @get url, opts.params, (data)->
      models = []
      models.push klass.load(attrs: attrs) for attrs in data
    , 'load'

  save: (model, opts={})->
    if model.isPersisted()
      @update(model, opts)
    else
      @create(model, opts)

  sync: (model, opts={})->
    url    = opts.url    || model.syncUrl?()    || model.url?()   || throw("#{model.className()} needs a syncUrl or url method")
    params = opts.params || model.syncParams?() || model.params?()
    
    @get url, params, (data)->
      model.set data
    , 'sync'

  create: (model, opts={})->
    url    = opts.url    || model.createUrl?()    || model.url?() || throw("#{model.className()} needs a createUrl or url method")
    params = opts.params || model.createParams?() || model.params?()

    @post url, params, (data)->
      model.set data
    , 'create'

  update: (model, opts={})->
    url    = opts.url    || model.updateUrl?()    || model.url?() || throw("#{model.className()} needs an updateUrl or url method")
    params = opts.params || model.updateParams?() || model.params?()

    @put url, params, (data)->
      model.set data
    , 'update'

  destroy: (model, opts={})->
    url    = opts.url    || model.destroyUrl?()    || model.url?()   || throw("#{model.className()} needs a destroyUrl or url method")
    params = opts.params || model.destroyParams?() || model.params?()

    @delete url, params, null, 'destroy'

  # Http related methods
  
  get: (url, params, callback, eventPrefix='get')->
    @_ajax url, {type: 'GET', data: params}, callback, eventPrefix

  post: (url, params, callback, eventPrefix='post')->
    @_ajax url, {type: 'POST', data: params}, callback, eventPrefix

  put: (url, params, callback, eventPrefix='put')->
    @_ajax url, {type: 'PUT', data: params}, callback, eventPrefix

  delete: (url, params, callback, eventPrefix='delete')->
    @_ajax url, {type: 'DELETE', data: params}, callback, eventPrefix

  _ajax: (url, opts={}, successCallback, eventPrefix='request')->
    deferred = $.Deferred()
    
    $.ajax(url, Object.extend({}, opts, @commonAjaxOpts))
      .done (data) =>
        successCallback(data) if successCallback
        deferred.resolve(data: data)
        @emit("#{eventPrefix}:success", data: data)
        @emit("request:success", type: eventPrefix, data: data)
      .fail (jqXhr, status, errors) =>
        deferred.reject(status: status, errors: errors)
        @emit("#{eventPrefix}:error", status: status, errors: errors)
        @emit("request:error", type: eventPrefix, status: status, errors: errors)
    
    deferred.promise()
