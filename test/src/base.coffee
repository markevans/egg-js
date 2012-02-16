describe 'egg.Base', ->

  describe 'eggID', ->

    class Dobbins extends egg.Base

    it "should set it as the name if it's a constructor", ->
      expect(Dobbins.eggID()).toEqual('Dobbins')

    it "should work for child constructors", ->
      class BabyDobbins extends Dobbins
      expect(BabyDobbins.eggID()).toEqual('BabyDobbins')

    it "should give instances a unique eggID", ->
      id1 = Dobbins.create().eggID()
      id2 = Dobbins.create().eggID()
      expect(id1).toMatch(/^Dobbins-\d+$/)
      expect(id2).toMatch(/^Dobbins-\d+$/)
      expect(id1).toNotEqual(id2)
