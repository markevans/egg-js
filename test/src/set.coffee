describe 'egg.Set', ->

  set = null
  class Bean extends egg.Base
  
  beforeEach ->
    set = new egg.Set

  it "should not allow adding objects with no eggID", ->
    expect(->
      set.add('blah')
    ).toThrow("Can't add String to set without an eggID")

  it "should not say it has something it doesn't", ->
    expect(set.has('blah')).toBeFalsy()

  it "should allow adding objects with an eggID", ->
    bean = Bean.create()
    set.add(bean)
    expect(set.has(bean)).toBeTruthy()

  it "should count em", ->
    set.add Bean.create()
    set.add Bean.create()
    expect(set.count()).toEqual(2)
  
  it "should allow removing yo", ->
    b1 = Bean.create()
    b2 = Bean.create()
    set.add b1
    set.add b2
    set.remove b1
    expect(set.has(b1)).toBeFalsy()
    expect(set.count()).toEqual(1)
