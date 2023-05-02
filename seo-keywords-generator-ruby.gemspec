Gem::Specification.new do |s|
    s.name                      = 'seo-keywords-generator-ruby'
    s.version                   = '0.1.4'
    s.license                   = 'MIT'
    s.summary                   = "Ruby SEO Keywords Generator"
    s.description               = "Ruby SEO keywords suggestion tool. Google Autocomplete, People Also Ask and Related Searches."
    s.authors                   = ['Artur Chukhrai', 'Dmitiry Zub']
    s.email                     = ['chukhraiartur@gmail.com', 'dimitryzub@gmail.com']
    s.files                     = Dir['lib/**/*.rb']
    s.homepage                  = 'https://github.com/chukhraiartur/seo-keywords-generator-ruby'
    s.required_ruby_version     = '>= 3.0.0'
    s.files = %w[
        bin/seo
        lib/seo-keywords-generator-ruby.rb
    ]
    s.add_dependency 'google_search_results', '~> 2.2'
  end