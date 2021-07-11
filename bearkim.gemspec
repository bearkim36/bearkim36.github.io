# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "bearkim"
  spec.version       = "0.1.0"
  spec.authors       = ["bearkim36"]
  spec.email         = ["bearkim36@gmail.com"]

  spec.summary       = "bearkim techlog"
  spec.homepage      = "https://github.com/bearkim36"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f|
    f.match(%r!^((assets\/(css|img|js\/[a-z])|_(includes|layouts|sass|config|data|tabs|plugins))|README|LICENSE|index)!i)
  }


  spec.add_runtime_dependency "jekyll", "~> 4.2"

end
