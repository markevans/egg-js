egg.jsModelView = (klass)->

  klass.include

    subscribeToObj: ->
      for key, s of @constructor.objectSubscriptionSpecs()
        eventName = s.eventName
        callback = (args...) => @[s.method](args...)
        @obj.bind(eventName, callback)
        @objectSubscriptions().push eventName: eventName, callback: callback

    unsubscribeToObj: ->
      @obj.unbind(sub.eventName, sub.callback) for sub in @objectSubscriptions()
