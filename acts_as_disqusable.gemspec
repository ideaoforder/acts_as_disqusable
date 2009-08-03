# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_disqusable}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Dickson", "Thomas Reynolds", "Norman Clarke", "Matthew Van Horn"]
  s.date = %q{2009-08-03}
  s.description = %q{Uses the Disqus API to make model(s) comment-on-able}
  s.email = %q{mark@sitesteaders.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "Manifest.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "acts_as_disqusable.gemspec",
     "lib/acts_as_disqusable.rb",
     "lib/acts_as_disqusable/author.rb",
     "lib/acts_as_disqusable/forum.rb",
     "lib/acts_as_disqusable/post.rb",
     "lib/acts_as_disqusable/thread.rb",
     "lib/acts_as_disqusable/view_helpers.rb",
     "lib/acts_as_disqusable/widget.rb",
     "lib/disqus.rb",
     "tasks/rcov.rake",
     "test/api_test.rb",
     "test/config.yml.sample",
     "test/forum_test.rb",
     "test/merb_test.rb",
     "test/post_test.rb",
     "test/rails_test.rb",
     "test/responses/bad_api_key.json",
     "test/responses/create_post.json",
     "test/responses/get_forum_api_key.json",
     "test/responses/get_forum_list.json",
     "test/responses/get_num_posts.json",
     "test/responses/get_thread_by_url.json",
     "test/responses/get_thread_list.json",
     "test/responses/get_thread_posts.json",
     "test/responses/thread_by_identifier.json",
     "test/responses/update_thread.json",
     "test/test_helper.rb",
     "test/thread_test.rb",
     "test/view_helpers_test.rb",
     "test/widget_test.rb"
  ]
  s.homepage = %q{http://github.com/ideaoforder/disqus}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Uses the Disqus API to make model(s) comment-on-able}
  s.test_files = [
    "test/merb_test.rb",
     "test/view_helpers_test.rb",
     "test/widget_test.rb",
     "test/api_test.rb",
     "test/post_test.rb",
     "test/thread_test.rb",
     "test/rails_test.rb",
     "test/forum_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.4"])
    else
      s.add_dependency(%q<httparty>, [">= 0.4.4"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0.4.4"])
  end
end
