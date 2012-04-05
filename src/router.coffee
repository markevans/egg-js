class Route

  tokenPattern = /:([\w_]+)/

  queryString = (params)->
    parts = []
    for key, value of params
      parts.push("#{encodeURIComponent(key)}=#{encodeURIComponent(value)}")
    parts.join('&')

  parseQuery = (query)->
    params = {}
    for part in query.split('&')
      [key, value] = part.split('=')
      params[key] = value
    params

  compile = (pattern)->
    pattern = RegExp.escape(pattern)
    # Regexify all the ":token" parts and record their names
    paramNames = []
    while matches = pattern.match(tokenPattern)
      paramNames.push matches[1]
      pattern = pattern.replace(tokenPattern, '([\\w_]+)')
    [new RegExp("^#{pattern}$"), paramNames]

  extractParams = (string, matcher, paramNames)->
    params = {}
    matches = matcher.exec(string)
    for group, i in matches[1..matches.length]
      params[paramNames[i]] = group
    params

  urlParts = (url)->
    [serverBit, hash] = url.split('#')
    [path, query] = serverBit.split('?')
    [path, query, hash]
  
  constructor: (@name, @pattern)->
    [@path, @hash] = @pattern.split('#')
    [@pathMatcher, @pathParamNames] = compile(@path) if @path
    [@hashMatcher, @hashParamNames] = compile(@hash) if @hash

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

  matches: (url)->
    [path, query, hash] = urlParts(url)
    return false if !!path != !!@path
    return false if !!hash != !!@hash
    return false if path && !@pathMatcher.test(path)
    return false if hash && !@hashMatcher.test(hash)
    true

  paramsFor: (url)->
    [path, query, hash] = urlParts(url)
    params = {}
    Object.extend params, extractParams(path, @pathMatcher, @pathParamNames) if path
    Object.extend params, extractParams(hash, @hashMatcher, @hashParamNames) if hash
    Object.extend params, parseQuery(query) if query
    params

class egg.Router extends egg.Base

  @init (opts={})->
    @window = opts.window || window
    
    if opts.routes
      @routes = {}
      @routes[name] = new Route(name, pattern) for name, pattern of opts.routes
    else
      throw("Router needs a 'routes' option!")
    
    @window.onpopstate = => @run()

  bookmark: (action, params={})->
    route = @routes[action]
    if route
      @window.history.pushState({}, "", route.toURL(params))

  run: (url=@currentURL())->
    route = @routeFor(url)
    if route
      @emit("route:#{route.name}", route.paramsFor(url))

  paramsFor: (url)->
    @routeFor(url)?.paramsFor(url)

  currentURL: ->
    l = @window.location
    l.pathname + l.search + l.hash

  routeFor: (url)->
    for name, route of @routes
      return route if route.matches(url)
    null
