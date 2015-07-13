require 'scraperwiki'
require './logging'
require 'csv'
require 'open-uri'

class ScraperMain < Logging
  #CSV_URL = 'http://www.parliament.nsw.gov.au/prod/parlment/members.nsf/reports/ContactSpreadsheetAll.csv'
  CSV_URL = 'doc/ContactSpreadsheetAll.csv'

  def main
    csv_records = scrape_csv

    csv_records.each do |electorate, record|
      @logger.info("### Saving #{record['first_name']} #{record['surname']}")
      puts("### Saving #{record['first_name']} #{record['surname']}")
      ScraperWiki::save(['first_name', 'surname', 'electorate'], record)
    end
  end

private

  def parse_record(row, headers)
    record = {}
    headers.each_with_index do |header, index|
      val = row[index] ? row[index].strip : nil
      record[header.gsub('"', '').gsub(' ','_').gsub('-', '_').downcase] = val
    end
    record['first_name'] = record['initials']
    key = "#{record['surname']}-#{record['first_name']}"
    [key, record]
  end

  def scrape_csv
    records = {}
    csv = CSV.read(open(CSV_URL), :headers => :true)
    headers = csv.headers
    csv.each do |line|
      key, record = parse_record(line, headers)
      records[key] = record
    end
    records
  end

  #type
    #`last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`parliament_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`parliament_fax` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_suburb` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_postcode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_fax` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`office_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  #`party_id` int(11) DEFAULT NULL,
  #`electorate_id` int(11) DEFAULT NULL,
end
