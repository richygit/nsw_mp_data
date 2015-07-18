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
      penrith = records["(02) 4722 8660"]
      expect(penrith.to_h).to eq PENRITH_RECORD
    end

    it "scrapes the right number of MPs and senators" do
      records = subject.scrape
      expect(records.select{ |_,v| v['type'] == 'mp'}.count).to eq 93
      expect(records.select{ |_,v| v['type'] == 'senator'}.count).to eq 42
    end
  end

  PENRITH_RECORD = {"type"=>"mp", "first_name"=>"S.L.", "surname"=>"Ayres", "email"=>"penrith@parliament.nsw.gov.au", "office_address"=>"Shop 23 Ground Floor Penrith Centre 510-534 High Street", "office_suburb"=>"PENRITH", "office_postcode"=>"2750", "office_state"=>"NSW", "office_fax"=>"(02) 4722 8660", "office_phone"=>"(02) 4731 4782", "party"=>"Liberal Party", "electorate"=>"Penrith"}
end

