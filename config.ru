require File.expand_path('../builder', __FILE__)

class Server

  def call(env)

    case env['PATH_INFO']
    when '/egg.js'
      Builder.build
      js_response File.read('lib/egg.js')
    when '/tests.js'
      Builder.build_tests
      js_response File.read('test/tests.js')
    else
      not_found_response
    end

  end

  private
  
  def js_response(body)
    [200, {'Content-Type' => 'application/x-javascript'}, [body]]
  end

  def not_found_response
    [404, {'Content-Type' => 'text/plain'}, ['Not found']]
  end

end

run Server.new
