module Capybara
  class << self

    def save_page(html, file_name=nil, save_to=nil)
      file_name ||= "capybara-#{Time.new.strftime("%Y%m%dT%H%M%S")}-#{rand(10**10)}.html"
      save_to ||= Capybara.save_and_open_page_path

      name = File.join(*[save_to, file_name].compact)

      unless save_to.nil? || File.directory?( save_to )
        FileUtils.mkdir_p(save_to)
      end
      FileUtils.touch(name) unless File.exist?(name)

      tempfile = File.new(name,'w')
      tempfile.write(rewrite_css_and_image_references(html))
      tempfile.close
      tempfile.path
    end

    def save_and_open_page(html)
      open_in_browser save_page(html)
    end

  protected

    def open_in_browser(path) # :nodoc
      require "launchy"
      if Launchy::Version::MAJOR >= 2
        Launchy.open(path)  
      else
        Launchy::Browser.run(path)  
      end
            
    rescue LoadError
      warn "Sorry, you need to install launchy (`gem install launchy`) and " <<
        "make sure it's available to open pages with `save_and_open_page`."
    end

    def rewrite_css_and_image_references(response_html) # :nodoc:
      root = Capybara.asset_root
      return response_html unless root
      directories = Dir.new(root).entries.select { |name|
        (root+name).directory? and not name.to_s =~ /^\./
      }
      if not directories.empty?
        response_html.gsub!(/("|')\/(#{directories.join('|')})/, '\1' + root.to_s + '/\2')
      end
      return response_html
    end
  end
end
