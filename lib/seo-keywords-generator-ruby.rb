require 'google_search_results'
require 'optparse'
require 'json'
require 'csv'

module SeoKeywordsGenerator
    class CLI
        def initialize(argv)
            @argv = argv
        end

        def run
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
                opts.banner = 'Usage: seo [options]'

                opts.on('-q', '--query QUERY', String, 'Search query (required)') do |q|
                    options[:query] = q
                end

                opts.on('-e', '--engines ENGINES', Array, 'Choices of engines to extract: Autocomplete (ac), Related Searches (rs), People Also Ask (rq). You can select multiple engines by separating them with a comma: ac,rs. All engines are selected by default.') do |e|
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
            end.parse!(@argv)

            keyword_research = SeoKeywordsGenerator::Scraper.new(
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
        end
    end

    class Scraper
        attr_accessor :query, :api_key, :lang, :country, :domain
        
        def initialize(query, api_key, lang = 'en', country = 'us', domain = 'google.com')
            @query = query
            @api_key = api_key
            @lang = lang
            @country = country
            @domain = domain
            @related_questions_results = []
        end
        
        def get_auto_complete
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                engine: 'google_autocomplete',    # search engine
                q: @query,                        # search query
                gl: @country,                     # country of the search
                hl: @lang                         # language of the search
            }
            
            search = GoogleSearch.new(params)     # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            results[:suggestions].map{ |result| result[:value] }.compact
        end
        
        def get_related_searches
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                engine: 'google',                 # search engine
                q: @query,                        # search query
                google_domain: @domain,           # Google domain to use
                gl: @country,                     # country of the search
                hl: @lang                         # language of the search
            }
            
            search = GoogleSearch.new(params)     # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            results[:related_searches].map{ |result| result[:query] }.compact
        end

        def get_depth_results(token, depth)
            depth_params = {
                q: @query,
                api_key: @api_key,
                engine: 'google_related_questions',
                next_page_token: token
            }
            
            depth_search = GoogleSearch.new(depth_params)
            depth_results = depth_search.get_hash
            
            @related_questions_results += depth_results[:related_questions]&.map{ |result| result[:question] }
            
            if depth > 1
                depth_results[:related_questions]&.each do |question|
                    if question[:next_page_token]
                        get_depth_results(question[:next_page_token], depth - 1)
                    end
                end
            end
        end
        
        def get_related_questions(depth_limit = 0)
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                engine: 'google',                 # search engine
                q: @query,                        # search query
                google_domain: @domain,           # Google domain to use
                gl: @country,                     # country of the search
                hl: @lang                         # language of the search
            }
            
            search = GoogleSearch.new(params)     # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            @related_questions_results = results[:related_questions]&.map{ |result| result[:question] }
            
            depth_limit = 4 if depth_limit > 4
            
            if depth_limit > 0
                results[:related_questions]&.each do |question|
                    if question[:next_page_token]
                        get_depth_results(question[:next_page_token], depth_limit)
                    end
                end
            end
        
            @related_questions_results
        end
        
        def save_to_csv(data)
            CSV.open("#{@query.gsub(' ', '_')}.csv", 'w') do |csv_file|
                csv_file << data.keys
                max_length = data.values.map(&:length).max
                (0...max_length).each do |index|
                    csv_file << data.values.map { |value| value[index] }
                end
            end
        end
        
        def save_to_json(data)
            File.open("#{@query.gsub(' ', '_')}.json", 'w') do |json_file|
                json_file.write(JSON.pretty_generate(data))
            end
        end
        
        def save_to_txt(data)
            File.open("#{@query.gsub(' ', '_')}.txt", "w") do |txt_file|
                data.each do |key, values|
                    txt_file.puts("#{key}:")
                    values.each do |value|
                        txt_file.puts("  #{value}")
                    end
                end
            end
        end
            
        def print_data(data)
            puts JSON.pretty_generate(data)
        end
    end
end