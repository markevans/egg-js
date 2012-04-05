describe "egg.Router", ->
  window.router = egg.Router.create(routes:
    'breads:index': '/breads'
    'breads:show':  '/breads/:id'
    'breads:show:stuff': '#foo/:bar'
  )
  
  it "should match the correct route", ->
    expect( router.routeFor('/breads'    ).name ).toEqual('breads:index')
    expect( router.routeFor('/breads/234').name ).toEqual('breads:show')
  
  it "should not match routes that don't exist", ->
    expect( router.routeFor('shenanigans/pans')        ).toEqual(null)
    expect( router.routeFor('/breads/234/shenanigans') ).toEqual(null)
    expect( router.routeFor('naan/breads')             ).toEqual(null)

  it "should work for hashes and shiz", ->
    expect( router.routeFor('#foo/dunk').name ).toEqual('breads:show:stuff')

  it "should still work with query strings", ->
    expect( router.routeFor('/breads/234?my=query' ).name ).toEqual('breads:show')
    expect( router.routeFor('#foo/dunk?my=query'   ).name ).toEqual('breads:show:stuff')

  it "should parse the url correctly", ->
    expect( router.paramsFor('/breads')     ).toEqual({})
    expect( router.paramsFor('/breads/234') ).toEqual(id: '234')
    expect( router.paramsFor('#foo/dunk')   ).toEqual(bar: 'dunk')

  it "should include query string params", ->
    expect( router.paramsFor('/breads/234?my=query') ).toEqual(id: '234', my: 'query')
    expect( router.paramsFor('#foo/dunk?my=query')   ).toEqual(bar: 'dunk', my: 'query')
