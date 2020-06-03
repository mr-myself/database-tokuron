require 'nokogiri'
require 'byebug'
require 'open-uri'
require 'sqlite3'

def extract_job_ids_from(doc)
  doc.search('.listResults div').map do |card|
    next if card.text.include?('Are you looking for a job?')
    break if card.text.include?('You might be interested in these jobs')
    next if card.first.first != 'data-jobid'

    card.first[1] #card.first['data-jobid']
  end
end

def extract_from_detail_box(attr)
  detail_box = text(@doc.css('.job-details--about').text)
  matched =  detail_box.match(/#{attr}:\s+([a-zA-Z0-9\-]+(\s?)[a-zA-Z0-9]+)/)
  matched[1] if matched
end

def text(text)
  return unless text
  text.strip.chomp
    .gsub(/[\r|\n|–]/, '')
    .gsub(/â/ , '')
    .gsub(/[\u0080-\u00ff]/, '-')
end

def extract_job_description
  job_description = text(@doc.css('section.fs-body2').first&.css('p')&.first&.text)
  return job_description unless job_description.nil?

  text(@doc.css('section.fs-body2').first&.css('div')&.first&.text)
end

def build_company_data(country_id, job_url)
  {
    country_id: country_id,
    name: text(@doc.css('header a.fc-black-700').text),
    location: text(@doc.css('header .fc-black-500').first&.text),
    url: job_url,
    company_size: extract_from_detail_box('Company size')
  }
end

def build_job_offer_data(company_id)
  {
    company_id: company_id,
    title: text(@doc.css('h1.fs-headline1').text),
    salary: text(@doc.css('.-salary').text),
    job_type: extract_from_detail_box('Job type'),
    experience_level: extract_from_detail_box('Experience level'),
    job_description: extract_job_description
  }
end

def build_statistics_data(job_offer_id)
  {
    job_offer_id: job_offer_id,
    likes: text(@doc.css('.js-react-toggle').first&.text).to_i,
    dislikes: text(@doc.css('.js-react-toggle')[1]&.text).to_i,
    loves: text(@doc.css('.js-react-toggle').last&.text).to_i,
  }
end

def sql_insert_country(country)
  @db.transaction
  @db.execute('INSERT OR IGNORE INTO countries(name) values(?)', country)
  @db.commit
  @db.execute('SELECT id FROM countries WHERE name = ?', country).first.first
end

def sql_insert_company(company)
  @db.transaction
  @db.execute(
    'INSERT OR IGNORE INTO companies(country_id, name, location, url, company_size) VALUES(?, ?, ?, ?, ?)', [
      company[:country_id], company[:name], company[:location],
      company[:url], company[:company_size]
    ]
  )
  @db.commit
end

def sql_insert_job_offers(job_offer)
  @db.transaction
  @db.execute(
    'INSERT OR IGNORE INTO job_offers(company_id, title, salary, job_type, experience_level, job_description) values(?, ?, ?, ?, ?, ?)',
    [
      job_offer[:company_id], job_offer[:title], job_offer[:salary],
      job_offer[:job_type], job_offer[:experience_level], job_offer[:job_description]
    ]
  )
  @db.commit
end

def sql_insert_statistics(statistics)
  @db.transaction
  @db.execute(
    'INSERT OR IGNORE INTO statistics(job_offer_id, likes, dislikes, loves) values(?, ?, ?, ?)',
    [
      statistics[:job_offer_id], statistics[:likes],
      statistics[:dislikes], statistics[:loves]
    ]
  )
  @db.commit
end

def sql_insert_skills(skills)
  skills.each do |skill|
    @db.execute('INSERT OR IGNORE INTO skills(name) values(?)', skill)
  end
end

def sql_map_job_offers_and_skills(job_offer_id, skill_ids)
  skill_ids.each do |id|
    @db.execute('
      INSERT OR IGNORE INTO map_job_offers_skills(job_offer_id, skill_id) values(?, ?)', [job_offer_id, id]
    )
  end
end

def find_or_create_company(company_data)
  if data = get_company_id(company_data).first
    data.first
  else
    sql_insert_company(company_data)
    get_company_id(company_data).first.first
  end
end

def find_or_create_job_offer(job_offer_data)
  if data = get_job_offer_id(job_offer_data).first
    data.first
  else
    sql_insert_job_offers(job_offer_data)
    get_job_offer_id(job_offer_data).first.first
  end
end

def find_or_create_skills(skills)
  data = get_skill_ids(skills)
  if data.length > 0
    data.flatten
  else
    sql_insert_skills(skills)
    get_skill_ids(skills).flatten
  end
end

def get_company_id(company_data)
  @db.execute(
    'SELECT id FROM companies WHERE country_id = ? AND name = ?',
    company_data[:country_id], company_data[:name]
  )
end

def get_job_offer_id(job_offer_data)
  @db.execute(
    'SELECT id FROM job_offers WHERE company_id = ? AND title = ?',
    job_offer_data[:company_id], job_offer_data[:title]
  )
end

def get_skill_ids(skills)
  placeholders = (['?'] * skills.length).join(',')
  @db.execute(
    "SELECT id FROM skills WHERE name IN (#{placeholders})",
    skills
  )
end

countries = %w(United+States Germany Netherlands Canada)
detail_url = 'https://stackoverflow.com/jobs/'
@db = SQLite3::Database.new('overseas_job_offers.db')

countries.each do |country|
  url = "https://stackoverflow.com/jobs?l=#{country}&d=20&u=Km"
  country_id = sql_insert_country(country)

  extract_job_ids_from(Nokogiri::HTML(open(url))).each do |id|
    next unless id

    p "parse job_id: #{id}"
    job_url = "#{detail_url}#{id}"
    @doc = Nokogiri::HTML(open(job_url))

    company_id = find_or_create_company(
      build_company_data(country_id, job_url)
    )
    job_offer_id = find_or_create_job_offer(
      build_job_offer_data(company_id)
    )
    sql_insert_statistics(build_statistics_data(job_offer_id))

    skills = []
    @doc.css('.post-tag.no-tag-menu').each do |tag|
      skills << text(tag.text)
    end
    skill_ids = find_or_create_skills(skills)
    sql_map_job_offers_and_skills(job_offer_id, skill_ids)
  end
end

@db.close
