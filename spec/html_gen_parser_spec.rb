require "spec_helper"

describe "Parser" do
  let(:parser) { HtmlGen::Parser.new(str: "<html><head><title>Test</title></head><body>This is the body</body></html>") }
  let(:doc) do
    HtmlGen::Parser.new(
      str: "<td colspan=\"2\" data-test=\"test-value\" data-nested-test=\"test-nested-keys\" style=\"font-weight: bold;\" width='100px' height=50px>test</td>"
    )
  end
  let(:td) { doc.eles.first }

  it "detects a single root element" do
    expect(parser.eles.length).to eq 1
  end

  it "detects the head and body element under the html element" do
    html = parser.eles.first
    expect(html.eles.length).to eq 2
  end

  it "reads the head-title element content correct" do
    head = parser.eles.first.eles.first
    title = head.eles.first
    expect(title.name).to eq "title"
  end

  it "reads the td elements name" do
    expect(td.name).to eq "td"
  end

  it "detects html attributes" do
    expect(td.attr).to include(
      "colspan" => "2",
      "width" => "100px",
      "height" => "50px"
    )
  end

  it "detects data attributes" do
    expect(td.data["test"]).to eq "test-value"
  end

  it "detects nested data key attributes" do
    expect(td.data["nested"]["test"]).to eq "test-nested-keys"
  end

  it "removes the original attributes" do
    expect(td.attr["data-test"]).to be_nil
    expect(td.attr["data-nested-test"]).to be_nil
  end

  it "detects CSS attributes" do
    expect(td.css["font-weight"]).to eq "bold"
    expect(td.attr["style"].to_s).to be_empty
  end
end
