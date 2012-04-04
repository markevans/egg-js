queryString = (params)->
  parts = []
  for key, value of params
    parts.push("#{encodeURIComponent(key)}=#{encodeURIComponent(value)}")
  parts.join('&')

class Route
  constructor: (@pattern)->
    [@path, @hash] = @pattern.split('#')

  toURL: (params)->
    path = @path
    query = {}
    hash = @hash
    for key, value of params
      token = ':' + key
      if path.match(token)
        path = path.replace(token, value)
      else if hash?.match(token)
        hash = hash.replace(token, value)
      else
        query[key] = value
    url = path
    url += "?#{queryString(query)}" unless Object.isEmpty(query)
    url += "##{hash}" if hash
    url

class egg.Router extends egg.Base

  @init (opts={})->
    @window = opts.window || window
    if opts.routes
      @routes = {}
      @routes[name] = new Route(pattern) for name, pattern of opts.routes
    else
      throw("Router needs a 'routes' option!")

  bookmark: (action, params={})->
    route = @routes[action]
    if route
      @window.history.pushState({}, "", route.toURL(params))
