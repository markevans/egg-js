fs     = require 'fs'
{exec} = require 'child_process'

process = (dest, fileContents)->
  fs.writeFile dest, fileContents.join('\n\n'), 'utf8', (err) ->
    throw err if err
    exec "coffee --compile #{dest}", (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr
      fs.unlink dest, (err) ->
        throw err if err
        console.log 'Done.'

build = (srcFiles, dest)->
  fileContents = new Array remaining = srcFiles.length

  for file, index in srcFiles then do (file, index) ->
    fs.readFile "#{file}.coffee", 'utf8', (err, contents) ->
      throw err if err
      fileContents[index] = contents
      process("#{dest}.coffee", fileContents) if --remaining is 0

# Build
task 'build', 'Build single application file from source files', ->
  build [
    'src/core_ext'
    'src/init'
    'src/publisher'
    'src/events'
    'src/base'
    'src/rest_api'
    'src/model'
    'src/active_record'
    'src/scope'
    'src/model_index'
    'src/view'
    'src/js_model_view'
  ], 'lib/egg'

# Minify
task 'minify', 'Minify the resulting application file after build', ->
  exec 'java -jar "$HOME/jar/compiler.jar" --js lib/egg.js --js_output_file lib/egg.min.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

# Build tests
task 'build_tests', 'Build tests from source files', ->
  build [
    'test/src/base'
    'test/src/scope'
  ], 'test/tests'
