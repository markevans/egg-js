module Builder
  class << self
    
    SRC_FILES = %w(
      core_ext
      jquery_plugins
      init
      publisher
      events
      base
      set
      rest_api
      datastore
      model
      active_record
      index
      view
      js_model_view
      presenter
      handler
      router
    ).map{|basename| "src/#{basename}.coffee" }
    
    TEST_FILES = Dir['test/src/*.coffee']
    
    def build
      js = `coffee --print --join --compile #{SRC_FILES.join(' ')}`
      js.sub!(/\.call\(this\);\s*\z/, '')
      
      File.open('lib/egg.js', 'w') do |f|
        f.write amdify(js)
      end
    end
    
    def build_tests
      `coffee --print --join --compile #{TEST_FILES.join(' ')} > test/tests.js`
    end
    
    private
    
    def amdify(src_function)
      """(function(){
var src = #{src_function};

if(this.define && this.define.amd){
  define(src);
} else {
  src();
}
})();
"""
    end
  end
end
