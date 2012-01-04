# -*- encoding: utf-8 -*-
require File.expand_path("../lib/open_geo_db/version", __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency("mixlib-cli", "~> 1.2.2")
  gem.add_development_dependency("rake")
  gem.authors = ["Kostiantyn Kahanskyi"]
  gem.description = "Create and destroy OpenGeoDb databases"
  gem.email = %w(kostiantyn.kahanskyi@googlemail.com)
  gem.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files = `git ls-files`.split("\n")
  gem.homepage = "https://github.com/kostia/open_geo_db"
  gem.name = "open_geo_db"
  gem.summary = "Create and destroy OpenGeoDb databases"
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version = OpenGeoDb::VERSION
end
