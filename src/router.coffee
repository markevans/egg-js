class Route

  queryString = (params)->
    parts = []
    for key, value of params
      parts.push("#{encodeURIComponent(key)}=#{encodeURIComponent(value)}")
    parts.join('&')

  compile = (pattern)->
    pattern = RegExp.escape(pattern)
    tokenPattern = /:([\w_]+)/
    # Regexify all the ":token" parts and record their names
    paramNames = []
    while matches = pattern.match(tokenPattern)
      paramNames.push matches[1]
      pattern = pattern.replace(tokenPattern, '([\\w_]+)')
    # Allow for a query string
    queryPattern = '(?:\\?[^#]*)?'
    pattern = if pattern.match('\\#')
      pattern.replace('\\#', queryPattern+'#')
    else
      pattern + queryPattern
    [new RegExp("^#{pattern}$"), paramNames]
  
  constructor: (@name, @pattern)->
    [@path, @hash] = @pattern.split('#')
    [@matcher, @paramNames] = compile(@pattern)

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
    @matcher.test(url)

  paramsFor: (url)->
    params = {}
    matches = @matcher.exec(url)
    for group, i in matches[1..matches.length]
      params[@paramNames[i]] = group
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
    console.log "Finding a match for url", url
    route = @routeFor(url)
    if route
      console.log "found", route.name
      @emit("route:#{route.name}", route.paramsFor(url))
    else
      console.log "nothing found"

  paramsFor: (url)->
    @routeFor(url)?.paramsFor(url)

  currentURL: ->
    l = @window.location
    l.pathname + l.search + l.hash

  routeFor: (url)->
    for name, route of @routes
      return route if route.matches(url)
    null
