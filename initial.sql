CREATE TABLE IF NOT EXISTS countries(
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  UNIQUE(name)
);

CREATE TABLE IF NOT EXISTS companies(
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  country_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  company_size INT,
  location TEXT,
  url TEXT,
  UNIQUE(name, country_id)
  FOREIGN KEY(country_id) REFERENCES countries(id)
);

CREATE TABLE IF NOT EXISTS job_offers(
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  company_id INTEGER NOT NULL,
  salary TEXT,
  requirements TEXT,
  bonus_points TEXT,
  working_style TEXT,
  company_size INT,
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY(company_id) REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS statistics(
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  job_offer_id INTEGER NOT NULL,
  views INT,
  likes INT,
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY(job_offer_id) REFERENCES job_offers(id)
);
