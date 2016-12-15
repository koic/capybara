# frozen_string_literal: true
module Capybara
  class SessionConfig
    attr_reader :default_host, :app_host, :save_and_open_page_path
    attr_accessor :always_include_port, :run_server, :default_selector, :default_max_wait_time, :ignore_hidden_elements,
                  :automatic_reload, :match, :exact, :raise_server_errors, :visible_text_only, :wait_on_first_by_default,
                  :automatic_label_click, :enable_aria_label,
                  :save_path, :exact_options, :asset_host

    def app_host=(url)
      raise ArgumentError.new("Capybara.app_host should be set to a url (http://www.example.com)") unless url.nil? || (url =~ URI::Parser.new.make_regexp)
      @app_host = url
    end

    def default_host=(url)
      raise ArgumentError.new("Capybara.default_host should be set to a url (http://www.example.com)") unless url.nil? || (url =~ URI::Parser.new.make_regexp)
      @default_host = url
    end

    def save_and_open_page_path=(path)
      warn "DEPRECATED: #save_and_open_page_path is deprecated, please use #save_path instead. \n"\
           "Note: Behavior is slightly different with relative paths - see documentation" unless path.nil?
      @save_and_open_page_path = path
    end
  end
end