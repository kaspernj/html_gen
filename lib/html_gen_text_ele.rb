class Html_gen::Text_ele
  attr_reader :args
  
  def initialize(args)
    @str = args[:str]
  end
  
  #Returns the text that this element holds.
  def str
    return @args[:str]
  end
end