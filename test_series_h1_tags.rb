require 'rubygems'
require 'watir-webdriver'

BASE_URL = 'http://www.huluqa.com'

@browser = Watir::Browser.new :phantomjs

@browser.goto BASE_URL

@browser.a(:id => 'logo-link').click

sleep 1

@browser.a(:text => 'TV').click

sleep 1

@browser.element(:xpath => "//*[@id='popular_shows']/div/div/div[1]/h3/a").click

sleep 1

# Grab all links on the current page
page_links = @browser.links

# Write links to file for later processing
open('page_links.txt', 'w+') do |file|
  file << "Current URL = #{@browser.url}\n"
  page_links.each do |page_link|
    link = page_link.attribute_value("href")
    file.puts("#{link}\n")
  end
end

# Open file, filter for series pages, and write list of series pages to a file
open('series_pages.txt', 'w+') do |series_file|
  open('page_links.txt').readlines.each do |page_link|
    unless page_link =~ /^\s*$/
      series_page = page_link
      if series_page !~ /javascript|tv|movies|kids|companies|originals|latino|british|videogames|recommendations|hulu-movie-night|account|mailto|help|plus|start|advertising|jobs|press|sitemap|terms|privacy/
        series_file << series_page
      end
    end
  end
end


open('test_results.txt', 'w+') do |results_file|
  open('series_pages.txt').readlines.each do |series_page|
    @browser.goto series_page
    current_page = @browser.url
    results_file.puts "... Checking #{current_page}"

    sleep 2

    unless current_page =~ /welcome/
      if @browser.h1.present?
        results_file.puts "H1 tag on page = #{@browser.h1.text} --> PASS"
      else
        results_file.puts "*** H1 tag not present in #{current_page} --> FAIL"
      end
    end

    sleep 1
  end

end

@browser.close

puts '=== Tests complete!  See test_results.txt file for details. ==='

# TODO:  Error Handling
# TODO:  Refactor to handle logged-in and logged-out users
# TODO:  Refactor to handle processing of *ANY* tag(s) on the page