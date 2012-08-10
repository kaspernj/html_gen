#This class doesnt hold other methods than for autoloading of subclasses.
class Html_gen
  #Autoloader for subclasses.
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/html_gen_#{name.to_s.downcase}.rb"
    raise "Still not defined: '#{name}'." if !Html_gen.const_defined?(name)
    return Html_gen.const_get(name)
  end
  
  #Escapes HTML from the given string. This is to avoid any dependencies and should not be used by other libs.
  def self.escape_html(string)
    return string.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
  end
end