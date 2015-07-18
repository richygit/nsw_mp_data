require 'spec_helper'
require_relative '../csv_scraper'
require 'open-uri'

describe CsvScraper do
  it "can download the CSV files" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::CSV_PATH).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr do
    it "scrapes details correctly" do
      records = subject.scrape
      penrith = records["0247228660"]
      expect(penrith.to_h).to eq PENRITH_RECORD
      cessnock = records["0249911466"]
      expect(cessnock.to_h).to eq CESSNOCK_RECORD
      ajaka = records["0292303640"]
      expect(ajaka.to_h).to eq AJAKA_RECORD
    end

    it "scrapes the right number of MPs and senators" do
      records = subject.scrape
      expect(records.select{ |_,v| v['type'] == 'mp'}.count).to eq 93
      expect(records.select{ |_,v| v['type'] == 'senator'}.count).to eq 42
    end
  end

  AJAKA_RECORD = {"type"=>"senator", "surname"=>"Ajaka", "email"=>"office@ajaka.minister.nsw.gov.au", "office_address"=>"Parliament House Macquarie Street", "office_suburb"=>"Sydney", "office_postcode"=>"2000", "office_state"=>"NSW", "office_fax"=>"(02) 9230 3620", "office_phone"=>"0292303640", "party"=>"Liberal Party", "electorate"=>nil, "ministerial_office_phone"=>"0285746400"}

  PENRITH_RECORD = {"type"=>"mp", "surname"=>"Ayres", "email"=>"penrith@parliament.nsw.gov.au", "office_address"=>"Shop 23 Ground Floor Penrith Centre 510-534 High Street", "office_suburb"=>"PENRITH", "office_postcode"=>"2750", "office_state"=>"NSW", "office_fax"=>"(02) 4731 4782", "office_phone"=>"0247228660", "party"=>"Liberal Party", "electorate"=>"Penrith", "ministerial_office_phone"=>"0285746500"}

  CESSNOCK_RECORD = {"type"=>"mp", "surname"=>"Barr", "email"=>"cessnock@parliament.nsw.gov.au", "office_address"=>"118 Vincent Street", "office_suburb"=>"CESSNOCK", "office_postcode"=>"2325", "office_state"=>"NSW", "office_fax"=>"(02) 4991 1103", "office_phone"=>"0249911466", "party"=>"Australian Labor Party", "electorate"=>"Cessnock", "ministerial_office_phone"=>nil}
end

