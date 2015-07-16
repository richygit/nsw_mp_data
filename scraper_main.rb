require_relative 'csv_scraper'
require_relative 'web_scraper'
require './logging'

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

  def merge_records(csv, web)
    web.each do |keys, record|
      keys.each { |key| csv[key].merge(record) if csv[key] }
    end
  end
end
