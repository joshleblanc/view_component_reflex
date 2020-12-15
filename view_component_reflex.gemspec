$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "view_component_reflex/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "view_component_reflex"
  spec.version     = ViewComponentReflex::VERSION
  spec.authors     = ["Joshua LeBlanc"]
  spec.email       = ["joshleblanc94@gmail.com"]
  spec.homepage    = "https://github.com/joshleblanc/view_component_reflex"
  spec.summary     = "Allow stimulus reflexes in a view component"
  spec.description = "Allow stimulus reflexes in a view component"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", [">= 5.2", "< 7.0"]
  spec.add_dependency "stimulus_reflex", "=3.4.0.pre9"
  spec.add_dependency "view_component"
end
