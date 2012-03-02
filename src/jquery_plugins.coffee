if @jQuery

  $ = jQuery

  splitOnSquareBrackets = (name)->
    name.replace(/\]$/, '').split(/\]?\[/)

  provide = (object, keys)->
    key = keys[0]
    if key
      object[key] ?= {}
      provide(object[key], keys.slice(1))
    else
      object

  # Return a form's values in the form of an object
  # e.g.
  # <input name="hello" value="there" />
  # <input name="goodbye[please]" value="guys" />
  # becomes
  # {
  #   hello: 'there',
  #   goodbye: {please: 'guys}
  # }
  $.fn.formParams = ->
    params = {}
    for item in @serializeArray()
      nameParts = splitOnSquareBrackets(item.name)
      basename = nameParts.pop()
      provide(params, nameParts)[basename] = item.value
    params
