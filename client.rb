# frozen_string_literal: true

require 'goodreads'
require 'oauth'
require 'open-uri'
require 'nokogiri'
require 'json'

require_relative 'ebay_search'

### Setup OAuth API keys for Goodreads login.
### Keys are stored in a keys/ folder so they are not shared publicly

api_key = File.open('keys/api_key.txt', &:gets)
api_secret_key = File.open('keys/api_secret_key.txt', &:gets)

consumer = OAuth::Consumer.new(api_key,
                               api_secret_key,
                               site: 'https://www.goodreads.com')

request_token = consumer.get_request_token

### Check if we have previously authenticated.
### If we have, we import previous credentials
### Otherwise we authenticate and then store the credentials in credentials.json

if File.file?('credentials.json')
  credentials = JSON.parse(File.read('credentials.json'))
  access_token = OAuth::AccessToken.new(consumer, credentials['token'], credentials['secret'])
else
  # authorize user on first run
  authorized = false
  while authorized == false
    begin
      sleep(3)
      access_token = request_token.get_access_token
      authorized = true
    rescue StandardError => e
      print "\ngo to authorize url.\n"
      print request_token.authorize_url
    end
  end

  credentials = {
    token: access_token.token,
    secret: access_token.secret
  }

  File.open('credentials.json', 'w') do |f|
    f.write(credentials.to_json)
  end
end

### We use the Goodreads API wrapper gem to make accessing data easier.
### We then proceed to collect all the books on a users shelf.
### Default is the 'to-read' shelf.

goodreads_client = Goodreads.new(oauth_token: access_token)

goodreads_section = 'to-read' # read, to-read
books_shelf = goodreads_client.shelf(goodreads_client.user_id, goodreads_section)

### We can only get 40 results at a time.
### Therefore we need to loop ceil(totalresults/40) times to collect all the books.
### We print the titles to the terminal to indicate we are sucessfully progressing through.

titles = []
pages_of_results = (books_shelf.total / 40.0).ceil
pages_of_results.times do |page_num|
  books_shelf_page = goodreads_client.shelf(goodreads_client.user_id, goodreads_section, page: page_num + 1)
  books_shelf_page.books.each do |b|
    title = b.book.title
    puts title
    titles.append(title)
  end
end

ebs = EbaySearch.new('Harrison-goodread-PRD-a7aad0465-e35ace13', 'JSON', books_only = true)
location = 'AU'
max_price = 15

avaliable_titles = {}

titles.each do |title|
  puts title

  ebs.get_search_url(title, max_price, location)
  resp = ebs.search_ebay
  puts resp
  if resp['errors']
    puts 'error'
  else
    number_of_results = resp['findItemsAdvancedResponse'][0]['searchResult'][0]['@count'].to_i

    if number_of_results > 0
      price_item = resp['findItemsAdvancedResponse'][0]['searchResult'][0]['item'][0]['sellingStatus'][0]['currentPrice'][0]['__value__'].to_i

      is_shipping_calculated = resp['findItemsAdvancedResponse'][0]['searchResult'][0]['item'][0]['shippingInfo'][0]['shippingType']
      if is_shipping_calculated.nil? || (is_shipping_calculated[0] == 'Flat')
        price_postage = resp['findItemsAdvancedResponse'][0]['searchResult'][0]['item'][0]['shippingInfo'][0]['shippingServiceCost'][0]['__value__'].to_i
      else
        # it is calculated
        price_postage = 0
      end

      if price_postage + price_item <= max_price
        puts price_item, price_postage
        avaliable_titles[title] = resp['findItemsAdvancedResponse'][0]['itemSearchURL'][0]
        puts 'found'
      end
    end
  end
  puts 'next'
  puts
end

puts '__________ eBay __________'

### look through titles we found last time to check if we have found any new ones
previous_titles = JSON.parse(File.read("previous_search_titles.json"))
# clone the available titles so if we add asterixes to their title, they wont get mixed with our regular titles
titles_to_save = avaliable_titles.clone

titles_to_update = {}
json_to_save = {"titles": []}
number_of_new_titles = 0

puts previous_titles

# create a hash of titles to update in the form of old:new
avaliable_titles.keys.each do |title|
  if previous_titles["titles"].include?(title)
    ### we found this title last time as well
  else
    ### we didnt find the title last time
    ### we replace the title with one marked with an asterix
    ### add an asterix * to show its newly found
    ### and increment our counter
    titles_to_update[title] = "#{title} (*)"
    number_of_new_titles += 1
  end
end

### iterate through titles to update and actually update
titles_to_update.keys.each do |title|
  new_title = titles_to_update[title]
  avaliable_titles[new_title] = avaliable_titles.delete title
end

titles_to_save.keys.each do |title|
  json_to_save[:titles].append(title)
end
File.open("previous_search_titles.json", "w") do |f|
  f << json_to_save.to_json
end

puts avaliable_titles

### sort available titles with new additions at the bottom
avaliable_titles.keys.sort{|title| title.to_s.include?("*") ? 1 : 0}.each do |title|
  puts title, avaliable_titles[title]
  puts
end

puts avaliable_titles.length.to_s + ' titles found!'
puts number_of_new_titles.to_s + ' new titles found —'
puts titles_to_update.keys
