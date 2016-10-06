# encoding: utf-8
#
# Jekyll category page generator.
# http://recursive-design.com/projects/jekyll-plugins/
#
# Version: 0.1.4 (201101061053)
#
# Copyright (c) 2010 Dave Perrett, http://recursive-design.com/
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# A generator that creates category pages for jekyll sites.
#
# Included filters :
# - category_links:      Outputs the list of categories as comma-separated <a> links.
# - date_to_html_string: Outputs the post.date as formatted html, with hooks for CSS styling.
#
# Available _config.yml settings :
# - category_dir:          The subfolder to build category pages in (default is 'categories').
# - category_title_prefix: The string used before the category name in the page title (default is
#                          'Category: ').

require 'stringex'

module Jekyll

  # The CategoryIndex class creates a single category page for the specified category.
  class TagIndex < Page

    # Initializes a new CategoryIndex.
    #
    #  +base+         is the String path to the <source>.
    #  +category_dir+ is the String path between <source> and the category folder.
    #  +category+     is the category currently being processed.
    def initialize(site, base, tag_dir, tag)
      @site = site
      @base = base
      @dir  = tag_dir
      @name = 'index.html'
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
      self.data['tag']    = tag
      # Set the title for this page.
      title_prefix             = site.config['tag_title_prefix'] || 'Category: '
      self.data['title']       = "#{title_prefix}#{tag}"
      # Set the meta-description for this page.
      meta_description_prefix  = site.config['tag_meta_description_prefix'] || 'Category: '
      self.data['description'] = "#{meta_description_prefix}#{tag}"
    end

  end

  # The CategoryFeed class creates an Atom feed for the specified category.
  class TagFeed < Page

    # Initializes a new CategoryFeed.
    #
    #  +base+         is the String path to the <source>.
    #  +category_dir+ is the String path between <source> and the category folder.
    #  +category+     is the category currently being processed.
    def initialize(site, base, tag_dir, tag)
      @site = site
      @base = base
      @dir  = tag_dir
      @name = 'atom.xml'
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'tag_feed.xml')
      self.data['tag']    = tag
      # Set the title for this page.
      title_prefix             = site.config['tag_title_prefix'] || 'Category: '
      self.data['title']       = "#{title_prefix}#{tag}"
      # Set the meta-description for this page.
      meta_description_prefix  = site.config['tag_meta_description_prefix'] || 'Category: '
      self.data['description'] = "#{meta_description_prefix}#{tag}"

      # Set the correct feed URL.
      self.data['feed_url'] = "#{tag_dir}/#{name}"
    end

  end

  # The Site class is a built-in Jekyll class with access to global site config information.
  class Site

    # Creates an instance of CategoryIndex for each category page, renders it, and
    # writes the output to a file.
    #
    #  +category_dir+ is the String path to the category folder.
    #  +category+     is the category currently being processed.
    def write_tag_index(tag_dir, tag)
      if self.data["projects"].keys.include? tag
          # Create an Atom-feed for each index.
          feed = TagFeed.new(self, self.source, "projects/#{tag}", tag)
          feed.render(self.layouts, site_payload)
          feed.write(self.dest)
          # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
          self.pages << feed
      else
          index = TagIndex.new(self, self.source, tag_dir, tag)
          index.render(self.layouts, site_payload)
          index.write(self.dest)
          # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
          self.pages << index

          # Create an Atom-feed for each index.
          feed = TagFeed.new(self, self.source, tag_dir, tag)
          feed.render(self.layouts, site_payload)
          feed.write(self.dest)
          # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
          self.pages << feed
      end

    end

    # Loops through the list of category pages and processes each one.
    def write_tag_indexes
      if self.layouts.key? 'tag_index'
        dir = self.config['tag_dir'] || 'tags'
        self.tags.keys.each do |tag|
          self.write_tag_index(File.join(dir, tag.to_url), tag)
        end

      # Throw an exception if the layout couldn't be found.
      else
        raise <<-ERR
===============================================
 Error for tag.rb plugin
-----------------------------------------------
 No 'tag_index.html' in source/_layouts/
 Perhaps you haven't installed a theme yet.
===============================================
ERR
      end
    end

  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the category pages.
  class GenerateCategories < Generator
    safe true
    #priority :low

    def generate(site)
      site.write_tag_indexes
    end

  end


  # Adds some extra filters used during the category creation process.
  module TagFilters

    # Outputs a list of categories as comma-separated <a> links. This is used
    # to output the category list for each post on a category page.
    #
    #  +categories+ is the list of categories to format.
    #
    # Returns string
    #
    def tag_links(tags)
      tags = tags.sort!.map { |c| tag_link c }
      tags.join(', ')
    end

    # Outputs a single category as an <a> link.
    #
    #  +category+ is a category string to format as an <a> link
    #
    # Returns string
    #
    def tag_link(tag)
      @@links ||= {}
      dir = @context.registers[:site].config['tag_dir'] || "tags"
      if @context.registers[:site].data["projects"].keys.include? tag
          dir = "projects"
      end
      # Memoize link
      @@links[tag] ||= "<a class='tag' href='/#{dir}/#{tag.to_url}/'>#{tag}</a>"
    end

    # Outputs the post.date as formatted html, with hooks for CSS styling.
    #
    #  +date+ is the date object to format as HTML.
    #
    # Returns string
    def date_to_html_string(date)
      result = '<span class="month">' + date.strftime('%b').upcase + '</span> '
      result += date.strftime('<span class="day">%d</span> ')
      result += date.strftime('<span class="year">%Y</span> ')
      result
    end

  end

end

Liquid::Template.register_filter(Jekyll::TagFilters)
