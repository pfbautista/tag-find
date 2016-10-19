require 'watir-webdriver'

BASE_URL = 'http://www.huluqa.com'

@browser = Watir::Browser.new :chrome

def check_genres_pages(browser)
  browser.goto BASE_URL
  login(browser, 'ppp_sash30@gmail.com', 'abc123')
  check_tv_genres(browser)
  check_movie_genres(browser)
end

def login(browser, username, password)
  if browser.url =~ /welcome/
    Watir::Wait.until { browser.div(:id, 'user-menu').present? }
    browser.div(:id => 'user-menu').link(:text => 'LOG IN').click
    browser.iframe(:id, 'login-iframe').wait_until_present(10)

    login_iframe = browser.iframe(:id, 'login-iframe')

    #click email field to activate
    login_iframe.text_field(:class, 'inactive dummy user').click

    login_iframe.text_field(:class, 'active user').set username
    login_iframe.text_field(:class, 'active password').set password

    login_iframe.link(:text, 'Log in').click

    sleep 1
  end
end

def check_tv_genres(browser)
  puts '**** CHECKING TV GENRES ***'

  Watir::Wait.until { browser.a(:text => 'TV').present? }
  browser.a(:text => 'TV').click

  sleep 1

  Watir::Wait.until { @browser.div(:class => 'genres-txt').present? }
  browser.div(:class => 'genres-txt').click

  sleep 1

  # Grab all links on the current page
  page_links = browser.links

  page_links.each do |page_link|
    link = page_link.attribute_value("href")
    #puts link
  end

  # Write links to file for later processing
  open('tv_genres_page_links.txt', 'w+') do |file|
    #file << "Current URL = #{@browser.url}\n"
    page_links.each do |page_link|
      link = page_link.attribute_value("href")
      if link =~ /genres/ && link =~ /tv/
        file.puts("#{link}\n")
      end
    end
  end

  # Open file, filter for series pages, and write list of series pages to a file
  open('tv_genres_pages.txt', 'w+') do |genres_file|
    open('tv_genres_page_links.txt').readlines.each do |page_link|
      unless page_link =~ /^\s*$/
        genres_page = page_link
        #if series_page !~ /javascript|tv|movies|kids|companies|originals|latino|british|videogames|recommendations|hulu-movie-night|account|mailto|help|plus|start|advertising|jobs|press|sitemap|terms|privacy/
          genres_file << genres_page
        #end
      end
    end
  end


  open('tv_genres_test_results.txt', 'w+') do |results_file|
    open('tv_genres_pages.txt').readlines.each do |genres_page|
      browser.goto genres_page
      current_page = browser.url
      results_file.puts "... Checking #{current_page}"

      sleep 2

      unless current_page =~ /welcome/
        if browser.h1.present?
          results_file.puts "H1 tag on page = #{@browser.h1.text} --> PASS"
        else
          results_file.puts "*** H1 tag not present in #{current_page} --> FAIL"
        end
      end

      sleep 1
    end

  end

  puts '**** CHECKING TV GENRES COMPLETE!! ***'
end

def check_movie_genres(browser)
  puts '**** CHECKING MOVIES GENRES ***'

  Watir::Wait.until { browser.a(:text => 'MOVIES').present? }
  browser.a(:text => 'MOVIES').click

  sleep 1

  Watir::Wait.until { @browser.div(:class => 'genres-txt').present? }
  browser.div(:class => 'genres-txt').click

  sleep 1

  # Grab all links on the current page
  page_links = browser.links

  page_links.each do |page_link|
    link = page_link.attribute_value("href")
    #puts link
  end

  # Write links to file for later processing
  open('movies_genres_page_links.txt', 'w+') do |file|
    #file << "Current URL = #{@browser.url}\n"
    page_links.each do |page_link|
      link = page_link.attribute_value("href")
      if link =~ /genres/ && link =~ /movies/
        file.puts("#{link}\n")
      end
    end
  end

  # Open file, filter for series pages, and write list of series pages to a file
  open('movies_genres_pages.txt', 'w+') do |genres_file|
    open('movies_genres_page_links.txt').readlines.each do |page_link|
      unless page_link =~ /^\s*$/
        genres_page = page_link
        #if series_page !~ /javascript|tv|movies|kids|companies|originals|latino|british|videogames|recommendations|hulu-movie-night|account|mailto|help|plus|start|advertising|jobs|press|sitemap|terms|privacy/
          genres_file << genres_page
        #end
      end
    end
  end


  open('movies_genres_test_results.txt', 'w+') do |results_file|
    open('movies_genres_pages.txt').readlines.each do |genres_page|
      browser.goto genres_page
      current_page = browser.url
      results_file.puts "... Checking #{current_page}"

      sleep 2

      unless current_page =~ /welcome/
        if browser.h1.present?
          results_file.puts "H1 tag on page = #{@browser.h1.text} --> PASS"
        else
          results_file.puts "*** H1 tag not present in #{current_page} --> FAIL"
        end
      end

      sleep 1
    end

  end

  puts '**** CHECKING MOVIES GENRES COMPLETE!! ***'
end

check_genres_pages(@browser)

@browser.close

puts '=== Tests complete!  See test_results.txt file(s) for details. ==='

# TODO:  Error Handling
# TODO:  Refactor to handle logged-in and logged-out users
# TODO:  Refactor to handle processing of *ANY* tag(s) on the page