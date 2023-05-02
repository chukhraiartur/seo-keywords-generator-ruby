<div align="center">
<p>Sponsor of the project:</p>
<div>
   <img src="https://user-images.githubusercontent.com/78694043/231375638-5bbf2989-fc7b-482a-b6fe-603d1d6d613f.svg" width="90" alt="SerpApi">
</div>
<a href="https://serpapi.com">
	<b>API to get search engine results with ease.</b>
</a>
</div>

<h2 align="center">
   Ruby SEO Keywords Generator
</h2>

<p align="center">
   Pull keyword ideas using Google Autocomplete, People Also Ask and Related Searches.
</p>

<div align="center">
   <img src="https://user-images.githubusercontent.com/78694043/233605838-0e325f18-78d2-44eb-b937-d24d5a051ce1.svg" width="600" alt="seo-keywords-generator-ruby-logo">
</div>



This tool uses [SerpApi](https://serpapi.com/) as a tool to parse data from Google search results. 

You can use provided API key that will be available after installation, however, it's purely for testing purposes to see if the tool fits your needs. If you'll be using it for your own purpose (personal or commercial), you have to use [your own SerpApi key](https://serpapi.com/manage-api-key).


## ⚙️Installation

```bash
$ gem install seo-keywords-generator-ruby
```


## 🤹‍♂️Usage

#### Available CLI arugments:

```bash
$ seo -h
```

```lang-none
Usage: seo [options]
    -q, --query QUERY                Search query (required)
    -e, --engines ENGINES            Choices of engines to extract: Autocomplete (ac), Related Searches (rs), People Also Ask (rq). You can select multiple engines by separating them with a comma: ac,rs. All engines are selected by default.
    -d, --depth-limit LIMIT          Depth limit for People Also Ask. Default is 0, first 2-4 results.
    -s, --save-to SAVE               Saves the results in the current directory in the selected format (CSV, JSON, TXT). Default CSV.
    -k, --api-key KEY                Your SerpApi API key: https://serpapi.com/manage-api-key. Default is a test API key to test CLI.
    -g, --domain DOMAIN              Google domain: https://serpapi.com/google-domains. Default google.com.
    -c, --country COUNTRY            Country of the search: https://serpapi.com/google-countries. Default us.
    -l, --language LANGUAGE          Language of the search: https://serpapi.com/google-languages. Default en.
```

The `--depth-limit` argument for People Also Ask can be set from `0` to `4`. For each depth limit value, the number of results returned grows exponentially. Below is a table showing how the depth limit argument is affected:

| Depth limit | Number of results | Explanation |
|-------------|-------------------|-------------|
| 0 | 4 | Standard results |
| 1 | 12 | 4*2 = 8 + 4 = 12 |
| 2 | 36 | 8*3 = 24 + 12 = 36 |
| 3 | 108 | 24*3 = 72 + 36 = 108 |
| 4 | 324 | 72*3 = 216 + 108 = 324 |

📌Note: This is how the logic works for the `google.com` domain, on other domains the results may differ.

#### Simple example:

```bash
$ seo -q "starbucks coffee"
```

```json
{
  "auto_complete": [
    "starbucks coffee menu",
    "starbucks coffee sizes",
    "starbucks coffee cups",
    "starbucks coffee gear",
    "starbucks coffee beans",
    "starbucks coffee near me",
    "starbucks coffee drinks",
    "starbucks coffee mugs",
    "starbucks coffee traveler",
    "starbucks coffee price",
    "starbucks coffee machine",
    "starbucks coffee creamer",
    "starbucks coffee pods",
    "starbucks coffee recall",
    "starbucks coffee flavors"
  ],
  "related_searches": [
    "starbucks near me",
    "starbucks products",
    "amazon starbucks coffee instant",
    "starbucks logo",
    "starbucks drinks",
    "starbucks twitter",
    "starbucks cups",
    "starbucks facebook"
  ],
  "related_questions": [
    "What is best coffee in Starbucks?",
    "What is the Starbucks drink for St Patrick's Day?",
    "How do I order a regular coffee at Starbucks?",
    "What kind of coffee does Starbucks make?"
  ]
}
```

#### Advanced example:

This example will use [related questions API](https://serpapi.com/related-questions) engine with a depth limit value of 2, and saves data to JSON:

```bash
$ seo --api-key "<your_serpapi_api_key>" \
> -q "starbucks coffee" \
> -e rq \
> -d 2 \
> -g google.co.uk \
> -c uk \
> -l en \
> -s json \
```

```json
{
  "related_questions": [
    "What is best coffee in Starbucks?",
    "What is Starbucks coffee called?",
    "Why is Starbucks famous for?",
    "Is Starbucks coffee good quality coffee?",
    "What is the most ordered drink at Starbucks?",
    "Which Starbucks coffee is best for beginners?",
    "What is the best choice in Starbucks?",
    "What is a good thing to order at Starbucks?",
    "What is Starbucks strongest coffee flavor?",
    "What is the most basic Starbucks coffee?",
    "Which Starbucks coffee is the least bitter?",
    "What should I order for my first coffee?",
    "Why is it called Starbuck?",
    "Is Starbucks Italian or Spanish?",
    "Why is Starbucks so expensive?",
    "Who is the woman on the Starbucks logo?",
    "Why is Starbucks called Grande?",
    "What does Grande and Venti mean?",
    "Why is a small Starbucks called tall?",
    "What country is Starbucks most popular?",
    "Why is Starbucks so expensive?",
    "What is the most famous drink at Starbucks?",
    "What is the most expensive thing in Starbucks?",
    "What's cheaper Dunkin or Starbucks?",
    "What are the weaknesses of Starbucks?",
    "What is the most ordered drink in the world?",
    "What is the most expensive Starbucks drink ever ordered?",
    "What is the most ordered drink?",
    "Which is the best quality coffee?",
    "Is Starbucks and McDonald's coffee the same?",
    "What is the number 1 coffee brand in the world?",
    "What is the most popular coffee in the world?",
    "What is the healthiest coffee to drink?",
    "Is Starbucks coffee arabica or robusta?",
    "Why is Starbucks coffee different?",
    "What country owns Starbucks coffee?"
  ]
}
```

#### Example of manual data extraction (without CLI):

```ruby
require 'seo-keywords-generator-ruby'

keyword_research = SeoKeywordsGenerator.new(
    query='starbucks coffee',
    api_key='<your_serpapi_api_key>',
    lang='en',
    country='us',
    domain='google.com'
)

auto_complete_results = keyword_research.get_auto_complete
related_searches_results = keyword_research.get_related_searches
related_questions_results = keyword_research.get_related_questions

data = {
    auto_complete: auto_complete_results,
    related_searches: related_searches_results,
    related_questions: related_questions_results
}

keyword_research.save_to_csv(data)
keyword_research.print_data(data)
```


### ✍Contributing

Feel free to open bug issue, something isn't working, what feature to add, or anything else related to Google autocomplete, related searches or people also ask.