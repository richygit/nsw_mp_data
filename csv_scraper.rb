require './logging'
require 'csv'
require 'open-uri'

class CsvScraper < Logging
  CSV_HOST = 'www.parliament.nsw.gov.au'
  CSV_PATH = '/prod/parlment/members.nsf/reports/ContactSpreadsheetAll.csv'
  CSV_URL = "http://#{CSV_HOST}#{CSV_PATH}"

  def scrape
    records = {}
    #set quote char to zero string so it doesn't trip up on BS double quotes
    csv = CSV.read(open(CSV_URL), :headers => :true, quote_char: "\x00")
    headers = csv.headers
    csv.each do |line|
      key, record = parse_record(line, headers)
      records[key] = record
    end
    records
  end

private

  def blank?(str)
    str == nil || str !~ /\S/ 
  end

  def clean_phone_no(phone_no)
    phone_no.scan(/\(\d{2}\)\s*\d*\s*\d*/).first
  end

  def parse_record(row, headers)
    key = clean_phone_no(row['CONTACT ADDRESS PHONE'])
    record = {}
    record['type'] = row['ELECTORATE'] && !blank?(row['ELECTORATE']) ? 'mp' : 'senator'
    record['surname'] = row['SURNAME']
    record['email'] = row['CONTACT ADDRESS EMAIL']
    record['office_address'] = contact_address(row)
    record['office_suburb'] = row['CONTACT ADDRESS SUBURB']
    record['office_postcode'] = row['CONTACT ADDRESS POSTCODE']
    record['office_state'] = row['CONTACT ADDRESS STATE']
    record['office_fax'] = row['CONTACT ADDRESS FAX']
    record['office_phone'] = clean_phone_no(row['CONTACT ADDRESS PHONE'])
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
end
