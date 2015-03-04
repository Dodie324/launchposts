DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS web_development;

CREATE TABLE web_development (
  id SERIAL PRIMARY KEY,
  topic VARCHAR(50) NOT NULL
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  url VARCHAR(500) UNIQUE,
  description VARCHAR(500) NOT NULL,
  post_date DATE,
  language_id INT REFERENCES languages(id) NOT NULL,
);

INSERT INTO web_development (topic) VALUES ('Ruby');
INSERT INTO web_development (topic) VALUES ('HTML/CSS');
INSERT INTO web_development (topic) VALUES ('JavaScript/jQuery');
INSERT INTO web_development (topic) VALUES ('SQL');
INSERT INTO web_development (topic) VALUES ('Misc');
