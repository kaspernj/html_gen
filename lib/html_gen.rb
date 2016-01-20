require "string-cases"

# This class doesnt hold other methods than for autoloading of subclasses.
class HtmlGen
  # Autoloader for subclasses.
  def self.const_missing(name)
    file_path = "#{File.dirname(__FILE__)}/html_gen/#{::StringCases.camel_to_snake(name)}.rb"

    if File.exist?(file_path)
      require file_path
      return HtmlGen.const_get(name) if HtmlGen.const_defined?(name)
    end

    super
  end

  # Escapes HTML from the given string. This is to avoid any dependencies and should not be used by other libs.
  def self.escape_html(string)
    string.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
  end
end
