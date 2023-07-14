require "spec_helper"

describe HtmlGen do
  it "generates elements with classes" do
    html = HtmlGen::Element.new(:td, classes: [:test]).html(pretty: false)
    expect(html).to eq "<td class=\"test\" />"
  end

  it "generates elements with attributes" do
    html = HtmlGen::Element.new(:td, attr: {colspan: 2}).html(pretty: false)
    expect(html).to eq "<td colspan=\"2\" />"
  end

  it "generates elements with css attributes" do
    html = HtmlGen::Element.new(:td, css: {width: "80px"}).html(pretty: false)
    expect(html).to eq "<td style=\"width: 80px;\" />"
  end

  it "generates elements with sub elementes" do
    a = HtmlGen::Element.new(:a)
    b = a.add_ele(:b)
    b.str = "Test"

    html = a.html(pretty: false)
    expect(html).to eq "<a><b>Test</b></a>"
  end

  it "generates elements with string content and escapes it" do
    html = HtmlGen::Element.new(:b, str: "<b>Test</b>").html(pretty: false)
    expect(html).to eq "<b>&lt;b&gt;Test&lt;/b&gt;</b>"
  end

  it "generates elements with html content and doesn't escape it" do
    html = HtmlGen::Element.new(:b, str_html: "<b>Test</b>").html(pretty: false)
    expect(html).to eq "<b><b>Test</b></b>"
  end

  it "supports mixed elements and string content" do
    div_ele = HtmlGen::Element.new(:div)
    div_ele.add_ele(:br)
    div_ele.add_str("This is a test")

    html = div_ele.html(pretty: false)
    expect(html).to eq "<div><br />This is a test</div>"
  end

  it "#add_html" do
    div_ele = HtmlGen::Element.new(:div)
    div_ele.add_ele(:br)
    div_ele.add_str("This is a test")
    div_ele.add_html("<b>test</b>")

    html = div_ele.html(pretty: false)
    expect(html).to eq "<div><br />This is a test<b>test</b></div>"
  end

  it "supports data attributes" do
    HtmlGen::Element.new(:div, str: "Test", data: {test: "value"})
  end

  it "supports nested data attributes" do
    div_ele = HtmlGen::Element.new(:div, str: "Test", data: {deep: {nested: {test: "value", test_underscoe: "test"}}})
    expect(div_ele.html(pretty: false)).to eq "<div data-deep-nested-test=\"value\" data-deep-nested-test-underscoe=\"test\">Test</div>"
  end

  it "supports text elements" do
    div_ele = HtmlGen::Element.new(:div)
    div_ele.add_str "test"

    expect(div_ele.html).to eq "<div>\n  test\n</div>\n"
  end

  it "adds recursive sub elements correctly" do
    progress = HtmlGen::Element.new(:div, classes: ["progress"])
    progress_bar = progress.add_ele(:div, classes: ["progress-bar"])
    progress_bar_text = progress.add_ele(:div, classes: ["bb-progress-bar-text"], str: "Test")

    expect(progress.eles.length).to eq 2
    expect(progress_bar.eles.length).to eq 0
    expect(progress_bar_text.eles.length).to eq 0

    html = progress.html(pretty: false)

    expect(html).to eq "<div class=\"progress\"><div class=\"progress-bar\"></div><div class=\"bb-progress-bar-text\">Test</div></div>"
  end
end
