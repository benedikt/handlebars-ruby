require 'spec_helper'
require 'handlebars'

describe Handlebars::Parser do

  it 'parses helpers with context paths' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{helper context}}</h1>
<h1>{{helper ..}}</h1>
EOF

    expected = [:multi, 
      [:static, "<h1>"], 
      [:mustache, :etag, "helper", "context"], 
      [:static, "</h1>\n<h1>"], 
      [:mustache, :etag, "helper", ".."], 
      [:static, "</h1>\n"]]
    tokens.should eq(expected)
  end

  it 'parses extended paths' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{../../header}}</h1>
<div>{{./header}}
{{hans/hubert/header}}</div>
{{#ines/ingrid/items}}
a
{{/ines/ingrid/items}}
EOF

    expected = [:multi, 
      [:static, "<h1>"], 
      [:mustache, :etag, "../../header", nil],
      [:static, "</h1>\n<div>"],
      [:mustache, :etag, "./header", nil], 
      [:static, "\n"], 
      [:mustache, :etag, "hans/hubert/header", nil],
      [:static, "</div>\n"], 
      [:mustache, :section, "ines/ingrid/items", [:multi, 
        [:static, "a\n"]]]]
    tokens.should eq(expected)
  end

  it 'parses the mustache example' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{header}}</h1>
{{#items}}
{{#first}}
  <li><strong>{{name}}</strong></li>
{{/first}}
{{#link}}
  <li><a href="{{url}}">{{name}}</a></li>
{{/link}}
{{/items}}

{{#empty}}
<p>The list is empty.</p>
{{/empty}}
EOF

    expected = [:multi,
      [:static, "<h1>"],
      [:mustache, :etag, "header", nil],
      [:static, "</h1>\n"],
      [:mustache,
        :section,
        "items",
        [:multi,
          [:mustache,
            :section,
            "first",
            [:multi,
              [:static, "<li><strong>"],
              [:mustache, :etag, "name", nil],
              [:static, "</strong></li>\n"]]],
          [:mustache,
            :section,
            "link",
            [:multi,
              [:static, "<li><a href=\""],
              [:mustache, :etag, "url", nil],
              [:static, "\">"],
              [:mustache, :etag, "name", nil],
              [:static, "</a></li>\n"]]]]],
      [:mustache,
        :section,
        "empty",
        [:multi, [:static, "<p>The list is empty.</p>\n"]]]]

    tokens.should eq(expected)
  end
end
