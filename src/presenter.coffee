class egg.Presenter extends egg.Base
  
  @init (opts)->
    @presentedItems = opts.present || throw("#{@constructor.name} needs a 'present' option")
  
  @decorate: (className, methodLists...)->
    @jsonGenerators()[className] = (obj)->
      Object.extend(obj.toJSON(), methodLists...)

  @jsonFor: (className, jsonGenerator)->
    @jsonGenerators()[className] = jsonGenerator
  
  @jsonGenerators: ->
    @classInstanceVars().jsonGenerators ?= {}

  jsonGeneratorFor: (obj)->
    @constructor.jsonGenerators()[obj.constructor.name]

  toJSON: ->
    json = {}
    for name, item of @presentedItems
      json[name] = @present(item)
    json

  present: (obj)->
    if @isEnumerable(obj)
      @presentEnumerable(obj)
    else
      @presentObject(obj)
  
  presentObject: (obj)->
    @jsonGeneratorFor(obj)?(obj) ||
      obj.toJSON?() ||
      Object.extend({}, obj)

  presentEnumerable: (obj)->
    json = []
    obj.forEach (item) => json.push @present(item)
    json

  isEnumerable: (obj)->
    !!obj.forEach
