module PrototypeLegacyHelper
  # Observes the field with the DOM ID specified by +field_id+ and calls a
  # callback when its contents have changed. The default callback is an
  # Ajax call. By default the value of the observed field is sent as a
  # parameter with the Ajax call.
  #
  # Example:
  #  # Generates: new Form.Element.Observer('suggest', 0.25, function(element, value) {new Ajax.Updater('suggest',
  #  #         '/testing/find_suggestion', {asynchronous:true, evalScripts:true, parameters:'q=' + value})})
  #  <%= observe_field :suggest, :url => { :action => :find_suggestion },
  #       :frequency => 0.25,
  #       :update => :suggest,
  #       :with => 'q'
  #       %>
  #
  # Required +options+ are either of:
  # <tt>:url</tt>::       +url_for+-style options for the action to call
  #                       when the field has changed.
  # <tt>:function</tt>::  Instead of making a remote call to a URL, you
  #                       can specify javascript code to be called instead.
  #                       Note that the value of this option is used as the
  #                       *body* of the javascript function, a function definition
  #                       with parameters named element and value will be generated for you
  #                       for example:
  #                         observe_field("glass", :frequency => 1, :function => "alert('Element changed')")
  #                       will generate:
  #                         new Form.Element.Observer('glass', 1, function(element, value) {alert('Element changed')})
  #                       The element parameter is the DOM element being observed, and the value is its value at the
  #                       time the observer is triggered.
  #
  # Additional options are:
  # <tt>:frequency</tt>:: The frequency (in seconds) at which changes to
  #                       this field will be detected. Not setting this
  #                       option at all or to a value equal to or less than
  #                       zero will use event based observation instead of
  #                       time based observation.
  # <tt>:update</tt>::    Specifies the DOM ID of the element whose
  #                       innerHTML should be updated with the
  #                       XMLHttpRequest response text.
  # <tt>:with</tt>::      A JavaScript expression specifying the parameters
  #                       for the XMLHttpRequest. The default is to send the
  #                       key and value of the observed field. Any custom
  #                       expressions should return a valid URL query string.
  #                       The value of the field is stored in the JavaScript
  #                       variable +value+.
  #
  #                       Examples
  #
  #                         :with => "'my_custom_key=' + value"
  #                         :with => "'person[name]=' + prompt('New name')"
  #                         :with => "Form.Element.serialize('other-field')"
  #
  #                       Finally
  #                         :with => 'name'
  #                       is shorthand for
  #                         :with => "'name=' + value"
  #                       This essentially just changes the key of the parameter.
  #
  # Additionally, you may specify any of the options documented in the
  # <em>Common options</em> section at the top of this document.
  #
  # Example:
  #
  #   # Sends params: {:title => 'Title of the book'} when the book_title input
  #   # field is changed.
  #   observe_field 'book_title',
  #     :url => 'http://example.com/books/edit/1',
  #     :with => 'title'
  #
  #
  def observe_field(field_id, options = {})
    if options[:frequency] && options[:frequency] > 0
      build_observer('Form.Element.Observer', field_id, options)
    else
      build_observer('Form.Element.EventObserver', field_id, options)
    end
  end

  # Observes the form with the DOM ID specified by +form_id+ and calls a
  # callback when its contents have changed. The default callback is an
  # Ajax call. By default all fields of the observed field are sent as
  # parameters with the Ajax call.
  #
  # The +options+ for +observe_form+ are the same as the options for
  # +observe_field+. The JavaScript variable +value+ available to the
  # <tt>:with</tt> option is set to the serialized form by default.
  def observe_form(form_id, options = {})
    if options[:frequency]
      build_observer('Form.Observer', form_id, options)
    else
      build_observer('Form.EventObserver', form_id, options)
    end
  end

  protected
    def build_observer(klass, name, options = {})
      if options[:with] && (options[:with] !~ /[\{=(.]/)
        options[:with] = "'#{options[:with]}=' + encodeURIComponent(value)"
      else
        options[:with] ||= 'value' unless options[:function]
      end

      callback = options[:function] || remote_function(options)
      javascript  = "new #{klass}('#{name}', "
      javascript << "#{options[:frequency]}, " if options[:frequency]
      javascript << "function(element, value) {"
      javascript << "#{callback}}"
      javascript << ")"
      javascript_tag(javascript)
    end
end
