describe 'egg jquery plugins', ->
  
  describe "formParams", ->
    
    it "should convert a form to params", ->
      form = $("""
        <form>
          <input type="text" name="animal" value="monkey" />
          <input type="text" name="mineral" value="hunkey" />
        </form>
      """)
      expect( form.formParams() ).toEqual(
        animal: 'monkey'
        mineral: 'hunkey'
      )

    it "should namespace names with brackets yo", ->
      form = $("""
        <form>
          <input type="text" name="egg[animal]" value="monkey" />
          <input type="text" name="big[bad][mineral]" value="hunkey" />
        </form>
      """)
      expect( form.formParams() ).toEqual(
        egg: {animal: 'monkey'}
        big: {bad: {mineral: 'hunkey'}}
      )