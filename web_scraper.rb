require 'mechanize'
require 'fileutils'
require './logging'

      require 'pry'

class WebScraper < Logging
  WEB_URL = 'http://www.parliament.nsw.gov.au/prod/parlment/members.nsf/V3ListCurrentMembers'

  def scrape
    records = []
    @agent = Mechanize.new
    page = @agent.get WEB_URL
    page.search('.houseTable table tr').each do |member_row|
      next if member_row.search('td:nth-child(1) a').text.nil? || member_row.search('td:nth-child(1) a').text.length == 0

      surname, first_name = split_name(member_row.search('td:nth-child(1) a').text)
      phones = member_phones(member_row.search('td:nth-child(3)').text)
      binding.pry unless phones
      records << [first_name, surname, phones]
    end

    records.each {|r| p r }
  end

private

  def member_phones(phone)
    phone.match(/Phone\s*(\(?\d\d\)?\s*\d+\s*\d+)/).to_a[1..-1]
  end

  def split_name(name)
    name.split(',').map(&:strip)
  end
end

WebScraper.new.scrape
