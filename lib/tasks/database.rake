require "mysql2"
require "yaml"
require "nokogiri"
require "reverse_markdown"

namespace :database do
  namespace :legacy do
    desc "Import news records to database"
    task :import_news => :environment do
      NewsItem.destroy_all
      records = YAML.load_file "#{Rails.root}/db/legacy.yml"
      records.each do |data|
        news_item = NewsItem.new
        news_item.state = :published
        news_item.title = data["post_title"]
        news_item.body = data['post_content']
        news_item.published_at = published_at = data["post_date"]
        # url: http://www.montrealrb.com/[post_date:YYYY]/[post_date:MM]/[post_name]
        news_item.legacy_slug = "#{published_at.strftime("%Y")}/#{published_at.strftime("%m")}/#{data["post_name"]}"
        puts news_item.legacy_slug
        begin
          news_item.save!
        rescue => e
          puts news_item.inspect
        end
      end
    end

    desc "Generate a yml files with legacy news records from wordpress mysql DB"
    task :dump => :environment do
      # database: montrealrb_wordpress
      # table: wp_posts
      # url: http://www.montrealrb.com/[post_date:YYYY]/[post_date:MM]/[post_name]
      client = Mysql2::Client.new(host: "localhost", username: "root", database: "montrealrb_wordpress")
      records = client.query("SELECT post_title, post_content, post_date, post_name FROM wp_posts WHERE post_status='publish'")

      sanitized_records = records.to_a.map do |row|
        row.each do |k, v|
          if k.to_s == "post_content"
            doc = Nokogiri.HTML(v)
            # Remove weird avatars
            doc.css("img.alignleft").each do |el|
              el.replace("")
            end
            # Remove non breaking spaces
            nbsp = Nokogiri::HTML("&nbsp;").text
            clean_html_content = doc.to_html
            clean_html_content.gsub!(nbsp, " ")
            # Remove line breaks
            clean_html_content.gsub!("<br>", "")
            # Update HTML
            row[k] = ReverseMarkdown.convert clean_html_content
          end
        end
      end
      File.open("#{Rails.root}/db/legacy.yml", "w") do |f|
        f.write sanitized_records.to_yaml
      end
    end
  end
end
