require "knjrbfw"

class Html_gen::Element
  attr_accessor :attr, :css, :classes, :str, :html
  
  def initialize(name, args = {})
    if args[:attr]
      @attr = args[:attr]
    else
      @attr = {}
    end
    
    raise "'name' should be a string or a symbol but was a '#{name.class.name}'."if !name.is_a?(String) and !name.is_a?(Symbol)
    
    @name = name
    
    {:classes => [], :html => "", :str => "", :css => {}, :eles => [], :nl => "\n", :inden => "\t"}.each do |arg, default_val|
      if args[arg]
        instance_variable_set("@#{arg}", args[arg])
      else
        instance_variable_set("@#{arg}", default_val)
      end
    end
  end
  
  def add_ele(name, args = {})
    ele = Html_gen::Element.new(name, args)
    @eles << ele
    return ele
  end
  
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
    
    pass_args = {:level => (level + 1), :pretty => pretty}
    
    attr = @attr.clone
    classes = @classes.clone
    
    str = ""
    str << @inden * level if pretty and level > 0
    str << "<#{@name}"
    
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
    
    if !@classes.empty?
      class_str = @classes.join(" ")
      
      if @attr[:class] and !@attr[:class].empty?
        @attr[:class] << " #{class_str}"
      else
        @attr[:class] = class_str
      end
    end
    
    attr.each do |key, val|
      str << " #{key}=\"#{Knj::Web.html(val)}\""
    end
    
    if @eles.empty? and @str.empty? and @html.empty?
      str << " />"
      str << @nl if pretty
    else
      str << ">"
      str << @nl if pretty
      
      if !@str.empty?
        str << @inden * (level + 1) if pretty
        str << Knj::Web.html(@str)
        str << @nl if pretty
      end
      
      if !@html.empty?
        str << @inden * (level + 1) if pretty
        str << @html
        str << @nl if pretty
      end
      
      @eles.each do |subele|
        str << subele.html(pass_args)
      end
      
      str << @inden * level if pretty and level > 0
      str << "</#{@name}>"
      str << @nl if pretty
    end
    
    return str
  end
end