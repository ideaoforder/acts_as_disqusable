# == From the {Disqus Website}[http://disqus.com]:
 
# "Disqus, pronounced "discuss", is a service and tool for web comments and
# discussions. The Disqus comment system can be plugged into any website, blog,
# or application. Disqus makes commenting easier and more interactive, while
# connecting websites and commenters across a thriving discussion community."
#
# "Disqus is a free service to the general public with absolutely no inline
# advertisements."
 
# The Disqus gem helps you quickly and easily integrate Disqus's Javascript
# widgets into your Ruby-based website. Adding Disqus to your site literally
# takes only a few minutes. The Disqus gem also provides a complete
# implementation of the Disqus API for more complex applications.
 
# To use this code, please first create an account on Disqus[http://disqus.com].
require 'rubygems'
require 'httparty'
 
require 'acts_as_disqusable/forum'
require 'acts_as_disqusable/thread'
require 'acts_as_disqusable/post'
require 'acts_as_disqusable/author'
require 'acts_as_disqusable/view_helpers'
require 'acts_as_disqusable/widget'
 
module Disqus
  @defaults = {
    :api_key => "",
    :account => "",
    :developer => false,
    :container_id => 'disqus_thread',
    :avatar_size => 48,
    :color => "grey",
    :default_tab => "popular",
    :hide_avatars => false,
    :hide_mods => true,
    :num_items => 5,
    :show_powered_by => false,
    :orientation => "horizontal",
    :forum_api_key => '', # optional--if you're just mapping one forum to your app, this is convenient
    :forum_shortname => '', # ditto
    :forum_id => '' # ditto
  }
 
  def self.defaults
    @config = @defaults.merge(YAML::load(File.open("#{RAILS_ROOT}/config/disqus.yml")))
  end
  
  [Author, Forum, Post, Thread].each do |klass|
    klass.class_eval "include HTTParty"
    klass.class_eval "base_uri 'http://disqus.com/api'"
    klass.class_eval "format :json"
    klass.class_eval "default_params :user_api_key => '#{self.defaults[:api_key]}'"
    klass.class_eval "default_params :forum_api_key => '#{self.defaults[:forum_api_key]}'"
    klass.class_eval "default_params :forum_id => '#{self.defaults[:forum_id]}'"
  end
end