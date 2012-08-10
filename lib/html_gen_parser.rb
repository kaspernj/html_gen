class Html_gen::Parser
  attr_reader :eles
  
  def initialize(args)
    if args[:io]
      @io = args[:io]
    elsif args[:str]
      @io = StringIO.new(args[:str])
    else
      raise "Dont know how to handle given arguments."
    end
    
    raise "No ':io' was given." if !@io
    @eof = false
    @buffer = ""
    @eles = []
    @eles_t = []
    @debug = args[:debug]
    
    while !@eof or !@buffer.empty?
      parse_tag
    end
  end
  
  private
  
  def ensure_buffer
    while @buffer.length < 16384 and !@eof
      str = @io.gets(16384)
      if !str
        @eof = true
      else
        @buffer << str
      end
    end
  end
  
  def search(regex)
    if match = @buffer.match(regex)
      @buffer.gsub!(regex, "")
      
      return match
    end
    
    return false
  end
  
  def parse_tag(args = {})
    ensure_buffer
    
    if match = search(/\A\s*<\s*(\/|)\s*(\S+?)(\s+|\/\s*>|>)/)
      tag_name = match[2].to_s.strip.downcase
      start_sign = match[1].to_s.strip.downcase
      end_sign = match[3].to_s.strip.downcase
      
      raise "Dont know how to handle start-sign: '#{start_sign}' for tag: '#{tag_name}'." if !start_sign.empty?
      
      ele = Html_gen::Element.new(tag_name)
      
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
  
  def parse_content_of_tag(ele, tag_name)
    ensure_buffer
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
      elsif new_ele = parse_tag(:false => true)
        puts "Found new element '#{new_ele.name}' and adding it to '#{ele.name}'." if @debug
        #ele.eles << new_ele
      elsif match = search(/\A(.+?)(<|\Z)/)
        puts "Text-content-match: '#{match.to_a}'." if @debug
        
        #Put end back into buffer.
        @buffer = match[2] + @buffer
        puts "Buffer after text-match: #{@buffer}" if @debug
        
        #Add text element to list as finished.
        ele.eles << Html_gen::Text_ele.new(:str => match[1])
      else
        raise "Dont know what to do with buffer: '#{@buffer}'."
      end
    end
  end
end