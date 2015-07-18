require 'mechanize'
require 'fileutils'
require './logging'

class WebScraper < Logging
  WEB_HOST = 'www.parliament.nsw.gov.au'
  WEB_PATH = '/prod/parlment/members.nsf/V3ListCurrentMembers'
  WEB_URL = "http://#{WEB_HOST}#{WEB_PATH}"

  def scrape
    records = []
    @agent = Mechanize.new
    page = @agent.get WEB_URL
    page.search('.houseTable table tr').each do |member_row|
      next if member_row.search('td:nth-child(1) a').text.nil? || member_row.search('td:nth-child(1) a').text.length == 0

      surname, first_name = split_name(member_row.search('td:nth-child(1) a').text)
      phones = member_phones(member_row.search('td:nth-child(3)').text)
      records << [first_name, surname, phones]
    end
    records
  end

private

  def member_phones(phone)
    phone.scan(/Phone\s*(\(?\d\d\)?\s*\d+\s*\d+)/).flatten
  end

  def split_name(name)
    name.split(',').map(&:strip)
  end
end
