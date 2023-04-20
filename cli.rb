require_relative 'lib/seo-keywords-generator'
require 'optparse'

options = {
    engines: ['ac', 'rs', 'rq'],
    depth_limit: 0,
    save_to: 'CSV',
    api_key: '5868ece26d41221f5e19ae8b3e355d22db23df1712da675d144760fc30d57988',
    domain: 'google.com',
    country: 'us',
    lang: 'en',
}

OptionParser.new do |opts|
    opts.banner = 'Usage: ruby cli.rb [options]'

    opts.on('-q', '--query QUERY', String, 'Search query (required)') do |q|
        options[:query] = q
    end

    opts.on('-e', '--engines ENGINES', Array, 'Choices of engines to extract: Autocomplete (ac), Related Searches (rs), People Also Ask (rq). You can select multiple engines. All engines are selected by default.') do |e|
        options[:engines] = e
    end

    opts.on('-d', '--depth-limit LIMIT', Integer, 'Depth limit for People Also Ask. Default is 0, first 2-4 results.') do |dl|
        options[:depth_limit] = dl
    end

    opts.on('-s', '--save-to SAVE', String, 'Saves the results in the current directory in the selected format (CSV, JSON, TXT). Default CSV.') do |st|
        options[:save_to] = st
    end

    opts.on('-k', '--api-key KEY', String, 'Your SerpApi API key: https://serpapi.com/manage-api-key. Default is a test API key to test CLI.') do |ak|
        options[:api_key] = ak
    end

    opts.on('-g', '--domain DOMAIN', String, 'Google domain: https://serpapi.com/google-domains. Default google.com.') do |gd|
        options[:domain] = gd
    end

    opts.on('-c', '--country COUNTRY', String, 'Country of the search: https://serpapi.com/google-countries. Default us.') do |gl|
        options[:country] = gl
    end

    opts.on('-l', '--language LANGUAGE', String, 'Language of the search: https://serpapi.com/google-languages. Default en.') do |hl|
        options[:lang] = hl
    end
end.parse!

keyword_research = SeoKeywordsGenerator.new(
    query=options[:query],
    api_key=options[:api_key],
    lang=options[:lang],
    country=options[:country],
    domain=options[:domain]
)

data = {}

options[:engines]&.each do |engine|
    case engine.downcase
    when 'ac'
        data['auto_complete'] = keyword_research.get_auto_complete()
    when 'rs'
        data['related_searches'] = keyword_research.get_related_searches()
    when 'rq'
        data['related_questions'] = keyword_research.get_related_questions(options[:depth_limit])
    end
end

if !data.empty?
    keyword_research.print_data(data)
    puts "Saving data in #{options[:save_to].upcase} format..."

    case options[:save_to].upcase
    when 'CSV'
        keyword_research.save_to_csv(data)
    when 'JSON'
        keyword_research.save_to_json(data)
    when 'TXT'
        keyword_research.save_to_txt(data)
    end

    puts "Data successfully saved to #{options[:query].gsub(' ', '_')}.#{options[:save_to].downcase} file"
end
