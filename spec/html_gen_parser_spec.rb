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
    
    doc = Html_gen::Parser.new(:str => "<td colspan=\"2\" style=\"font-weight: bold;\" width='100px' height=50px>test</td>")
    td = doc.eles.first
    
    raise "Expected name of element to be 'td' but it wasnt: '#{td.name}'." if td.name != "td"
    raise "Expected colspan to be '2' but it wasnt: '#{td.attr["colspan"]}'." if td.attr["colspan"] != "2"
    raise "Expected width to be '100px' but it wasnt: '#{td.attr["width"]}'." if td.attr["width"] != "100px"
    raise "Expected height to be '50px' but it wasnt: '#{td.attr["height"]}'." if td.attr["height"] != "50px"
    raise "Expected CSS-font-weight to be 'bold' but it wasnt: '#{td.css["font-weight"]}'." if td.css["font-weight"] != "bold"
    raise "Expected style to be empty but it wasnt: '#{td.attr["style"]}'." if !td.attr["style"].to_s.empty?
  end
end
