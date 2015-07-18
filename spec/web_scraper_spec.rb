require 'spec_helper'
require_relative '../web_scraper'

RSpec.describe WebScraper do
  it "can download the search page" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(WebScraper::WEB_HOST, 80) {|http| expect(http.head(WebScraper::WEB_PATH).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr do
    it "finds the right MP data" do
      records = subject.scrape

      expect(records.count).to eq 93+42
      expect(records).to include(["Damien", "Tudehope", ["0298770266"]])
      expect(records).to include(["Stuart", "Ayres", ["0285746500", "0247228660"]])
    end
  end
end
