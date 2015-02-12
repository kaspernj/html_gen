require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Parser" do
  let(:parser) { HtmlGen::Parser.new(str: "<html><head><title>Test</title></head><body>This is the body</body></html>") }
  let(:doc) { HtmlGen::Parser.new(str: "<td colspan=\"2\" style=\"font-weight: bold;\" width='100px' height=50px>test</td>") }
  let(:td) { doc.eles.first }

  it "detects a single root element" do
    parser.eles.length.should eq 1
  end

  it "detects the head and body element under the html element" do
    html = parser.eles.first
    html.eles.length.should eq 2
  end

  it "reads the head-title element content correct" do
    head = parser.eles.first.eles.first
    title = head.eles.first
    title.name.should eq "title"
  end

  it "reads the td elements name" do
    td.name.should eq "td"
  end

  it "detects html attributes" do
    td.attr["colspan"].should eq "2"
    td.attr["width"].should eq "100px"
    td.attr["height"].should eq "50px"
  end

  it "detects CSS attributes" do
    td.css["font-weight"].should eq "bold"
    td.attr["style"].to_s.empty?.should eq true
  end
end
