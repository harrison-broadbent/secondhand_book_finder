require 'open-uri'
require 'nokogiri'

### Now that we have all the titles, we search to try and find them.
### Searching for non-ascii titles breaks our code, so we filter then out.
### Brotherhood books offers no API, so we manually scrape their web-pages.

brotherhood_search_url = 'https://www.brotherhoodbooks.org.au/catalogsearch/result/?q='
avaliable_titles = {}

titles.each do |title|
  puts title
  if title.ascii_only?
    brotherhood_search_url = 'https://www.brotherhoodbooks.org.au/catalogsearch/result/?q=' + title
  else
    break
  end

  search_page = Nokogiri::HTML(::OpenURI.open_uri(brotherhood_search_url)).xpath('//*[@class="product-image-photo "]')

  (1..10).each do |counter|
    if search_page[counter]
      book_title_from_search = search_page[counter].values.last
      if book_title_from_search.include?(title) || title.include?(book_title_from_search)
        puts book_title_from_search, title
        puts book_title_from_search.include? title
        puts title.include? book_title_from_search
        avaliable_titles[title] = brotherhood_search_url
      end
    else
      break
    end
  end
end

puts '__________ Brotherhood Books __________'
puts avaliable_titles.keys
