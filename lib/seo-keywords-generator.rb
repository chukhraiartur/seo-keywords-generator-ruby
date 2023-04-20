require 'google_search_results'
require 'json'
require 'csv'


class SeoKeywordsGenerator
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
