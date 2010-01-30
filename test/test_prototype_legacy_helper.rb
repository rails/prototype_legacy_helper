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
end
