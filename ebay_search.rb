# frozen_string_literal: true

require 'net/http'
require 'json'

class EbaySearch
  def initialize(appname, response_format, affiliate_enabled = true, books_only = true)
    @root_url = 'https://svcs.ebay.com/services/search/FindingService/v1?'
    @operation_name = 'OPERATION-NAME=findItemsAdvanced&'
    @service_version = 'SERVICE-VERSION=1.0.0&'
    @security_appname = "SECURITY-APPNAME=#{appname}&"
    @resp_format = "RESPONSE-DATA-FORMAT=#{response_format}&"
    @affiliate = affiliate_enabled ? 'affiliate.trackingId=5338676433&affiliate.networkId=9&affiliate.customId=1&' : ''
    @category_books = books_only ? 'categoryId=267&' : ''
    @sort_by_lowest_price = 'sortOrder=PricePlusShippingLowest&'
  end

  def get_search_url(search_phrase, maximum_price, g_id)
    keyword_phrase = "keywords=#{URI.encode_www_form_component(search_phrase)}&"
    maximum_price = "itemFilter(0).name=MaxPrice&itemFilter(0).value=#{maximum_price}&"
    global_id = "GLOBAL-ID=EBAY-#{g_id}&"

    @search_url = @root_url + @operation_name + @service_version + @security_appname + @resp_format + @affiliate + @category_books + @sort_by_lowest_price + global_id + keyword_phrase + maximum_price
    @search_url
  end

  def search_ebay(url = @search_url)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    @j_resp = JSON.parse(response)
    @j_resp
  end
end

# ebs = EbaySearch.new('Harrison-goodread-PRD-a7aad0465-e35ace13', 'JSON')
# ebs.get_search_url('lost and founder', 25, 'AU')
# resp = ebs.search_ebay

# resp['findItemsAdvancedResponse'][0]['searchResult'][0]['item'].each do |item|
#   print item['title'][0], item['sellingStatus'][0]['currentPrice'][0]['__value__']
#   puts ''
# end
