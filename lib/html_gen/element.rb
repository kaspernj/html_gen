# This class can be used to generate HTML.
#===Examples
#  ele = HtmlGen::Element.new(:a) #=> #<HtmlGen::Element:0x00000000e5f650 @attr={}, @name=:a, @classes=[], @str_html="", @str="", @css={}, @eles=[], @nl="\n", @inden="\t">
#  ele.classes << "custom_link"
#  ele.css["font-weight"] = "bold"
#  ele.attr[:href] = "http://www.youtube.com"
#
#  b = ele.add_ele(:b)
#  b.str = "Title of link"
#
#  ele.html #=> "<a href=\"http://www.youtube.com\" style=\"font-weight: bold;\" class=\"custom_link\">\n\t<b>\n\t\tTitle of link\n\t</b>\n</a>\n"
class HtmlGen::Element
  FORBIDDEN_SHORT = ["script"].freeze

  # Attributes hash which will be used to generate attributes-elements.
  #===Example
  #  element.attr[:href] = "http://www.youtube.com"
  attr_reader :attr

  # CSS-hash which will be used to generate the 'style'-attribute.
  #===Example
  #  element.css["font-weight"] = "bold"
  attr_reader :css

  # Data hash which will nest keys.
  attr_reader :data

  # Classes-array which will be used to generate the 'class'-attribute.
  #===Example
  #  element.classes += ["class1", "class2"]
  #  element.html #=> ... class="class1 class2"...
  attr_reader :classes

  # This string is used to generate the value of an element. It will be HTML-escaped.
  #===Example
  #  element = HtmlGen::Element.new("b")
  #  element.str = "Te<i>s</i>t"
  #  element.html(pretty: false) #=> "<b>Te&lt;i&gt;s&lt;/i&gt;t</b>"
  attr_accessor :str

  # This string is used to generate the value of an element. It will not be HTML-escaped.
  #===Example
  #  element = HtmlGen::Element.new("b")
  #  element.str_html = "Te<i>s</i>t"
  #  element.html #=> "<b>Te<i>s</i>t</b>"
  attr_accessor :str_html

  # An array holding all the sub-elements of this element.
  attr_accessor :eles

  # The name of the element. "a" for <a> and such.
  attr_accessor :name

  # You can give various arguments as shortcuts to calling the methods. You can also decide what should be used for newline and indentation.
  #  HtmlGen::Element.new(:b, {
  #    css: {"font-weight" => "bold"},
  #    attr: {"href" => "http://www.youtube.com"},
  #    classes: ["class1", "class2"],
  #    str: "A title",
  #    str_html: "Some custom URL as title",
  #    nl: "\n",
  #    inden: "\t",
  #    eles: [HtmlGen::Element.new("i", str: "Hello world!")
  #  })
  def initialize(name, args = {})
    raise "'name' should be a string or a symbol but was a '#{name.class.name}'." if !name.is_a?(String) && !name.is_a?(Symbol)
    @name = name

    {attr: {}, data: {}, classes: [], str_html: "", str: "", css: {}, eles: [], nl: "\n", inden: "\t"}.each do |arg, default_val|
      if args[arg]
        instance_variable_set("@#{arg}", args[arg])
      else
        instance_variable_set("@#{arg}", default_val)
      end

      args.delete(arg)
    end

    raise "Unknown arguments: '#{args.keys.join(",")}'." unless args.empty?
  end

  # Adds a sub-element to the element.
  #===Examples
  #  element = HtmlGen::Element.new("a")
  #  another_ele = element.add_ele("b")
  #  another_ele.str = "Hello world!"
  #  element.html #=> "<a>\n\t<b>\n\t\tHello world!\n\t</b>\n</a>\n"
  def add_ele(name, args = {})
    ele = HtmlGen::Element.new(name, args.merge(nl: @nl, inden: @inden))
    @eles << ele
    ele
  end

  alias add add_ele

  # Add a text-element to the element.
  def add_str(str)
    ele = HtmlGen::TextEle.new(str: str, inden: @inden, nl: @nl)
    @eles << ele
    ele
  end

  # Add a text-element to the element.
  def add_html(html)
    ele = HtmlGen::TextEle.new(html: html, inden: @inden, nl: @nl)
    @eles << ele
    ele
  end

  # Returns the HTML for the element.
  # To avoid indentation and newlines you can use the 'pretty'-argument:
  #  element.html(pretty: false)
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

    # Used for keeping 'pretty'-value and correct indentation according to parent elements.
    pass_args = {level: (level + 1), pretty: pretty, inden: @inden}

    # Clone the attributes-hash since we are going to add stuff to it, and it shouldnt be reflected (if 'html' is called multiple times, it will bug unless we clone).
    attr = @attr.clone

    # Start generating the string with HTML (possible go give a custom 'str'-variable where the content should be pushed to).
    if args[:str]
      str = args[:str]
    else
      str = ""
    end

    str << @inden * level if pretty && level > 0
    str << "<#{@name}"

    # Add content from the 'css'-hash to the 'style'-attribute in the right format.
    unless @css.empty?
      style = ""
      @css.each do |key, val|
        style << "; " unless style.empty?
        style << "#{key}: #{val};"
      end

      if attr[:style] && !attr[:style].empty?
        attr[:style] << "; #{style}"
      else
        attr[:style] = style
      end
    end

    # Add content from the 'classes'-array to the 'class'-attribute in the right format.
    unless @classes.empty?
      class_str = @classes.join(" ")

      if @attr[:class] && !@attr[:class].empty?
        attr[:class] << " #{class_str}"
      else
        attr[:class] = class_str
      end
    end

    # Write out the attributes to the string.
    attr.each do |key, val|
      str << " #{key}=\"#{HtmlGen.escape_html(val)}\""
    end

    str << " #{data_attributes(@data, "data")}" if @data.any?

    forbidden_short = FORBIDDEN_SHORT.include?(@name.to_s)
    skip_pretty = false

    if @eles.empty? && @str.empty? && @str_html.empty? && !forbidden_short
      # If no sub-string, sub-HTML or sub-elements are given, we should end the HTML with " />".
      str << " />"
      str << @nl if pretty
    else
      # Write end-of-element and then all sub-elements.
      str << ">"

      if @eles.empty? && @str.empty? && @str_html.empty? && forbidden_short
        skip_pretty = true
      end

      str << @nl if pretty && !skip_pretty

      unless @str.empty?
        str << @inden * (level + 1) if pretty

        if @str.respond_to?(:html_safe?) && @str.html_safe?
          str << @str
        else
          str << HtmlGen.escape_html(@str)
        end

        str << @nl if pretty
      end

      unless @str_html.empty?
        str << @inden * (level + 1) if pretty
        str << @str_html
        str << @nl if pretty
      end

      @eles.each do |subele|
        str << subele.html(pass_args)
      end

      str << @inden * level if pretty && level > 0 && !skip_pretty
      str << "</#{@name}>"
      str << @nl if pretty
    end

    str = str.html_safe if str.respond_to?(:html_safe)
    str
  end

  # Returns the names of all sub-elements in an array.
  def eles_names
    names = []
    @eles.each do |ele|
      names << ele.name
    end

    names
  end

  # Converts the content of the 'style'-attribute to css-hash-content.
  def convert_style_to_css
    if !@attr[:style].to_s.strip.empty?
      style = @attr[:style]
    elsif !@attr["style"].to_s.strip.empty?
      style = @attr["style"]
    else
      raise "No style set in element."
    end

    loop do
      if (match = style.match(/\A\s*(\S+?):\s*(.+?)\s*(;|\Z)/))
        style.gsub!(match[0], "")
        key = match[1]
        val = match[2]
        raise "Such a key already exists in CSS-hash: '#{key}'." if @css.key?(key)
        @css[key] = val
      elsif (match = style.slice!(/\A\s*\Z/))
        break
      else
        raise "Dont know what to do with style-variable: '#{style}'."
      end
    end
  end

  def convert_data_attributes_to_data
    @attr.delete_if do |key, value|
      match = key.to_s.match(/\Adata-(.+)\Z/)

      if match
        data_keys = match[1].split("-")
        last_key = data_keys.pop

        current_data_element = @data
        data_keys.each do |key_part|
          current_data_element = current_data_element[key_part] ||= {}
        end

        current_data_element[last_key] = value

        true
      else
        false
      end
    end
  end

private

  def data_attributes(data_hash, prev_key)
    html = ""
    data_hash.each do |key, value|
      key = key.to_s.tr("_", "-") if key.is_a?(Symbol)

      if value.is_a?(Hash)
        html << " " unless html.empty?
        html << data_attributes(value, "#{prev_key}-#{key}").to_s
      else
        html << " " unless html.empty?
        html << "#{prev_key}-#{key}=\"#{HtmlGen.escape_html(value)}\""
      end
    end

    html
  end
end
