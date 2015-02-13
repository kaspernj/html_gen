[![Build Status](https://api.shippable.com/projects/540e7b9b3479c5ea8f9ec21c/badge?branchName=master)](https://app.shippable.com/projects/540e7b9b3479c5ea8f9ec21c/builds/latest)
[![Code Climate](https://codeclimate.com/github/kaspernj/html_gen/badges/gpa.svg)](https://codeclimate.com/github/kaspernj/html_gen)
[![Test Coverage](https://codeclimate.com/github/kaspernj/html_gen/badges/coverage.svg)](https://codeclimate.com/github/kaspernj/html_gen)

# HtmlGen

A small and fast framework to parse and generate HTML in Ruby.

## Install

Add to your Gemfile and bundle:

```ruby
gem "html_gen"
```

## Usage

### Generate elements

```ruby
div = HtmlGen::Element.new(:div, classes: ["class1", "class2"], attr: {width: "100px"}, css: {height: "50px"})
div.add_str "Hello world"

p = div.add_ele(:p)
p.add_str "Test"

div.html #=> '<div width="100px" style="height: 50px;" class="class1 class2">Hello world<p>Test</p></div>'
```

### Parse HTML into elements

```ruby
parser = HtmlGen::Parser.new(str: "<html><head><title>Test</title></head><body>This is the body</body></html>")
html = parser.eles.first
head = html.eles.first

head.name #=> "head"

title = head.eles.first
title.html #=> "Test"
title.attr #=> {}
title.css #=> {}
title.data #=> {}
```

## Contributing to html_gen

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kasper Johansen. See LICENSE.txt for
further details.

