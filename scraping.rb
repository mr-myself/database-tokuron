require 'nokogiri'
require 'byebug'
require 'open-uri'

countries = %w(United+States Germany Netherlands Canada)
url = 'https://stackoverflow.com/jobs?l=United+States&d=20&u=Km'
detail_url = 'https://stackoverflow.com/jobs/'

countries.each do |country|
  # TODO: insert country

  extract_job_ids_from(Nokogiri::HTML(open(url))).each do |id|
    job_url = "#{detail_url}#{id}"
    doc = Nokogiri::HTML(open(job_url))
    {
      name: text(doc.css('header a.fc-black-700').text),
      location: text(doc.css('header .fc-black-500').first.text),
      url: job_url,
      company_size: extract_from_detail_box('Company size')
    }

    {
      title: text(doc.css('h1.fs-headline1').text),
      salary: text(doc.css('.-salary').text),
      job_type: extract_from_detail_box('Job type'),
      experience_level: extract_from_detail_box('Experience level'),
      job_description: extract_job_description
    }

    {
      likes: text(doc.css('.js-react-toggle').first.text).to_i,
      dislikes: text(doc.css('.js-react-toggle').second.text).to_i,
      loves: text(doc.css('.js-react-toggle').last.text).to_i,
    }

    tags = []
    doc.css('.post-tag.no-tag-menu').each do |tag|
      tags << text(tag.text)
    end
  end
end

def extract_job_ids_from(doc)
  doc.search('.listResults div').map do |card|
    next if card.text.include?('Are you looking for a job?')
    break if card.text.include?('You might be interested in these jobs')
    card.first['data-jobid']
  end
end

def extract_from_detail_box(attr)
  detail_box = text(doc.css('.job-details--about').text)
  detail_box.match(/#{attr}:\s+([a-zA-Z0-9\-]+(\s?)[a-zA-Z0-9]+)/)[1]
end

def text(text)
  return unless text
  text.strip.chomp
    .gsub(/[\r|\n|–]/, '')
    .gsub(/â/ , '')
    .gsub(/[\u0080-\u00ff]/, '-')
end

def extract_job_description
  job_description = text(doc.css('section.fs-body2').first.css('p').first&.text)
  if job_description.nil?
    job_description = text(doc.css('section.fs-body2').first.css('div').first&.text)
  end
  job_description
end
