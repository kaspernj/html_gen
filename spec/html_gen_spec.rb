require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HtmlGen" do
  it "should be able to generate html" do
    html = Html_gen::Element.new(:td, :classes => [:test]).html(:pretty => false)
    raise "Expected valid HTML." if html != "<td class=\"test\" />"
    
    html = Html_gen::Element.new(:td, :attr => {:colspan => 2}).html(:pretty => false)
    raise "Expected valid HTML." if html != "<td colspan=\"2\" />"
    
    html = Html_gen::Element.new(:td, :css => {:width => "80px"}).html(:pretty => false)
    raise "Expected valid HTML: '#{html}'." if html != "<td style=\"width: 80px;\" />"
    
    a = Html_gen::Element.new(:a)
    b = a.add_ele(:b)
    b.str = "Test"
    
    html = a.html(:pretty => false)
    raise "Expected something else." if html != "<a><b>Test</b></a>"
    
    html = Html_gen::Element.new(:b, :str => "<b>Test</b>").html(:pretty => false)
    raise "Expected escape HTML: '#{html}'." if html != "<b>&lt;b&gt;Test&lt;/b&gt;</b>"
    
    html = Html_gen::Element.new(:b, :str_html => "<b>Test</b>").html(:pretty => false)
    raise "Expected escape HTML: '#{html}'." if html != "<b><b>Test</b></b>"
  end
end
