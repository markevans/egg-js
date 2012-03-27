describe 'egg.Presenter', ->

  class TestPresenter extends egg.Presenter
    
    @decorate 'Elbow'
      shards: "blaggard"
  
    @decorate 'Shiny', {
      smurf: 'poo'
    }, {
      dongle: 'trousers'
    }
    
    @decorate 'Knee',
      thighBone: -> @get('hipBone') * 2
    
    @decorate 'Monkey',
      elbows: -> [Elbow.create(attrs: {degrees: 90})]
  
    @decorate 'Car', ['doors', 'eggs']
  
  class Elbow extends egg.Model
  class Knee extends egg.Model
  class Shiny extends egg.Model
  class Monkey extends egg.Model
  class Car
    doors: -> 5
    eggs: 6


  describe 'toJSON', ->
    it "should return the items to present", ->
      presenter = TestPresenter.create(objects: {chicken: {big: 'beak'}})
      expect( presenter.toJSON() ).toEqual chicken: {big: 'beak'}

    it "should use toJSON if it's present", ->
      presenter = TestPresenter.create(objects: {chicken: {toJSON: -> ['d', {a: 2}]}})
      expect( presenter.toJSON() ).toEqual chicken: ['d', {a: 2}]

    it "should loop over anything that responds to forEach", ->
      array = [{toJSON: -> 'blah'}, {toJSON: -> 'gurd'}]
      chickens = {forEach: (callback) -> callback(item) for item in array }
      presenter = TestPresenter.create(objects: {chickens: chickens})
      expect( presenter.toJSON() ).toEqual chickens: ['blah', 'gurd']

    it "should decorate any specified objects", ->
      elbow = Elbow.create attrs: {doobie: 'doo'}
      presenter = TestPresenter.create(objects: {elbow: elbow})
      expect( presenter.toJSON() ).toEqual elbow: {doobie: 'doo', shards: 'blaggard'}

    it "should allow giving multiple decoration method lists", ->
      shiny = Shiny.create attrs: {doobie: 'doo'}
      presenter = TestPresenter.create(objects: {shiny: shiny})
      expect( presenter.toJSON() ).toEqual shiny: {doobie: 'doo', smurf: 'poo', dongle: 'trousers'}

    it "should call any decoration methods", ->
      knee = Knee.create attrs: {hipBone: 4}
      presenter = TestPresenter.create(objects: {knee: knee})
      expect( presenter.toJSON() ).toEqual knee: {hipBone: 4, thighBone: 8}

    it "should allow getting json for a specific model", ->
      knee = Knee.create attrs: {hipBone: 4}
      presenter = TestPresenter.create(objects: {knee: knee})
      expect( presenter.present(knee) ).toEqual {hipBone: 4, thighBone: 8}

    it "should recurse toJSON", ->
      presenter = TestPresenter.create(objects: {monkey: Monkey.create(attrs: {bananas: 'many'})})
      expect( presenter.toJSON() ).toEqual {monkey: {bananas: 'many', elbows: [{degrees: 90, shards: 'blaggard'}]}}

    it "should allow specifying an array to use methods on the model", ->
      presenter = TestPresenter.create(objects: {car: new Car})
      expect( presenter.toJSON() ).toEqual {car: {doors: 5, eggs: 6}}

    describe "events", ->
      it "should forward events", ->
        monkey = Monkey.create attrs: {hungry: 'yes'}
        presenter = TestPresenter.create(objects: {monkey: monkey})
        spyOn(presenter, 'emit')
        presenter.on 'anything', ->
        monkey.set('hungry', 'pig')
        expect( presenter.emit ).toHaveBeenCalledWith('monkey:change:hungry', instance: monkey, from: 'yes', to: 'pig')

      it "should not forward events if nothing has yet subscribed to it", ->
        monkey = Monkey.create attrs: {hungry: 'yes'}
        presenter = TestPresenter.create(objects: {monkey: monkey})
        spyOn(presenter, 'emit')
        monkey.set('hungry', 'pig')
        expect( presenter.emit ).not.toHaveBeenCalled()
      