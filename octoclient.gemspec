Gem::Specification.new do |s|
  s.name        = 'octoclient'
  s.version     = '0.0.1'
  s.date        = '2014-10-22'
  s.summary     = "How we do Github"
  s.description = "Github API wrapper with friendly test stubs"
  s.authors     = ["Sam Joseph", "Dan Le Dosquet-Bergquist"]
  s.email       = 'tansaku@gmail.com'
  s.files       = `git ls-files`.split($\)
  s.homepage    = 'http://rubygems.org/gems/octoclient'
  s.license       = 'MIT'

  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
end
