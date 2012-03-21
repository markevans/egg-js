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
      thighBone: -> @hipBone * 2
  
    @jsonFor 'Monkey', (monkey)->
      {super: "#{monkey.get('hungry')}duper"}
  
  class Elbow extends egg.Model
  class Knee extends egg.Model
  class Shiny extends egg.Model
  class Monkey extends egg.Model


  describe 'toJSON', ->
    it "should return the items to present", ->
      presenter = TestPresenter.create(present: {chicken: {big: 'beak'}})
      expect( presenter.toJSON() ).toEqual chicken: {big: 'beak'}

    it "should use toJSON if it's present", ->
      presenter = TestPresenter.create(present: {chicken: {toJSON: -> ['d', {a: 2}]}})
      expect( presenter.toJSON() ).toEqual chicken: ['d', {a: 2}]

    it "should loop over anything that responds to forEach", ->
      array = [{toJSON: -> 'blah'}, {toJSON: -> 'gurd'}]
      chickens = {forEach: (callback) -> callback(item) for item in array }
      presenter = TestPresenter.create(present: {chickens: chickens})
      expect( presenter.toJSON() ).toEqual chickens: ['blah', 'gurd']

    it "should decorate any specified objects", ->
      elbow = Elbow.create attrs: {doobie: 'doo'}
      presenter = TestPresenter.create(present: {elbow: elbow})
      expect( presenter.toJSON() ).toEqual elbow: {doobie: 'doo', shards: 'blaggard'}

    it "should allow giving multiple decoration method lists", ->
      shiny = Shiny.create attrs: {doobie: 'doo'}
      presenter = TestPresenter.create(present: {shiny: shiny})
      expect( presenter.toJSON() ).toEqual shiny: {doobie: 'doo', smurf: 'poo', dongle: 'trousers'}

    it "should allow for custom toJSON overrides", ->
      monkey = Monkey.create attrs: {hungry: 'yes'}
      presenter = TestPresenter.create(present: {monkey: monkey})
      expect( presenter.toJSON() ).toEqual monkey: {super: 'yesduper'}
