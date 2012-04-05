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

  constructor: (@name, pattern)->
    if pattern[0] == '#'
      @usesHash = true
      @pattern = pattern.slice(1)
    else
      @usesHash = false
      @pattern = pattern
    
    [@matcher, @paramNames] = compile(@pattern)

  toURL: (params)->
    pattern = @pattern
    query = {}
    for key, value of params
      token = ':' + key
      if pattern.match(token)
        pattern = pattern.replace(token, value)
      else
        query[key] = value
    url = ""
    url += "#" if @usesHash
    url += pattern
    url += "?#{queryString(query)}" unless Object.isEmpty(query)
    url

  matches: (url)->
    [path, query] = @urlParts(url)
    @matcher.test(path)

  paramsFor: (url)->
    [path, query] = @urlParts(url)
    params = {}
    Object.extend params, extractParams(path, @matcher, @paramNames)
    Object.extend params, parseQuery(query) if query
    params

  urlParts: (url)->
    [serverBit, hash] = url.split('#')
    if @usesHash
      (hash || "").split('?')
    else
      (serverBit || "").split('?')

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
