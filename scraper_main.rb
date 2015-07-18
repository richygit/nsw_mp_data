require_relative 'csv_scraper'
require_relative 'web_scraper'
require './logging'
require 'scraperwiki'

class ScraperMain < Logging
  def main
    csv_records = CsvScraper.new.scrape
    web_records = WebScraper.new.scrape

    merge_records(csv_records, web_records).each do |key, record|
      @logger.info("### Saving #{record['first_name']} #{record['surname']}")
      puts("### Saving #{record['first_name']} #{record['surname']}")
      ScraperWiki::save(['first_name', 'surname'], record)
    end
  end

  def match_on_alternate_key(web, csv_records)
    csv_records.each do |key, record|
      if record['ministerial_office_phone'] && web[2].include?(record['ministerial_office_phone'])
        record.merge!({'first_name' => web[0]}) 
        return true
      end
    end
    return false
  end

  require 'pry'

  def merge_records(csv, web)
    web.each do |web_record|
      phone_nos = web_record[2]
      matched = false
      phone_nos.each do |phone_no| 
        if csv[phone_no]
          csv[phone_no].merge!({'first_name' => web_record[0]}) 
          matched = true
        end
      end
      unless matched
        unless match_on_alternate_key(web_record, csv)
          @logger.error("Unable to find matching CSV record for: #{web_record}")
        end
      end
    end
    csv
  end
end
