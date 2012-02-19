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

  it "should not add things twice", ->
    bean = Bean.create()
    set.add bean
    set.add bean
    expect(set.count()).toEqual(1)
  
  it "should give an array in the order added", ->
    bean1 = Bean.create()
    bean2 = Bean.create()
    set.add bean1
    set.add bean2
    expect(set.toArray()).toEqual([bean1, bean2])

  it "should allow taking one (in fact the first added)", ->
    bean1 = Bean.create()
    bean2 = Bean.create()
    set.add bean1
    set.add bean2
    expect( set.takeOne() ).toEqual(bean1)

  describe 'events', ->
    bean = null
    
    beforeEach ->
      set = new egg.Set
      bean = Bean.create()
    
    it "should say when something is added and someone is listening", ->
      set.on 'add', ->
      spyOn(set, 'emit')
      set.add bean
      expect(set.emit).toHaveBeenCalledWith('add', instance: bean)
    
    it "should not emit add if no-one is listening", ->
      spyOn(set, 'emit')
      set.add bean
      expect(set.emit).not.toHaveBeenCalled()

    it "should not emit add if it already belongs to the set", ->
      set.add bean
      set.on 'add', ->
      spyOn(set, 'emit')
      set.add bean
      expect(set.emit).not.toHaveBeenCalled()

    it "should say when something is removed and someone is listening", ->
      set.add bean
      set.on 'remove', ->
      spyOn(set, 'emit')
      set.remove bean
      expect(set.emit).toHaveBeenCalledWith('remove', instance: bean)

    it "should not emit remove if no-one is listening", ->
      set.add bean
      spyOn(set, 'emit')
      set.remove bean
      expect(set.emit).not.toHaveBeenCalled()

    it "should not emit remove if it didn't already belong to the set", ->
      set.on 'remove', ->
      spyOn(set, 'emit')
      set.remove bean
      expect(set.emit).not.toHaveBeenCalled()
