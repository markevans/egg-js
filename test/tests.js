(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  describe('egg.Scope', function() {
    var TestObject;
    TestObject = (function(_super) {

      __extends(TestObject, _super);

      function TestObject() {
        TestObject.__super__.constructor.apply(this, arguments);
      }

      TestObject.use(egg.model);

      return TestObject;

    })(egg.Base);
    return describe('correctly filtering', function() {
      var a, b, c, d, evens;
      evens = egg.Scope.create({
        modelClass: TestObject,
        filter: function(model) {
          return model.get('num') % 2 === 0;
        }
      });
      a = null;
      b = null;
      c = null;
      d = null;
      beforeEach(function() {
        TestObject.destroyAll();
        a = TestObject.create({
          attrs: {
            num: 1
          }
        });
        b = TestObject.create({
          attrs: {
            num: 2
          }
        });
        c = TestObject.create({
          attrs: {
            num: 7
          }
        });
        return d = TestObject.create({
          attrs: {
            num: 10
          }
        });
      });
      it("should include all the ones that meet the criteria", function() {
        return expect(evens.toArray()).toEqual([b, d]);
      });
      it("should include all the ones that meet the criteria if created later than the models", function() {
        var odds;
        odds = egg.Scope.create({
          modelClass: TestObject,
          filter: function(model) {
            return model.get('num') % 2 === 1;
          }
        });
        return expect(odds.toArray()).toEqual([a, c]);
      });
      describe("when one of them subsequently fits the criteria", function() {
        beforeEach(function() {
          spyOn(evens, 'emit');
          return a.set('num', 4);
        });
        it("should be updated", function() {
          return expect(evens.toArray()).toEqual([a, b, d]);
        });
        return it("should emit an added event", function() {
          return expect(evens.emit).toHaveBeenCalledWith('add', {
            instance: a
          });
        });
      });
      describe("when one of the subsequently doesn't fit the criteria", function() {
        beforeEach(function() {
          spyOn(evens, 'emit');
          return b.set('num', 3);
        });
        it("should be updated", function() {
          return expect(evens.toArray()).toEqual([d]);
        });
        return it("should emit a removed event", function() {
          return expect(evens.emit).toHaveBeenCalledWith('remove', {
            instance: b
          });
        });
      });
      describe("when one of them is changed and still fits the criteria", function() {
        var spy;
        spy = null;
        beforeEach(function() {
          spy = spyOn(evens, 'emit');
          return b.set('num', 22);
        });
        it("should not change", function() {
          return expect(evens.toArray()).toEqual([b, d]);
        });
        it("should not emit any add or destroy events", function() {
          var eventName;
          eventName = spy.mostRecentCall.args[0];
          expect(eventName).not.toEqual('add');
          return expect(eventName).not.toEqual('destroy');
        });
        return it("should emit a changed event", function() {
          return expect(evens.emit).toHaveBeenCalledWith('change', {
            instance: b,
            from: {
              num: 2
            },
            to: {
              num: 22
            }
          });
        });
      });
      describe("when one of them is changed and still doesn't fit the criteria", function() {
        beforeEach(function() {
          spyOn(evens, 'emit');
          return a.set('num', 33);
        });
        it("should not change", function() {
          return expect(evens.toArray()).toEqual([b, d]);
        });
        return it("should not emit any events", function() {
          return expect(evens.emit).not.toHaveBeenCalled();
        });
      });
      describe("when a new one fits the criteria", function() {
        var e;
        e = null;
        beforeEach(function() {
          spyOn(evens, 'emit');
          return e = TestObject.create({
            attrs: {
              num: 12
            }
          });
        });
        it("should be updated", function() {
          return expect(evens.toArray()).toEqual([b, d, e]);
        });
        return it("should emit an added event", function() {
          return expect(evens.emit).toHaveBeenCalledWith('add', {
            instance: e
          });
        });
      });
      describe("when a new one doesn't fit the criteria", function() {
        var e;
        e = null;
        beforeEach(function() {
          spyOn(evens, 'emit');
          return e = TestObject.create({
            attrs: {
              num: 13
            }
          });
        });
        it("should not change", function() {
          return expect(evens.toArray()).toEqual([b, d]);
        });
        return it("should not emit any events", function() {
          return expect(evens.emit).not.toHaveBeenCalled();
        });
      });
      describe("when one is destroyed that fitted the criteria", function() {
        beforeEach(function() {
          spyOn(evens, 'emit');
          return d.destroy();
        });
        it("should be updated", function() {
          return expect(evens.toArray()).toEqual([b]);
        });
        return it("should emit a removed event", function() {
          return expect(evens.emit).toHaveBeenCalledWith('remove', {
            instance: d
          });
        });
      });
      return describe("when one is destroyed that didn't fit the criteria", function() {
        beforeEach(function() {
          spyOn(evens, 'emit');
          return c.destroy();
        });
        it("should not change", function() {
          return expect(evens.toArray()).toEqual([b, d]);
        });
        return it("should not emit any events", function() {
          return expect(evens.emit).not.toHaveBeenCalled();
        });
      });
    });
  });

}).call(this);
