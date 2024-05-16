CREATE TABLE movies (
    movie_id VARCHAR PRIMARY KEY,
    movie_title VARCHAR(100) NOT NULL,
    release_year INTEGER,
    runtime INTEGER,
    budget NUMERIC(12, 2),
    box_office NUMERIC(12, 2)
);
CREATE TABLE chapters (
    chapter_id VARCHAR PRIMARY KEY,
    chapter_name VARCHAR(100) NOT NULL,
    movie_id VARCHAR REFERENCES movies(movie_id),
    movie_chapter VARCHAR(50)
);
CREATE TABLE characters (
    character_id VARCHAR PRIMARY KEY,
    character_name VARCHAR(100) NOT NULL,
    species VARCHAR(50),
    gender VARCHAR(10),
    house VARCHAR(50),
    patronus VARCHAR(50),
    wand_wood VARCHAR(50),
    wand_core VARCHAR(50)
);
CREATE TABLE places (
    place_id VARCHAR PRIMARY KEY,
    place_name VARCHAR(100) NOT NULL,
    place_category VARCHAR(50)
);
CREATE TABLE spells (
    spell_id VARCHAR PRIMARY KEY,
    incantation VARCHAR(100) NOT NULL,
    spell_name VARCHAR(100),
    effect VARCHAR(100),
    light VARCHAR(20)
);
CREATE TABLE dialogue (
    dialogue_id VARCHAR PRIMARY KEY,
    chapter_id VARCHAR REFERENCES chapters(chapter_id),
    place_id VARCHAR REFERENCES places(place_id),
    character_id VARCHAR REFERENCES characters(character_id),
    dialogue TEXT
);

-- Disable foreign key constraint
ALTER TABLE chapters DROP CONSTRAINT chapters_movie_id_fkey;


-- Add a new column "caster_id" to the "spells" table
ALTER TABLE spells
ADD COLUMN caster_id VARCHAR REFERENCES characters(character_id);
