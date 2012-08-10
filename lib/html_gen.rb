class Html_gen
  #Autoloader for subclasses.
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/html_gen_#{name.to_s.downcase}.rb"
    raise "Still not defined: '#{name}'." if !Html_gen.const_defined?(name)
    return Html_gen.const_get(name)
  end
end