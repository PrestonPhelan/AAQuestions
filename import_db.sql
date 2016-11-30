DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(50),
  lname VARCHAR(50)
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  question_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (follower_id) REFERENCES users(id),

  PRIMARY KEY(question_id, follower_id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  liker_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (liker_id) REFERENCES users(id),

  PRIMARY KEY(question_id, liker_id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Preston', 'Phelan'),
  ('Samuel', 'Lee');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('origin', 'where were you born?', 1),
  ('hobby', 'what do you like to do in spare time?', 2);

INSERT INTO
  question_follows (question_id, follower_id)
VALUES
  (1, 2),
  (2, 1);

INSERT INTO
  replies (question_id, parent_reply, user_id, body)
VALUES
  (1, NULL, 2, 'I was born in Michigan'),
  (2, NULL, 1, 'Learn SQL!');

INSERT INTO
  question_likes (question_id, liker_id)
VALUES
  (1, 2),
  (2, 1);
