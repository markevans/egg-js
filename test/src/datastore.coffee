describe 'egg.Datastore', ->

  class Fig extends egg.Model

  describe 'saving', ->
    store = null

    beforeEach ->
      store = egg.Datastore.create(store: localStorage)
      
    it "should store the correct thing yo", ->
      Fig.create(attrs: {colour: 'orange'})
      Fig.create(attrs: {size: 16})
      store.save(Fig)
      expect( store.get(Fig) ).toEqual([
        {colour: 'orange'}
        {size: 16}
      ])
