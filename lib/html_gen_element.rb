#This class can be used to generate HTML.
#===Examples
#  ele = Html_gen::Element.new(:a) #=> #<Html_gen::Element:0x00000000e5f650 @attr={}, @name=:a, @classes=[], @str_html="", @str="", @css={}, @eles=[], @nl="\n", @inden="\t">
#  ele.classes << "custom_link"
#  ele.css["font-weight"] = "bold"
#  ele.attr[:href] = "http://www.youtube.com"
#  
#  b = ele.add_ele(:b)
#  b.str = "Title of link"
#  
#  ele.html #=> "<a href=\"http://www.youtube.com\" style=\"font-weight: bold;\" class=\"custom_link\">\n\t<b>\n\t\tTitle of link\n\t</b>\n</a>\n"
class Html_gen::Element
  #Attributes hash which will be used to generate attributes-elements.
  #===Example
  #  element.attr[:href] = "http://www.youtube.com"
  attr_reader :attr
  
  #CSS-hash which will be used to generate the 'style'-attribute.
  #===Example
  #  element.css["font-weight"] = "bold"
  attr_reader :css
  
  #Classes-array which will be used to generate the 'class'-attribute.
  #===Example
  #  element.classes += ["class1", "class2"]
  #  element.html #=> ... class="class1 class2"...
  attr_reader :classes
  
  #This string is used to generate the value of an element. It will be HTML-escaped.
  #===Example
  #  element = Html_gen::Element.new("b")
  #  element.str = "Te<i>s</i>t"
  #  element.html(:pretty => false) #=> "<b>Te&lt;i&gt;s&lt;/i&gt;t</b>"
  attr_accessor :str
  
  #This string is used to generate the value of an element. It will not be HTML-escaped.
  #===Example
  #  element = Html_gen::Element.new("b")
  #  element.str_html = "Te<i>s</i>t"
  #  element.html #=> "<b>Te<i>s</i>t</b>"
  attr_accessor :str_html
  
  #An array holding all the sub-elements of this element.
  attr_accessor :eles
  
  #The name of the element. "a" for <a> and such.
  attr_accessor :name
  
  #You can give various arguments as shortcuts to calling the methods. You can also decide what should be used for newline and indentation.
  #  Html_gen::Element.new(:b, {
  #    :css => {"font-weight" => "bold"},
  #    :attr => {"href" => "http://www.youtube.com"},
  #    :classes => ["class1", "class2"],
  #    :str => "A title",
  #    :str_html => "Some custom URL as title",
  #    :nl => "\n",
  #    :inden => "\t",
  #    :eles => [Html_gen::Element.new("i", :str => "Hello world!")
  #  })
  def initialize(name, args = {})
    raise "'name' should be a string or a symbol but was a '#{name.class.name}'."if !name.is_a?(String) and !name.is_a?(Symbol)
    @name = name
    
    {:attr => {}, :classes => [], :str_html => "", :str => "", :css => {}, :eles => [], :nl => "\n", :inden => "\t"}.each do |arg, default_val|
      if args[arg]
        instance_variable_set("@#{arg}", args[arg])
      else
        instance_variable_set("@#{arg}", default_val)
      end
      
      args.delete(arg)
    end
    
    raise "Unknown arguments: '#{args.keys.join(",")}'." if !args.empty?
  end
  
  #Adds a sub-element to the element.
  #===Examples
  #  element = Html_gen::Element.new("a")
  #  another_ele = element.add_ele("b")
  #  another_ele.str = "Hello world!"
  #  element.html #=> "<a>\n\t<b>\n\t\tHello world!\n\t</b>\n</a>\n"
  def add_ele(name, args = {})
    ele = Html_gen::Element.new(name, args.merge(:nl => @nl, :inden => @inden))
    @eles << ele
    return ele
  end
  
  #Add a text-element to the element.
  def add_str(str)
    ele = Html_gen::Text_ele.new(:str => str, :inden => @inden, :nl => @nl)
    @eles << ele
    return ele
  end
  
  # Returns the HTML for the element.
  # To avoid indentation and newlines you can use the 'pretty'-argument:
  #  element.html(:pretty => false)
  def html(args = {})
    if args[:level]
      level = args[:level]
    else
      level = 0
    end
    
    if args.key?(:pretty)
      pretty = args[:pretty]
    else
      pretty = true
    end
    
    #Used for keeping 'pretty'-value and correct indentation according to parent elements.
    pass_args = {:level => (level + 1), :pretty => pretty, :inden => @inden}
    
    #Clone the attributes-hash since we are going to add stuff to it, and it shouldnt be reflected (if 'html' is called multiple times, it will bug unless we clone).
    attr = @attr.clone
    
    #Start generating the string with HTML (possible go give a custom 'str'-variable where the content should be pushed to).
    if args[:str]
      str = args[:str]
    else
      str = ""
    end
    
    str << @inden * level if pretty and level > 0
    str << "<#{@name}"
    
    #Add content from the 'css'-hash to the 'style'-attribute in the right format.
    if !@css.empty?
      style = ""
      @css.each do |key, val|
        style << "; " if !style.empty?
        style << "#{key}: #{val};"
      end
      
      if attr[:style] and !attr[:style].empty?
        attr[:style] << "; "
        attr[:style] << style
      else
        attr[:style] = style
      end
    end
    
    #Add content from the 'classes'-array to the 'class'-attribute in the right format.
    if !@classes.empty?
      class_str = @classes.join(" ")
      
      if @attr[:class] and !@attr[:class].empty?
        attr[:class] << " #{class_str}"
      else
        attr[:class] = class_str
      end
    end
    
    #Write out the attributes to the string.
    attr.each do |key, val|
      str << " #{key}=\"#{Html_gen.escape_html(val)}\""
    end
    
    if @eles.empty? and @str.empty? and @str_html.empty?
      #If no sub-string, sub-HTML or sub-elements are given, we should end the HTML with " />".
      str << " />"
      str << @nl if pretty
    else
      #Write end-of-element and then all sub-elements.
      str << ">"
      str << @nl if pretty
      
      if !@str.empty?
        str << @inden * (level + 1) if pretty
        str << Html_gen.escape_html(@str)
        str << @nl if pretty
      end
      
      if !@str_html.empty?
        str << @inden * (level + 1) if pretty
        str << @str_html
        str << @nl if pretty
      end
      
      @eles.each do |subele|
        str << subele.html(pass_args)
      end
      
      str << @inden * level if pretty and level > 0
      str << "</#{@name}>"
      str << @nl if pretty
    end
    
    #Returns the string.
    return str
  end
  
  #Returns the names of all sub-elements in an array.
  def eles_names
    names = []
    @eles.each do |ele|
      names << ele.name
    end
    
    return names
  end
  
  #Converts the content of the 'style'-attribute to css-hash-content.
  def convert_style_to_css
    if !@attr[:style].to_s.strip.empty?
      style = @attr[:style]
    elsif !@attr["style"].to_s.strip.empty?
      style = @attr["style"]
    else
      raise "No style set in element."
    end
    
    loop do
      if match = style.match(/\A\s*(\S+?):\s*(.+?)\s*(;|\Z)/)
        style.gsub!(match[0], "")
        key = match[1]
        val = match[2]
        raise "Such a key already exists in CSS-hash: '#{key}'." if @css.key?(key)
        @css[key] = val
      elsif match = style.slice!(/\A\s*\Z/)
        break
      else
        raise "Dont know what to do with style-variable: '#{style}'."
      end
    end
  end
end