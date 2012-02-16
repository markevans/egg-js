egg.activeRecord = (klass, opts={})->
  
  baseUrl = opts.url || throw("activeRecord plugin needs a url opt")
  paramsNamespace = opts.paramsNamespace
  
  klass.include
  
    isPersisted: ->
      !!@get('id')

    createUrl: ->
      baseUrl

    url: ->
      "#{baseUrl}/#{@get('id')}"

    params: ->
      if paramsNamespace
        params = {}
        params[paramsNamespace] = @attrs()
        params
      else
        @attrs()
