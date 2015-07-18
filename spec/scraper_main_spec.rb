require 'spec_helper'
require_relative '../scraper_main'

RSpec.describe ScraperMain do
  before(:each) do
    ScraperWiki.config = { db: 'data.test', default_table_name: 'data' }
    ScraperWiki::sqliteexecute("drop table if exists data")
  end

  describe "#main" do
    before(:each) do
      allow_any_instance_of(CsvScraper).to receive(:scrape).and_return(EPPING_RECORD)
      allow_any_instance_of(WebScraper).to receive(:scrape).and_return([["Damien", "Tudehope", ["0298770266"]]])
    end

    it "should merge data from each scraper" do
      subject.main
      epping = ScraperWiki::select('* FROM data WHERE electorate = "Epping"')
      expect(epping.first).to eq({"first_name"=>"Damien", "surname"=>"Tudehope", "email"=>"epping@parliament.nsw.gov.au", "office_address"=>"Suite 303 Level 3 51 Rawson Street", "office_suburb"=>"EPPING", "office_postcode"=>"2121", "office_state"=>"NSW", "office_fax"=>"(02) 9877 0266", "office_phone"=>"0298770405", "party"=>"Liberal Party", "electorate"=>"Epping", "type"=>"mp"})
    end
  end

  describe "full test", :vcr do
    it "should merge all data" do
      subject.main
      records = ScraperWiki::select('* FROM data')
      expect(records.count).to eq (93+42)
    end
  end

  EPPING_RECORD = {"0298770266"=>{"type"=>"mp", "surname"=>"Tudehope", "email"=>"epping@parliament.nsw.gov.au", "office_address"=>"Suite 303 Level 3 51 Rawson Street", "office_suburb"=>"EPPING", "office_postcode"=>"2121", "office_state"=>"NSW", "office_fax"=>"(02) 9877 0266", "office_phone"=>"0298770405", "party"=>"Liberal Party", "electorate"=>"Epping"}}
end
