CREATE TABLE IF NOT EXISTS countries(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  UNIQUE(name)
);

CREATE TABLE IF NOT EXISTS companies(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  country_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  company_size INT,
  location TEXT,
  url TEXT,
  UNIQUE(name, country_id),
  FOREIGN KEY(country_id) REFERENCES countries(id)
);

CREATE TABLE IF NOT EXISTS job_offers(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  company_id INTEGER NOT NULL,
  title TEXT,
  salary TEXT,
  job_description TEXT,
  experience_level TEXT,
  job_type INT,
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY(company_id) REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS statistics(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_offer_id INTEGER NOT NULL,
  likes INT,
  dislikes INT,
  loves INT,
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY(job_offer_id) REFERENCES job_offers(id)
);

CREATE TABLE IF NOT EXISTS skills(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  UNIQUE(name)
);

CREATE TABLE IF NOT EXISTS map_job_offers_skills(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_offer_id INTEGER NOT NULL,
  skill_id INTEGER NOT NULL,
  FOREIGN KEY(job_offer_id) REFERENCES job_offers(id),
  FOREIGN KEY(skill_id) REFERENCES skills(id)
);
