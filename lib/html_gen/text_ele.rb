class HtmlGen::TextEle
  attr_reader :args

  def initialize(args)
    @str = args[:str]
    @inden = args[:inden]
    @nl = args[:nl]
  end

  #Returns the text that this element holds.
  def str
    return @str
  end

  #Returns the text HTML-escaped.
  def html(args)
    if args[:level]
      level = args[:level]
    else
      level = 0
    end

    if !args.key?(:pretty) or args[:pretty]
      pretty = true
    else
      pretty = false
    end

    str = ""
    str << @inden * level if pretty
    str << HtmlGen.escape_html(@str)
    str << @nl if pretty

    return str
  end
end