require "spec_helper"

describe "HtmlGen" do
  it "generates elements with classes" do
    html = HtmlGen::Element.new(:td, classes: [:test]).html(pretty: false)
    html.should eq "<td class=\"test\" />"
  end

  it "generates elements with attributes" do
    html = HtmlGen::Element.new(:td, attr: {colspan: 2}).html(pretty: false)
    html.should eq "<td colspan=\"2\" />"
  end

  it "generates elements with css attributes" do
    html = HtmlGen::Element.new(:td, css: {width: "80px"}).html(pretty: false)
    html.should eq "<td style=\"width: 80px;\" />"
  end

  it "generates elements with sub elementes" do
    a = HtmlGen::Element.new(:a)
    b = a.add_ele(:b)
    b.str = "Test"

    html = a.html(pretty: false)
    html.should eq "<a><b>Test</b></a>"
  end

  it "generates elements with string content and escapes it" do
    html = HtmlGen::Element.new(:b, str: "<b>Test</b>").html(pretty: false)
    html.should eq "<b>&lt;b&gt;Test&lt;/b&gt;</b>"
  end

  it "generates elements with html content and doesn't escape it" do
    html = HtmlGen::Element.new(:b, str_html: "<b>Test</b>").html(pretty: false)
    html.should eq "<b><b>Test</b></b>"
  end

  it "supports mixed elements and string content" do
    div_ele = HtmlGen::Element.new(:div)
    div_ele.add_ele(:br)
    div_ele.add_str("This is a test")

    html = div_ele.html(pretty: false)
    html.should eq "<div><br />This is a test</div>"
  end

  it "#add_html" do
    div_ele = HtmlGen::Element.new(:div)
    div_ele.add_ele(:br)
    div_ele.add_str("This is a test")
    div_ele.add_html("<b>test</b>")

    html = div_ele.html(pretty: false)
    html.should eq "<div><br />This is a test<b>test</b></div>"
  end

  it "supports data attributes" do
    div_ele = HtmlGen::Element.new(:div, str: "Test", data: {test: "value"})
  end

  it "supports nested data attributes" do
    div_ele = HtmlGen::Element.new(:div, str: "Test", data: {deep: {nested: {test: "value"}}})
    div_ele.html(pretty: false).should eq "<div data-deep-nested-test=\"value\">Test</div>"
  end
end
