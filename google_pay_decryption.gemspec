# frozen_string_literal: true

require_relative 'lib/google_pay_decryption/version'

Gem::Specification.new do |spec|
  spec.name = 'google_pay_decryption'
  spec.version = GooglePayDecryption::VERSION
  spec.authors = ['Nguyen Tien Dzung']
  spec.email = ['imnguyentiendzung@gmail.com']

  spec.summary = 'Ruby library for decrypting Google Pay and Android Pay payment tokens'
  spec.description = 'A secure, easy-to-use Ruby library for decrypting Google Pay (ECv1/ECv2) and Android Pay payment tokens with built-in signature verification and constant-time comparison'
  spec.homepage = 'https://github.com/codewithdzung/google_pay_decryption'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/codewithdzung/google_pay_decryption'
  spec.metadata['changelog_uri'] = 'https://github.com/codewithdzung/google_pay_decryption/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/codewithdzung/google_pay_decryption/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'base64', '~> 0.1'

  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end
