class egg.Set
  
  constructor: ->
    @items = {}
  
  add: (item)->
    throw "Can't add #{item.constructor.name} to set without an eggID" unless item.eggID
    id = item.eggID()
    unless @items[id]
      @items[id] = item

  remove: (item)->
    id = item.eggID()
    if @items[id]
      delete @items[id]

  count: ->
    i = 0
    i++ for k of @items
    i

  has: (item)->
    item.eggID && (item.eggID() of @items)
  
  toArray: ->
    array = []
    array.push v for k, v of @items
    array
  
  takeOne: ->
    return v for k, v of @items