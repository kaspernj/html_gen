class HtmlGen::TextEle
  attr_reader :args

  def initialize(args)
    @str = args[:str]
    @html = args[:html]
    @inden = args[:inden]
    @nl = args[:nl]
  end

  # Returns the text that this element holds.
  attr_reader :str

  # Returns the text HTML-escaped.
  def html(args)
    str = ""
    str << @inden * level(args) if pretty?(args)
    str << html_content
    str << @nl if pretty?(args)
    str
  end

private

  def pretty?(args)
    !args.key?(:pretty) || args[:pretty]
  end

  def level(args)
    args[:level] || 0
  end

  def html_content
    if @str
      HtmlGen.escape_html(@str)
    else
      @html
    end
  end
end
