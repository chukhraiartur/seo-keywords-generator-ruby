Gem::Specification.new do |s|
    s.name                      = 'seo-keywords-generator-ruby'
    s.version                   = '0.1.12'
    s.platform                  = Gem::Platform::RUBY
    s.date                      = Time.now.strftime('%Y-%m-%d')
    s.license                   = 'MIT'
    s.summary                   = "Ruby SEO Keywords Generator"
    s.homepage                  = "https://github.com/chukhraiartur/seo-keywords-generator-ruby"
    s.description               = "Ruby SEO keywords suggestion tool. Google Autocomplete, People Also Ask and Related Searches."
    s.authors                   = ['Artur Chukhrai', 'Dmitiry Zub']
    s.email                     = ['chukhraiartur@gmail.com', 'dimitryzub@gmail.com']
    s.homepage                  = 'https://github.com/chukhraiartur/seo-keywords-generator-ruby'
    s.required_ruby_version     = '>= 3.0.0'
    s.add_dependency            'google_search_results', '~> 2.2'
    s.files                     = Dir.glob("{lib,bin}/**/*")
    s.require_path              = 'lib'
    s.executables               = ['seo']
end