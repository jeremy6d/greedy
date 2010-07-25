# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{greedy}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Weiland"]
  s.date = %q{2010-07-25}
  s.description = %q{With greedy, you can access and manipulate the reading list for a Google Reader account via the API. Inspired by John Nunemaker's GoogleReader gem.}
  s.email = %q{jeremy6d@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "greedy.gemspec",
     "lib/greedy.rb",
     "lib/greedy/connection.rb",
     "lib/greedy/entry.rb",
     "lib/greedy/feed.rb",
     "lib/greedy/stream.rb",
     "test/fixtures/another_success_hash.txt",
     "test/fixtures/lorem_ipsum.txt",
     "test/fixtures/success_json_hash.txt",
     "test/fixtures/update_hash.txt",
     "test/test_connection.rb",
     "test/test_entry.rb",
     "test/test_helper.rb",
     "test/test_stream.rb"
  ]
  s.homepage = %q{http://github.com/jeremy6d/greedy}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Access a Google Reader reading list}
  s.test_files = [
    "test/test_connection.rb",
     "test/test_entry.rb",
     "test/test_helper.rb",
     "test/test_stream.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<mcmire-matchy>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<mcmire-matchy>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<mcmire-matchy>, [">= 0"])
  end
end

