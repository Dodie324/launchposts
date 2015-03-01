DROP TABLE IF EXISTS ruby_posts, html_css_posts, javascript_posts, misc, posts, languages;

CREATE TABLE languages (
  id serial PRIMARY KEY,
  language VARCHAR(50) NOT NULL
);

CREATE TABLE posts (
  id serial PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  url VARCHAR(255) UNIQUE,
  description VARCHAR(255) NOT NULL,
  language_id int REFERENCES languages(id) NOT NULL
);
