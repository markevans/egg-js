describe 'egg.Scope', ->

  class TestObject extends egg.Model

  describe 'correctly filtering', ->

    evens = egg.Scope.create(
      parent: TestObject
      filter: (model) -> model.get('num') % 2 == 0
    )
    a = null
    b = null
    c = null
    d = null
    
    beforeEach ->
      TestObject.destroyAll()
      a = TestObject.create attrs: {num: 1}
      b = TestObject.create attrs: {num: 2}
      c = TestObject.create attrs: {num: 7}
      d = TestObject.create attrs: {num: 10}

    it "should include all the ones that meet the criteria", ->
      expect(evens.toArray()).toEqual([b, d])
    
    it "should include all the ones that meet the criteria if created later than the models", ->
      odds = egg.Scope.create(
        parent: TestObject
        filter: (model) -> model.get('num') % 2 == 1
      )
      expect(odds.toArray()).toEqual([a, c])

    it "should say if it has an item", ->
      expect( evens.has(b) ).toEqual(true)

    it "should say if it doesn't have an item", ->
      expect( evens.has(a) ).toEqual(false)

    describe "when one of them subsequently fits the criteria", ->
      beforeEach ->
        spyOn(evens, 'emit')
        a.set('num', 4)
      
      it "should be updated", ->
        expect(evens.toArray()).toEqual([b, d, a])

      it "should emit an added event", ->
        expect(evens.emit).toHaveBeenCalledWith('add', instance: a)

    describe "when one of the subsequently doesn't fit the criteria", ->
      beforeEach ->
        spyOn(evens, 'emit')
        b.set('num', 3)

      it "should be updated", ->
        expect(evens.toArray()).toEqual([d])

      it "should emit a removed event", ->
        expect(evens.emit).toHaveBeenCalledWith('remove', instance: b)

    describe "when one of them is changed and still fits the criteria", ->
      spy = null
      beforeEach ->
        spy = spyOn(evens, 'emit')
        b.set('num', 22)

      it "should not change", ->
        expect(evens.toArray()).toEqual([b, d])

      it "should not emit any add or destroy events", ->
        eventName = spy.mostRecentCall.args[0]
        expect(eventName).not.toEqual('add')
        expect(eventName).not.toEqual('destroy')

      it "should emit a changed event", ->
        expect(evens.emit).toHaveBeenCalledWith('change', instance: b, from: {num: 2}, to: {num: 22})

    describe "when one of them is changed and still doesn't fit the criteria", ->
      beforeEach ->
        spyOn(evens, 'emit')
        a.set('num', 33)

      it "should not change", ->
        expect(evens.toArray()).toEqual([b, d])

      it "should not emit any events", ->
        expect(evens.emit).not.toHaveBeenCalled()

    describe "when a new one fits the criteria", ->
      e = null
      beforeEach ->
        spyOn(evens, 'emit')
        e = TestObject.create attrs: {num: 12}

      it "should be updated", ->
        expect(evens.toArray()).toEqual([b, d, e])

      it "should emit an added event", ->
        expect(evens.emit).toHaveBeenCalledWith('add', instance: e)

    describe "when a new one doesn't fit the criteria", ->
      e = null
      beforeEach ->
        spyOn(evens, 'emit')
        e = TestObject.create attrs: {num: 13}

      it "should not change", ->
        expect(evens.toArray()).toEqual([b, d])

      it "should not emit any events", ->
        expect(evens.emit).not.toHaveBeenCalled()


    describe "when one is destroyed that fitted the criteria", ->
      beforeEach ->
        spyOn(evens, 'emit')
        d.destroy()

      it "should be updated", ->
        expect(evens.toArray()).toEqual([b])

      it "should emit a removed event", ->
        expect(evens.emit).toHaveBeenCalledWith('remove', instance: d)

    describe "when one is destroyed that didn't fit the criteria", ->
      beforeEach ->
        spyOn(evens, 'emit')
        c.destroy()

      it "should not change", ->
        expect(evens.toArray()).toEqual([b, d])

      it "should not emit any events", ->
        expect(evens.emit).not.toHaveBeenCalled()
