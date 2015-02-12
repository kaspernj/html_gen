#A simple, lightweight and pure-Ruby class for parsing HTML-strings into elements.
#===Examples
#  doc = HtmlGen::Parser.new(str: a_html_variable)
#  html_ele = doc.eles.first
#  html_ele.name #=> "html"
class HtmlGen::Parser
  #An array that holds all the parsed root-elements.
  attr_reader :eles

  #The constructor. See class documentation for usage of this.
  def initialize(args)
    if args[:io]
      @io = args[:io]
    elsif args[:str]
      @io = ::StringIO.new(args[:str])
    else
      raise "Dont know how to handle given arguments."
    end

    raise "No ':io' was given." unless @io
    @eof = false
    @buffer = ""
    @eles = []
    @eles_t = []
    @debug = args[:debug]

    while !@eof || !@buffer.empty?
      parse_tag
    end
  end

  private

  #Ensures at least 16kb of data is loaded into the buffer.
  def ensure_buffer
    while @buffer.length < 16384 && !@eof
      str = @io.gets(16384)
      if !str
        @eof = true
      else
        @buffer << str
      end
    end
  end

  #Searches for a given regex. If found the contents is removed from the buffer.
  def search(regex)
    ensure_buffer

    if match = @buffer.match(regex)
      @buffer.gsub!(regex, "")
      ensure_buffer
      return match
    end

    return false
  end

  #Asumes a tag is the next to be parsed and adds it to document-data.
  def parse_tag(args = {})
    if match = search(/\A\s*<\s*(\/|)\s*(\S+?)(\s+|\/\s*>|>)/)
      tag_name = match[2].to_s.strip.downcase
      start_sign = match[1].to_s.strip.downcase
      end_sign = match[3].to_s.strip.downcase

      raise "Dont know how to handle start-sign: '#{start_sign}' for tag: '#{tag_name}'." unless start_sign.empty?

      ele = HtmlGen::Element.new(tag_name)

      if @eles_t.empty?
        puts "Adding element '#{tag_name}' to root elements." if @debug
        @eles << ele
      else
        puts "Adding element '#{tag_name}' to last t-element: '#{@eles_t.last.name}'." if @debug
        @eles_t.last.eles << ele
      end

      @eles_t << ele
      puts "New element-match: #{match.to_a}" if @debug

      if end_sign.match(/^\/\s*>$/)
        puts "End of element '#{tag_name}' for '#{@eles_t.last.name}'." if @debug
        ele = @eles_t.pop
        raise "Expected ele-name to be: '#{tag_name}' but it wasnt: '#{ele.name}'." if ele.name.to_s != tag_name
        return ele
      elsif end_sign.to_s.strip.empty?
        parse_attr_of_tag(ele, tag_name)
        ele.convert_style_to_css if ele.attr.key?("style") || ele.attr.key?(:style)
        return ele
      else
        parse_content_of_tag(ele, tag_name)
        return ele
      end
    else
      if args[:false]
        return false
      else
        raise "Dont know what to do with buffer: '#{@buffer}'."
      end
    end
  end

  #Parses all attributes of the current tag.
  def parse_attr_of_tag(ele, tag_name)
    loop do
      if match = search(/\A\s*(\S+)=(\"|'|)/)
        attr_name = match[1]
        raise "Attribute already exists on element: '#{attr_name}'." if ele.attr.key?(attr_name)

        if match[2].to_s.empty?
          quote_char = /\s+/
          quote_val = :whitespace
        else
          quote_char = /#{Regexp.escape(match[2])}/
          quote_val = :normal
        end

        attr_val = parse_attr_until_quote(quote_char, quote_val)

        puts "Parsed attribute '#{attr_name}' with value '#{attr_val}'." if @debug
        ele.attr[attr_name] = attr_val
      elsif search(/\A\s*>/)
        parse_content_of_tag(ele, tag_name)
        break
      else
        raise "Dont know what to do with buffer when parsing attributes: '#{@buffer}'."
      end
    end
  end

  #Parses an attribute-value until a given quote-char is reached.
  def parse_attr_until_quote(quote_char, quote_val)
    val = ""

    loop do
      ensure_buffer
      char = @buffer.slice!(0)
      break if !char

      if char == "\\"
        val << char
        val << @buffer.slice!(0)
      elsif char =~ quote_char
        break
      elsif char == ">" and quote_val == :whitespace
        @buffer = char + @buffer
        break
      else
        val << char
      end
    end

    return val
  end

  #Assumes some content of a tag is next to be parsed and parses it.
  def parse_content_of_tag(ele, tag_name)
    raise "Empty tag-name given: '#{tag_name}'." if tag_name.to_s.strip.empty?
    raise "No 'ele' was given." if !ele

    loop do
      if search(/\A\s*\Z/)
        raise "Could not find end of tag: '#{tag_name}'."
      elsif match = search(/\A\s*<\s*\/\s*#{Regexp.escape(tag_name)}\s*>\s*/i)
        puts "Found end: '#{match.to_a}' for '#{@eles_t.last.name}'." if @debug
        ele = @eles_t.pop
        raise "Expected ele-name to be: '#{tag_name}' but it wasnt: '#{ele.name}'." if ele.name.to_s != tag_name

        break
      elsif new_ele = parse_tag(false: true)
        puts "Found new element '#{new_ele.name}' and adding it to '#{ele.name}'." if @debug
        #ele.eles << new_ele
      elsif match = search(/\A(.+?)(<|\Z)/)
        puts "Text-content-match: '#{match.to_a}'." if @debug

        #Put end back into buffer.
        @buffer = match[2] + @buffer
        puts "Buffer after text-match: #{@buffer}" if @debug

        #Add text element to list as finished.
        ele.eles << HtmlGen::TextEle.new(str: match[1])
      else
        raise "Dont know what to do with buffer: '#{@buffer}'."
      end
    end
  end
end
