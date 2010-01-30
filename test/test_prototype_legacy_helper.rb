require 'test/unit'
require 'prototype_legacy_helper'

class TestPrototypeLegacyHelper < ActionView::TestCase
  def test_observe_form
    assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Form.Observer('cart', 2, function(element, value) {new Ajax.Request('http://www.example.com/cart_changed', {asynchronous:true, evalScripts:true, parameters:value})})\n//]]>\n</script>),
      observe_form("cart", :frequency => 2, :url => { :action => "cart_changed" })
  end

  def test_observe_form_using_function_for_callback
    assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Form.Observer('cart', 2, function(element, value) {alert('Form changed')})\n//]]>\n</script>),
      observe_form("cart", :frequency => 2, :function => "alert('Form changed')")
  end

  def test_observe_field
    assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Form.Element.Observer('glass', 300, function(element, value) {new Ajax.Request('http://www.example.com/reorder_if_empty', {asynchronous:true, evalScripts:true, parameters:value})})\n//]]>\n</script>),
      observe_field("glass", :frequency => 5.minutes, :url => { :action => "reorder_if_empty" })
  end

  def test_observe_field_using_with_option
    expected = %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Form.Element.Observer('glass', 300, function(element, value) {new Ajax.Request('http://www.example.com/check_value', {asynchronous:true, evalScripts:true, parameters:'id=' + encodeURIComponent(value)})})\n//]]>\n</script>)
    assert_dom_equal expected, observe_field("glass", :frequency => 5.minutes, :url => { :action => "check_value" }, :with => 'id')
    assert_dom_equal expected, observe_field("glass", :frequency => 5.minutes, :url => { :action => "check_value" }, :with => "'id=' + encodeURIComponent(value)")
  end

  def test_observe_field_using_json_in_with_option
    expected = %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Form.Element.Observer('glass', 300, function(element, value) {new Ajax.Request('http://www.example.com/check_value', {asynchronous:true, evalScripts:true, parameters:{'id':value}})})\n//]]>\n</script>)
    assert_dom_equal expected, observe_field("glass", :frequency => 5.minutes, :url => { :action => "check_value" }, :with => "{'id':value}")
  end

  def test_observe_field_using_function_for_callback
    assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Form.Element.Observer('glass', 300, function(element, value) {alert('Element changed')})\n//]]>\n</script>),
      observe_field("glass", :frequency => 5.minutes, :function => "alert('Element changed')")
  end

  def test_observe_field_without_frequency
    assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Form.Element.EventObserver('glass', function(element, value) {new Ajax.Request('http://www.example.com/', {asynchronous:true, evalScripts:true, parameters:value})})\n//]]>\n</script>),
      observe_field("glass")
  end


  def test_periodically_call_remote
    assert_dom_equal %(<script type="text/javascript">\n//<![CDATA[\nnew PeriodicalExecuter(function() {new Ajax.Updater('schremser_bier', 'http://www.example.com/mehr_bier', {asynchronous:true, evalScripts:true})}, 10)\n//]]>\n</script>),
      periodically_call_remote(:update => "schremser_bier", :url => { :action => "mehr_bier" })
  end

  def test_periodically_call_remote_with_frequency
    assert_dom_equal(
      "<script type=\"text/javascript\">\n//<![CDATA[\nnew PeriodicalExecuter(function() {new Ajax.Request('http://www.example.com/', {asynchronous:true, evalScripts:true})}, 2)\n//]]>\n</script>",
      periodically_call_remote(:frequency => 2)
    )
  end


  def test_link_to_remote
    assert_dom_equal %(<a class=\"fine\" href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot', {asynchronous:true, evalScripts:true}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", { :url => { :action => "whatnot"  }}, { :class => "fine"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot', {asynchronous:true, evalScripts:true, onComplete:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", :complete => "alert(request.responseText)", :url => { :action => "whatnot"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot', {asynchronous:true, evalScripts:true, onSuccess:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", :success => "alert(request.responseText)", :url => { :action => "whatnot"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot', {asynchronous:true, evalScripts:true, onFailure:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", :failure => "alert(request.responseText)", :url => { :action => "whatnot"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?a=10&amp;b=20', {asynchronous:true, evalScripts:true, onFailure:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", :failure => "alert(request.responseText)", :url => { :action => "whatnot", :a => '10', :b => '20' })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot', {asynchronous:false, evalScripts:true}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", :url => { :action => "whatnot" }, :type => :synchronous)
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot', {asynchronous:true, evalScripts:true, insertion:'bottom'}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", :url => { :action => "whatnot" }, :position => :bottom)
  end

  def test_link_to_remote_html_options
    assert_dom_equal %(<a class=\"fine\" href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot', {asynchronous:true, evalScripts:true}); return false;\">Remote outauthor</a>),
      link_to_remote("Remote outauthor", { :url => { :action => "whatnot"  }, :html => { :class => "fine" } })
  end

  def test_link_to_remote_url_quote_escaping
    assert_dom_equal %(<a href="#" onclick="new Ajax.Request('http://www.example.com/whatnot\\\'s', {asynchronous:true, evalScripts:true}); return false;">Remote</a>),
      link_to_remote("Remote", { :url => { :action => "whatnot's" } })
  end

  def test_link_to_function
    assert_dom_equal %(<a href="#" onclick="alert('Hello world!'); return false;">Greeting</a>),
      link_to_function("Greeting", "alert('Hello world!')")
  end

  def test_link_to_function_with_existing_onclick
    assert_dom_equal %(<a href="#" onclick="confirm('Sanity!'); alert('Hello world!'); return false;">Greeting</a>),
      link_to_function("Greeting", "alert('Hello world!')", :onclick => "confirm('Sanity!')")
  end

  def test_link_to_function_with_rjs_block
    html = link_to_function( "Greet me!" ) do |page|
      page.replace_html 'header', "<h1>Greetings</h1>"
    end
    assert_dom_equal %(<a href="#" onclick="Element.update(&quot;header&quot;, &quot;\\u003Ch1\\u003EGreetings\\u003C/h1\\u003E&quot;);; return false;">Greet me!</a>), html
  end

  def test_link_to_function_with_rjs_block_and_options
    html = link_to_function( "Greet me!", :class => "updater" ) do |page|
      page.replace_html 'header', "<h1>Greetings</h1>"
    end
    assert_dom_equal %(<a href="#" class="updater" onclick="Element.update(&quot;header&quot;, &quot;\\u003Ch1\\u003EGreetings\\u003C/h1\\u003E&quot;);; return false;">Greet me!</a>), html
  end

  def test_link_to_function_with_href
    assert_dom_equal %(<a href="http://example.com/" onclick="alert('Hello world!'); return false;">Greeting</a>),
      link_to_function("Greeting", "alert('Hello world!')", :href => 'http://example.com/')
  end
end
