require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Parser" do
  it "should be able generate elements from HTML" do
    parser = Html_gen::Parser.new(:str => "<html><head><title>Test</title></head><body>This is the body</body></html>")
    raise "Expected 1 root element but got: '#{parser.eles.length}'." if parser.eles.length != 1
    
    html = parser.eles.first
    raise "Expected 2 elements of HTML element but got: '#{html.eles.length}'. #{html.eles_names}" if html.eles.length != 2
    
    head = html.eles.first
    title = head.eles.first
    raise "Expected name to be 'title' but it wasnt: '#{title.name}'." if title.name != "title"
  end
end
