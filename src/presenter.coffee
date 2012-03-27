class egg.Presenter extends egg.Base
  
  @init (opts)->
    @objects = opts.objects || throw("#{@constructor.name} needs an 'objects' option")
    @onFirstSubscribe ->
      for name, item of @objects
        @subscribe item, '*', (params, event) => @emit("#{name}:#{event.name}", params)
  
  @decorate: (className, methodLists...)->
    @decorators()[className] = Object.extend({}, methodLists...)

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
    if @isEnumerable(obj)
      @presentEnumerable(obj)
    else
      @presentObject(obj)
  
  presentObject: (obj)->
    hash = obj.toJSON?() || Object.extend({}, obj)
    decorator = @decoratorFor(obj)
    if decorator
      for key, value of decorator
        hash[key] = (if @isFunction(value) then value.call(obj) else value)
    hash

  presentEnumerable: (obj)->
    json = []
    obj.forEach (item) => json.push @present(item)
    json

  isEnumerable: (obj)->
    !!obj.forEach

  isFunction: (value)->
    typeof value == 'function'