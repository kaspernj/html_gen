require "spec_helper"

describe HtmlGen::Element do
  describe "#add_html_if_safe" do
    it "returns esacped html when not html safe" do
      element = HtmlGen::Element.new(:div)
      element.add_html_if_safe("<b>Hello world</b>")

      expect(element.html(pretty: false)).to eq "<div>&lt;b&gt;Hello world&lt;/b&gt;</div>"
    end

    it "returns unescaped html when html safe" do
      element = HtmlGen::Element.new(:div)

      string_stub = "<b>Hello world</b>"
      expect(string_stub).to receive(:html_safe?).and_return(true)

      element.add_html_if_safe(string_stub)

      expect(element.html(pretty: false)).to eq "<div><b>Hello world</b></div>"
    end
  end
end
