describe 'egg.Base', ->

  describe 'eggID', ->

    class Dobbins extends egg.Base

    it "should set it as the name if it's a constructor", ->
      expect(Dobbins.eggID()).toEqual('Dobbins')

    it "should work for child constructors", ->
      class BabyDobbins extends Dobbins
      expect(BabyDobbins.eggID()).toEqual('BabyDobbins')

    it "should give instances a unique eggID", ->
      expect(Dobbins.create().eggID()).toEqual('Dobbins-1')
      expect(Dobbins.create().eggID()).toEqual('Dobbins-2')
