describe 'egg.Index', ->

  class window.Pea extends egg.Model

  index = null

  beforeEach ->
    Pea.destroyAll()

  describe 'for', ->
    
    beforeEach ->
      index = egg.Index.create parent: Pea.all(), attrNames: ['zinc', 'apple']
    
    it "should return null if the index doesn't exist", ->
      expect(egg.Index.for(Pea.all(), ['doobie', 'do'])).toBeUndefined()

    it "should return the index if it exists", ->
      expect(egg.Index.for(Pea.all(), ['zinc', 'apple'])).toEqual(index)

    it "shouldn't care about the order of the attrs", ->
      expect(egg.Index.for(Pea.all(), ['apple', 'zinc'])).toEqual(index)

  describe 'auto-adding', ->

    pea1 = null
    pea2 = null
    pea3 = null
    pea4 = null

    beforeEach ->
      index = egg.Index.create parent: Pea.all(), attrNames: ['zinc', 'apple']
      pea1 = Pea.create attrs: {zinc: 1, apple: 'gog'}
      pea2 = Pea.create attrs: {zinc: 1, apple: 'gog'}
      pea3 = Pea.create attrs: {zinc: 'dimble', apple: 'gog'}
      pea4 = Pea.create attrs: {zinc: 'farm', apple: 'house'}

    it "should be added when one is created", ->
      expect( index.setFor(zinc: 1,        apple: 'gog'  ).toArray() ).toEqual([pea1, pea2])
      expect( index.setFor(zinc: 'dimble', apple: 'gog'  ).toArray() ).toEqual([pea3])
      expect( index.setFor(zinc: 'farm',   apple: 'house').toArray() ).toEqual([pea4])
      expect( index.setFor(zinc: 'farm',   apple: 'gog'  ).toArray() ).toEqual([])

    it "should update when one is changed", ->
      pea1.set('zinc', 'farm')
      pea2.set('zinc', 'nuther')
      expect( index.setFor(zinc: 1,        apple: 'gog'  ).toArray() ).toEqual([])
      expect( index.setFor(zinc: 'dimble', apple: 'gog'  ).toArray() ).toEqual([pea3])
      expect( index.setFor(zinc: 'farm',   apple: 'house').toArray() ).toEqual([pea4])
      expect( index.setFor(zinc: 'farm',   apple: 'gog'  ).toArray() ).toEqual([pea1])
      expect( index.setFor(zinc: 'nuther', apple: 'gog'  ).toArray() ).toEqual([pea2])

    it "should update when one is destroyed", ->
      pea2.destroy()
      expect( index.setFor(zinc: 1, apple: 'gog'  ).toArray() ).toEqual([pea1])

  describe "changes that don't change the set", ->
    pea = null
    
    beforeEach ->
      index = egg.Index.create parent: Pea.all(), attrNames: ['fruit']
      pea = Pea.create attrs: {fruit: 'apple', colour: 'red'}
    
    it "should belong to the same set", ->
      expect( index.setFor(fruit: 'apple').toArray() ).toEqual([pea])
      pea.set(colour: 'green')
      expect( index.setFor(fruit: 'apple').toArray() ).toEqual([pea])

    it "should notify the set of the change", ->
      set = index.setFor(fruit: 'apple')
      spyOn(set, 'notifyChanged')
      pea.set(colour: 'green')
      expect( set.notifyChanged ).toHaveBeenCalledWith(pea, {fruit: 'apple', colour: 'red'}, {fruit: 'apple', colour: 'green'})
      