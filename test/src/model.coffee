describe 'egg.Model', ->

  class TestModel extends egg.Model

  beforeEach ->
    TestModel.destroyAll()

  describe 'filter', ->
    it "should return the correct models", ->
      m1 = TestModel.create attrs: log: 'nog'
      m2 = TestModel.create attrs: log: 'noggin'
      m3 = TestModel.create attrs: log: 'nogules'
      set = TestModel.filter (model) -> model.get('log').length > 4
      expect( set.toArray() ).toEqual([m2, m3])

  describe 'where', ->
    it "should return the correct models", ->
      m1 = TestModel.create attrs: log: 'nog'
      m2 = TestModel.create attrs: log: 'noggin'
      m3 = TestModel.create attrs: log: 'noggin'
      set = TestModel.where log: 'noggin'
      expect( set.toArray() ).toEqual([m2, m3])
    
    it "should work when an index exists", ->
      egg.Index.create(parent: TestModel.all(), attrNames: ['log'])
      m1 = TestModel.create attrs: log: 'nog'
      m2 = TestModel.create attrs: log: 'noggin'
      m3 = TestModel.create attrs: log: 'noggin'

      spyOn(TestModel, 'filter')
      set = TestModel.where log: 'noggin'
      expect( set.toArray() ).toEqual([m2, m3])
      expect( TestModel.filter ).not.toHaveBeenCalled()

  describe 'find', ->
    it "should return the correct model", ->
      m1 = TestModel.create attrs: log: 'nog'
      m2 = TestModel.create attrs: log: 'noggin'
      m3 = TestModel.create attrs: log: 'noggin'
      expect( TestModel.find(log: 'nog') ).toEqual(m1)
