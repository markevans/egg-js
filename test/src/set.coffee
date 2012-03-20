describe 'egg.Set', ->

  set = null
  class Bean extends egg.Model

  describe 'general shermanickans', ->

    beforeEach ->
      set = new egg.Set

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

    it "should allow taking the first", ->
      bean1 = Bean.create()
      bean2 = Bean.create()
      set.add bean1
      set.add bean2
      expect( set.first() ).toEqual(bean1)

  describe 'return values', ->
    bean = null
    
    beforeEach ->
      set = new egg.Set
      bean = Bean.create()
    
    it "should return true if added", ->
      expect( set.add(bean) ).toBeTruthy()

    it "should return false if already there", ->
      set.add bean
      expect( set.add(bean) ).toBeFalsy()

    it "should return true if removed", ->
      set.add bean
      expect( set.remove(bean) ).toBeTruthy()

    it "should return false if not already there", ->
      expect( set.remove(bean) ).toBeFalsy()

  describe 'initializing with items', ->
    it "should allow initializing with an items array", ->
      b1 = Bean.create()
      b2 = Bean.create()
      set = new egg.Set(items: [b1, b2])
      expect( set.toArray() ).toEqual([b1, b2])

  describe 'ordering', ->
    b1 = null
    b2 = null

    beforeEach ->
      b1 = Bean.create(attrs: {name: 'Abi'})
      b2 = Bean.create(attrs: {name: 'Bigs'})

    it "should allow sorting", ->
      set = new egg.Set(items: [b1, b2], sorter: (a,b) -> 1)
      expect( set.toArray() ).toEqual([b2, b1])

    it "should allow easy model ordering by ascending", ->
      set = new egg.Set(items: [b1, b2])
      expect( set.asc('name').toArray() ).toEqual([b1, b2])

    it "should allow easy model ordering by descending", ->
      set = new egg.Set(items: [b1, b2])
      expect( set.desc('name').toArray() ).toEqual([b2, b1])

    it "should put undefined values last", ->
      b3 = Bean.create()
      set = new egg.Set(items: [b1, b2, b3])
      expect( set.asc('name').toArray()  ).toEqual([b1, b2, b3])
      expect( set.desc('name').toArray() ).toEqual([b2, b1, b3])

  describe 'cached array', ->
    it "should correctly 'uncache' when adding/removing", ->
      b1 = Bean.create()
      b2 = Bean.create()

      set = new egg.Set(items: [b1])
      expect( set.toArray() ).toEqual([b1])
      expect( set.count() ).toEqual(1)

      set.add b2
      expect( set.toArray() ).toEqual([b1, b2])
      expect( set.count() ).toEqual(2)

      set.remove b1
      expect( set.toArray() ).toEqual([b2])
      expect( set.count() ).toEqual(1)
