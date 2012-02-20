class egg.Set
  
  constructor: (opts={})->
    @items = {}
    if opts.items
      @items[item.eggID()] = item for item in opts.items
    @sorter = opts.sorter
  
  add: (item)->
    id = item.eggID()
    unless @items[id]
      @items[id] = item
      delete @array

  remove: (item)->
    id = item.eggID()
    if @items[id]
      delete @items[id]
      delete @array

  count: ->
    @toArray().length

  has: (item)->
    item.eggID && (item.eggID() of @items)

  filter: (callback)->
    set = new @constructor
    @forEach (item) => set.add item if callback(item)
    set

  asc: (attr)->
    new @constructor items: @toArray(), sorter: (a, b) ->
      if a.get(attr) > b.get(attr) then 1 else -1

  desc: (attr)->
    new @constructor items: @toArray(), sorter: (a, b) ->
      if a.get(attr) < b.get(attr) then 1 else -1

  toArray: ->
    return @array if @array
    array = []
    array.push v for k, v of @items
    @array = if @sorter then array.sort(@sorter) else array

  forEach: (callback)->
    array = @toArray()
    callback(item, i, array) for item, i in @toArray()

  first: ->
    @toArray()[0]

  pluck: (attr)->
    array = []
    array.push model.get(attr) for model in @toArray()

  sample: (attr)->
    array = @toArray()
    index = Math.floor(Math.random() * array.length)
    model = array[index]
    if attr then model.get(attr) else model

  toJSON: ->
    array = []
    @forEach (model) ->
      array.push model.toJSON()
    array
