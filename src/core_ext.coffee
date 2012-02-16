Object.extend = (obj, otherObjs...)->
  for otherObj in otherObjs
    obj[key] = value for key, value of otherObj
  obj

Object.slice = (obj, keys)->
  newObj = {}
  for key in keys
    newObj[key] = obj[key]
  newObj