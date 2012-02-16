class egg.Set
  
  constructor: ->
    @items = {}
  
  add: (item)->
    throw "Can't add #{item.constructor.name} to set without an eggID" unless item.eggID
    @items[item.eggID()] = item

  remove: (item)->
    delete @items[item.eggID()]

  count: ->
    i = 0
    i++ for k of @items
    i

  has: (item)->
    item.eggID && (item.eggID() of @items)