require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HtmlGen" do
  it "should be able to generate html" do
    html = Html_gen::Element.new(:td, :classes => [:test]).html
    raise "Expected valid HTML." if html != "<td class=\"test\" />"
    
    html = Html_gen::Element.new(:td, :attr => {:colspan => 2}).html
    raise "Expected valid HTML." if html != "<td colspan=\"2\" />"
    
    html = Html_gen::Element.new(:td, :css => {:width => "80px"}).html
    raise "Expected valid HTML: '#{html}'." if html != "<td style=\"width: 80px;\" />"
  end
end
