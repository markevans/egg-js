class egg.Presenter extends egg.Base

  isEnumerable = (obj)->
    !!obj.forEach

  isFunction = (value)->
    typeof value == 'function'

  isObject = (value)->
    typeof value == 'object'

  @init (opts)->
    @objects = opts.objects || {}
    @onFirstSubscribe ->
      for name, item of @objects
        @subscribe item, '*', (params, event) => @emit("#{name}:#{event.name}", params)
  
  @decorate: (className, methodLists...)->
    decorator = {}
    for methodList in methodLists
      if isEnumerable(methodList)
        methodList.forEach (method) ->
          decorator[method] = -> if isFunction(@[method]) then @[method]() else @[method]
      else
        Object.extend decorator, methodList
    @decorators()[className] = decorator

  @decorators: ->
    @classInstanceVars().decorators ?= {}

  decoratorFor: (obj)->
    @constructor.decorators()[obj.constructor.name]

  toJSON: ->
    json = {}
    for name, object of @objects
      json[name] = @present(object)
    json

  present: (obj)->
    if isEnumerable(obj)
      @presentEnumerable(obj)
    else if isObject(obj)
      @presentObject(obj)
    else
      obj

  presentObject: (obj)->
    hash = obj.toJSON?() || Object.extend({}, obj)
    decorator = @decoratorFor(obj)
    if decorator
      for key, value of decorator
        hash[key] = @present(if isFunction(value) then value.call(obj) else value)
    hash

  presentEnumerable: (obj)->
    json = []
    obj.forEach (item) => json.push @present(item)
    json
