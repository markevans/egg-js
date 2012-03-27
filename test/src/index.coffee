describe 'egg.Index', ->

  class window.Pea extends egg.Model

  index = null

  beforeEach ->
    Pea.destroyAll()

  describe 'for', ->
    
    beforeEach ->
      index = egg.Index.create modelClass: Pea, attrNames: ['zinc', 'apple']
    
    it "should return null if the index doesn't exist", ->
      expect(egg.Index.for(Pea, ['doobie', 'do'])).toBeUndefined()
      expect(egg.Index.for({}, ['zinc, apple'])).toBeUndefined()

    it "should return the index if it exists", ->
      expect(egg.Index.for(Pea, ['zinc', 'apple'])).toEqual(index)

    it "shouldn't care about the order of the attrs", ->
      expect(egg.Index.for(Pea, ['apple', 'zinc'])).toEqual(index)

  describe 'auto-adding', ->

    pea1 = null
    pea2 = null
    pea3 = null
    pea4 = null

    beforeEach ->
      index = egg.Index.create modelClass: Pea, attrNames: ['zinc', 'apple']
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
