class egg.Handler extends egg.Base
  
  constructor: (opts)->
    super
    if opts.objects
      @[name] = object for name, object of opts.objects
    