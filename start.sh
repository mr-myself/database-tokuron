docker build . -t scraping_indeed
docker run scraping_indeed bundle exec ruby scraping.rb
