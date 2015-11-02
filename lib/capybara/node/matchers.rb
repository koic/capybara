# frozen_string_literal: true
module Capybara
  module Node
    module Matchers

      ##
      #
      # Checks if a given selector is on the page or current node.
      #
      #     page.has_selector?('p#foo')
      #     page.has_selector?(:xpath, './/p[@id="foo"]')
      #     page.has_selector?(:foo)
      #
      # By default it will check if the expression occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_selector?('p.foo', :count => 4)
      #
      # This will check if the expression occurs exactly 4 times.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as :text and :visible.
      #
      #     page.has_selector?('li', :text => 'Horse', :visible => true)
      #
      # has_selector? can also accept XPath expressions generated by the
      # XPath gem:
      #
      #     page.has_selector?(:xpath, XPath.descendant(:p))
      #
      # @param (see Capybara::Node::Finders#all)
      # @param args
      # @option args [Integer] :count (nil)     Number of times the text should occur
      # @option args [Integer] :minimum (nil)   Minimum number of times the text should occur
      # @option args [Integer] :maximum (nil)   Maximum number of times the text should occur
      # @option args [Range]   :between (nil)   Range of times that should contain number of times text occurs
      # @return [Boolean]                       If the expression exists
      #
      def has_selector?(*args)
        assert_selector(*args)
      rescue Capybara::ExpectationNotMet
        return false
      end

      ##
      #
      # Checks if a given selector is not on the page or current node.
      # Usage is identical to Capybara::Node::Matchers#has_selector?
      #
      # @param (see Capybara::Node::Finders#has_selector?)
      # @return [Boolean]
      #
      def has_no_selector?(*args)
        assert_no_selector(*args)
      rescue Capybara::ExpectationNotMet
        return false
      end

      ##
      #
      # Checks if the current node matches given selector
      # Usage is identical to Capybara::Node::Matchers#has_selector?
      #
      # @param (see Capybara::Node::Finders#has_selector?)
      # @return [Boolean]
      #
      def matches_selector?(*args)
        assert_matches_selector(*args)
      rescue Capybara::ExpectationNotMet
        return false
      end


      ##
      #
      # Checks if the current node does not match given selector
      # Usage is identical to Capybara::Node::Matchers#has_selector?
      #
      # @param (see Capybara::Node::Finders#has_selector?)
      # @return [Boolean]
      #
      def not_matches_selector?(*args)
        assert_not_matches_selector(*args)
      rescue Capybara::ExpectationNotMet
        return false
      end


      ##
      #
      # Asserts that a given selector is on the page or current node.
      #
      #     page.assert_selector('p#foo')
      #     page.assert_selector(:xpath, './/p[@id="foo"]')
      #     page.assert_selector(:foo)
      #
      # By default it will check if the expression occurs at least once,
      # but a different number can be specified.
      #
      #     page.assert_selector('p#foo', :count => 4)
      #
      # This will check if the expression occurs exactly 4 times. See
      # {Capybara::Node::Finders#all} for other available result size options.
      #
      # If a :count of 0 is specified, it will behave like {#assert_no_selector};
      # however, use of that method is preferred over this one.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as :text and :visible.
      #
      #     page.assert_selector('li', :text => 'Horse', :visible => true)
      #
      # `assert_selector` can also accept XPath expressions generated by the
      # XPath gem:
      #
      #     page.assert_selector(:xpath, XPath.descendant(:p))
      #
      # @param (see Capybara::Node::Finders#all)
      # @option options [Integer] :count (nil)    Number of times the expression should occur
      # @raise [Capybara::ExpectationNotMet]      If the selector does not exist
      #
      def assert_selector(*args)
        query = Capybara::Queries::SelectorQuery.new(*args)
        synchronize(query.wait) do
          result = query.resolve_for(self)
          matches_count = Capybara::Helpers.matches_count?(result.size, query.options)
          unless matches_count && ((result.size > 0) || Capybara::Helpers.expects_none?(query.options))
            raise Capybara::ExpectationNotMet, result.failure_message
          end
        end
        return true
      end

      ##
      #
      # Asserts that a given selector is not on the page or current node.
      # Usage is identical to Capybara::Node::Matchers#assert_selector
      #
      # Query options such as :count, :minimum, :maximum, and :between are
      # considered to be an integral part of the selector. This will return
      # true, for example, if a page contains 4 anchors but the query expects 5:
      #
      #     page.assert_no_selector('a', :minimum => 1) # Found, raises Capybara::ExpectationNotMet
      #     page.assert_no_selector('a', :count => 4)   # Found, raises Capybara::ExpectationNotMet
      #     page.assert_no_selector('a', :count => 5)   # Not Found, returns true
      #
      # @param (see Capybara::Node::Finders#assert_selector)
      # @raise [Capybara::ExpectationNotMet]      If the selector exists
      #
      def assert_no_selector(*args)
        query = Capybara::Queries::SelectorQuery.new(*args)
        synchronize(query.wait) do
          result = query.resolve_for(self)
          matches_count = Capybara::Helpers.matches_count?(result.size, query.options)
          if matches_count && ((result.size > 0) || Capybara::Helpers.expects_none?(query.options))
            raise Capybara::ExpectationNotMet, result.negative_failure_message
          end
        end
        return true
      end
      alias_method :refute_selector, :assert_no_selector

      ##
      #
      # Asserts that the current_node matches a given selector
      #
      #     node.assert_matches_selector('p#foo')
      #     node.assert_matches_selector(:xpath, '//p[@id="foo"]')
      #     node.assert_matches_selector(:foo)
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as :text and :visible.
      #
      #     node.assert_matches_selector('li', :text => 'Horse', :visible => true)
      #
      # @param (see Capybara::Node::Finders#all)
      # @raise [Capybara::ExpectationNotMet]      If the selector does not match
      #
      def assert_matches_selector(*args)
        query = Capybara::Queries::MatchQuery.new(*args)
        synchronize(query.wait) do
          result = query.resolve_for(self.query_scope)
          unless result.include? self
            raise Capybara::ExpectationNotMet, "Item does not match the provided selector"
          end
        end
        return true
      end

      def assert_not_matches_selector(*args)
        query = Capybara::Queries::MatchQuery.new(*args)
        synchronize(query.wait) do
          result = query.resolve_for(self.query_scope)
          if result.include? self
            raise Capybara::ExpectationNotMet, 'Item matched the provided selector'
          end
        end
        return true
      end
      alias_method :refute_matches_selector, :assert_not_matches_selector

      ##
      #
      # Checks if a given XPath expression is on the page or current node.
      #
      #     page.has_xpath?('.//p[@id="foo"]')
      #
      # By default it will check if the expression occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_xpath?('.//p[@id="foo"]', :count => 4)
      #
      # This will check if the expression occurs exactly 4 times.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as :text and :visible.
      #
      #     page.has_xpath?('.//li', :text => 'Horse', :visible => true)
      #
      # has_xpath? can also accept XPath expressions generate by the
      # XPath gem:
      #
      #     xpath = XPath.generate { |x| x.descendant(:p) }
      #     page.has_xpath?(xpath)
      #
      # @param [String] path                      An XPath expression
      # @param options                            (see Capybara::Node::Finders#all)
      # @option options [Integer] :count (nil)    Number of times the expression should occur
      # @return [Boolean]                         If the expression exists
      #
      def has_xpath?(path, options={})
        has_selector?(:xpath, path, options)
      end

      ##
      #
      # Checks if a given XPath expression is not on the page or current node.
      # Usage is identical to Capybara::Node::Matchers#has_xpath?
      #
      # @param (see Capybara::Node::Finders#has_xpath?)
      # @return [Boolean]
      #
      def has_no_xpath?(path, options={})
        has_no_selector?(:xpath, path, options)
      end

      ##
      #
      # Checks if a given CSS selector is on the page or current node.
      #
      #     page.has_css?('p#foo')
      #
      # By default it will check if the selector occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_css?('p#foo', :count => 4)
      #
      # This will check if the selector occurs exactly 4 times.
      #
      # It also accepts all options that {Capybara::Node::Finders#all} accepts,
      # such as :text and :visible.
      #
      #     page.has_css?('li', :text => 'Horse', :visible => true)
      #
      # @param [String] path                      A CSS selector
      # @param options                            (see Capybara::Node::Finders#all)
      # @option options [Integer] :count (nil)    Number of times the selector should occur
      # @return [Boolean]                         If the selector exists
      #
      def has_css?(path, options={})
        has_selector?(:css, path, options)
      end

      ##
      #
      # Checks if a given CSS selector is not on the page or current node.
      # Usage is identical to Capybara::Node::Matchers#has_css?
      #
      # @param (see Capybara::Node::Finders#has_css?)
      # @return [Boolean]
      #
      def has_no_css?(path, options={})
        has_no_selector?(:css, path, options)
      end

      ##
      #
      # Checks if the page or current node has a link with the given
      # text or id.
      #
      # @param [String] locator           The text or id of a link to check for
      # @param options
      # @option options [String, Regexp] :href    The value the href attribute must be
      # @return [Boolean]                 Whether it exists
      #
      def has_link?(locator, options={})
        has_selector?(:link, locator, options)
      end

      ##
      #
      # Checks if the page or current node has no link with the given
      # text or id.
      #
      # @param (see Capybara::Node::Finders#has_link?)
      # @return [Boolean]            Whether it doesn't exist
      #
      def has_no_link?(locator, options={})
        has_no_selector?(:link, locator, options)
      end

      ##
      #
      # Checks if the page or current node has a button with the given
      # text, value or id.
      #
      # @param [String] locator      The text, value or id of a button to check for
      # @return [Boolean]            Whether it exists
      #
      def has_button?(locator, options={})
        has_selector?(:button, locator, options)
      end

      ##
      #
      # Checks if the page or current node has no button with the given
      # text, value or id.
      #
      # @param [String] locator      The text, value or id of a button to check for
      # @return [Boolean]            Whether it doesn't exist
      #
      def has_no_button?(locator, options={})
        has_no_selector?(:button, locator, options)
      end

      ##
      #
      # Checks if the page or current node has a form field with the given
      # label, name or id.
      #
      # For text fields and other textual fields, such as textareas and
      # HTML5 email/url/etc. fields, it's possible to specify a :with
      # option to specify the text the field should contain:
      #
      #     page.has_field?('Name', :with => 'Jonas')
      #
      # It is also possible to filter by the field type attribute:
      #
      #     page.has_field?('Email', :type => 'email')
      #
      # Note: 'textarea' and 'select' are valid type values, matching the associated tag names.
      #
      # @param [String] locator           The label, name or id of a field to check for
      # @option options [String] :with    The text content of the field
      # @option options [String] :type    The type attribute of the field
      # @return [Boolean]                 Whether it exists
      #
      def has_field?(locator, options={})
        has_selector?(:field, locator, options)
      end

      ##
      #
      # Checks if the page or current node has no form field with the given
      # label, name or id. See {Capybara::Node::Matchers#has_field?}.
      #
      # @param [String] locator           The label, name or id of a field to check for
      # @option options [String] :with    The text content of the field
      # @option options [String] :type    The type attribute of the field
      # @return [Boolean]                 Whether it doesn't exist
      #
      def has_no_field?(locator, options={})
        has_no_selector?(:field, locator, options)
      end

      ##
      #
      # Checks if the page or current node has a radio button or
      # checkbox with the given label, value or id, that is currently
      # checked.
      #
      # @param [String] locator           The label, name or id of a checked field
      # @return [Boolean]                 Whether it exists
      #
      def has_checked_field?(locator, options={})
        has_selector?(:field, locator, options.merge(:checked => true))
      end

      ##
      #
      # Checks if the page or current node has no radio button or
      # checkbox with the given label, value or id, that is currently
      # checked.
      #
      # @param [String] locator           The label, name or id of a checked field
      # @return [Boolean]                 Whether it doesn't exist
      #
      def has_no_checked_field?(locator, options={})
        has_no_selector?(:field, locator, options.merge(:checked => true))
      end

      ##
      #
      # Checks if the page or current node has a radio button or
      # checkbox with the given label, value or id, that is currently
      # unchecked.
      #
      # @param [String] locator           The label, name or id of an unchecked field
      # @return [Boolean]                 Whether it exists
      #
      def has_unchecked_field?(locator, options={})
        has_selector?(:field, locator, options.merge(:unchecked => true))
      end

      ##
      #
      # Checks if the page or current node has no radio button or
      # checkbox with the given label, value or id, that is currently
      # unchecked.
      #
      # @param [String] locator           The label, name or id of an unchecked field
      # @return [Boolean]                 Whether it doesn't exist
      #
      def has_no_unchecked_field?(locator, options={})
        has_no_selector?(:field, locator, options.merge(:unchecked => true))
      end

      ##
      #
      # Checks if the page or current node has a select field with the
      # given label, name or id.
      #
      # It can be specified which option should currently be selected:
      #
      #     page.has_select?('Language', :selected => 'German')
      #
      # For multiple select boxes, several options may be specified:
      #
      #     page.has_select?('Language', :selected => ['English', 'German'])
      #
      # It's also possible to check if the exact set of options exists for
      # this select box:
      #
      #     page.has_select?('Language', :options => ['English', 'German', 'Spanish'])
      #
      # You can also check for a partial set of options:
      #
      #     page.has_select?('Language', :with_options => ['English', 'German'])
      #
      # @param [String] locator                      The label, name or id of a select box
      # @option options [Array] :options             Options which should be contained in this select box
      # @option options [Array] :with_options        Partial set of options which should be contained in this select box
      # @option options [String, Array] :selected    Options which should be selected
      # @return [Boolean]                            Whether it exists
      #
      def has_select?(locator, options={})
        has_selector?(:select, locator, options)
      end

      ##
      #
      # Checks if the page or current node has no select field with the
      # given label, name or id. See {Capybara::Node::Matchers#has_select?}.
      #
      # @param (see Capybara::Node::Matchers#has_select?)
      # @return [Boolean]     Whether it doesn't exist
      #
      def has_no_select?(locator, options={})
        has_no_selector?(:select, locator, options)
      end

      ##
      #
      # Checks if the page or current node has a table with the given id
      # or caption:
      #
      #    page.has_table?('People')
      #
      # @param [String] locator                        The id or caption of a table
      # @return [Boolean]                              Whether it exist
      #
      def has_table?(locator, options={})
        has_selector?(:table, locator, options)
      end

      ##
      #
      # Checks if the page or current node has no table with the given id
      # or caption. See {Capybara::Node::Matchers#has_table?}.
      #
      # @param (see Capybara::Node::Matchers#has_table?)
      # @return [Boolean]       Whether it doesn't exist
      #
      def has_no_table?(locator, options={})
        has_no_selector?(:table, locator, options)
      end

      ##
      # Asserts that the page or current node has the given text content,
      # ignoring any HTML tags.
      #
      # @!macro text_query_params
      #   @overload $0(type, text, options = {})
      #     @param [:all, :visible] type               Whether to check for only visible or all text. If this parameter is missing or nil then we use the value of `Capybara.ignore_hidden_elements`, which defaults to `true`, corresponding to `:visible`.
      #     @param [String, Regexp] text               The string/regexp to check for. If it's a string, text is expected to include it. If it's a regexp, text is expected to match it.
      #     @option options [Integer] :count (nil)     Number of times the text is expected to occur
      #     @option options [Integer] :minimum (nil)   Minimum number of times the text is expected to occur
      #     @option options [Integer] :maximum (nil)   Maximum number of times the text is expected to occur
      #     @option options [Range]   :between (nil)   Range of times that is expected to contain number of times text occurs
      #     @option options [Numeric] :wait (Capybara.default_max_wait_time)      Maximum time that Capybara will wait for text to eq/match given string/regexp argument
      #   @overload $0(text, options = {})
      #     @param [String, Regexp] text               The string/regexp to check for. If it's a string, text is expected to include it. If it's a regexp, text is expected to match it.
      #     @option options [Integer] :count (nil)     Number of times the text is expected to occur
      #     @option options [Integer] :minimum (nil)   Minimum number of times the text is expected to occur
      #     @option options [Integer] :maximum (nil)   Maximum number of times the text is expected to occur
      #     @option options [Range]   :between (nil)   Range of times that is expected to contain number of times text occurs
      #     @option options [Numeric] :wait (Capybara.default_max_wait_time)      Maximum time that Capybara will wait for text to eq/match given string/regexp argument
      # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
      # @return [true]
      #
      def assert_text(*args)
        query = Capybara::Queries::TextQuery.new(*args)
        synchronize(query.wait) do
          count = query.resolve_for(self)
          matches_count = Capybara::Helpers.matches_count?(count, query.options)
          unless matches_count && ((count > 0) || Capybara::Helpers.expects_none?(query.options))
            raise Capybara::ExpectationNotMet, query.failure_message
          end
        end
        return true
      end

      ##
      # Asserts that the page or current node doesn't have the given text content,
      # ignoring any HTML tags.
      #
      # @macro text_query_params
      # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
      # @return [true]
      #
      def assert_no_text(*args)
        query = Capybara::Queries::TextQuery.new(*args)
        synchronize(query.wait) do
          count = query.resolve_for(self)
          matches_count = Capybara::Helpers.matches_count?(count, query.options)
          if matches_count && ((count > 0) || Capybara::Helpers.expects_none?(query.options))
            raise Capybara::ExpectationNotMet, query.negative_failure_message
          end
        end
        return true
      end

      ##
      # Checks if the page or current node has the given text content,
      # ignoring any HTML tags.
      #
      # Whitespaces are normalized in both node's text and passed text parameter.
      # Note that whitespace isn't normalized in passed regexp as normalizing whitespace
      # in regexp isn't easy and doesn't seem to be worth it.
      #
      # By default it will check if the text occurs at least once,
      # but a different number can be specified.
      #
      #     page.has_text?('lorem ipsum', between: 2..4)
      #
      # This will check if the text occurs from 2 to 4 times.
      #
      # @macro text_query_params
      # @return [Boolean]                            Whether it exists
      #
      def has_text?(*args)
        assert_text(*args)
      rescue Capybara::ExpectationNotMet
        return false
      end
      alias_method :has_content?, :has_text?

      ##
      # Checks if the page or current node does not have the given text
      # content, ignoring any HTML tags and normalizing whitespace.
      #
      # @macro text_query_params
      # @return [Boolean]  Whether it doesn't exist
      #
      def has_no_text?(*args)
        assert_no_text(*args)
      rescue Capybara::ExpectationNotMet
        return false
      end
      alias_method :has_no_content?, :has_no_text?

      def ==(other)
        self.eql?(other) || (other.respond_to?(:base) && base == other.base)
      end
    end
  end
end
