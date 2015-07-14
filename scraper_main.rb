require 'scraperwiki'
require './logging'
require 'csv'
require 'open-uri'

class ScraperMain < Logging
  #CSV_URL = 'http://www.parliament.nsw.gov.au/prod/parlment/members.nsf/reports/ContactSpreadsheetAll.csv'
  CSV_URL = 'doc/ContactSpreadsheetAll.csv'

  def main
    csv_records = scrape_csv

    csv_records.each do |key, record|
      @logger.info("### Saving #{record['first_name']} #{record['surname']}")
      puts("### Saving #{record['first_name']} #{record['surname']}")
      ScraperWiki::save(['first_name', 'surname'], record)
    end
  end

private

  def parse_record(row, headers)
    key = "#{row['SURNAME']}-#{row['INITIALS']}"
    record = {}
    record['type'] = row['ELECTORATE'] && !row['ELECTORATE'].blank? ? 'mp' : 'senator'
    record['first_name'] = row['INITIALS']
    record['surname'] = row['SURNAME']
    record['email'] = row['CONTACT ADDRESS EMAIL']
    record['office_address'] = contact_address(row)
    record['office_suburb'] = row['CONTACT ADDRESS SUBURB']
    record['office_postcode'] = row['CONTACT ADDRESS POSTCODE']
    record['office_state'] = row['CONTACT ADDRESS STATE']
    record['office_fax'] = row['CONTACT ADDRESS PHONE']
    record['office_phone'] = row['CONTACT ADDRESS FAX']
    record['party'] = row['PARTY']
    record['electorate'] = row['ELECTORATE']
    [key, record]
  end

  def contact_address(row)
    address = row['CONTACT ADDRESS LINE1']
    address += ' ' + row['CONTACT ADDRESS LINE2'] if row['CONTACT ADDRESS LINE2']
    address += ' ' + row['CONTACT ADDRESS LINE3'] if row['CONTACT ADDRESS LINE3']
    address.strip
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
