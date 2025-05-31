import { pool } from '../config/db.js'

class Table {
  async delete() {
    const queryText = `
      DROP TABLE IF EXISTS 
        lab_submissions,
        lab_submission_files,
        lab_groups,
        labs,
        lab_files,
        students,
        lecturer_groups,
        lecturer_subjects,
        lecturers,
        subjects,
        groups,
        users,
				tokens,
        temp_tokens
      CASCADE;
    `
    try {
      await pool.query(queryText)
      console.log('Все таблицы удалены.')
    } catch (error) {
      console.error('Ошибка при удалении таблиц:', error)
    }
  }

  async create() {
    const queryText = `
      CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) CHECK (role IN ('admin', 'lecturer', 'student')) NOT NULL
);

CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS subjects (
  id UUID PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS lecturers (
  user_id UUID PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  middle_name VARCHAR(255),
  last_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lecturer_subjects (
  lecturer_id UUID NOT NULL,
  subject_id UUID NOT NULL,
  PRIMARY KEY (lecturer_id, subject_id),
  FOREIGN KEY (lecturer_id) REFERENCES lecturers(user_id) ON DELETE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lecturer_groups (
  lecturer_id UUID NOT NULL,
  group_id UUID NOT NULL,
  PRIMARY KEY (lecturer_id, group_id),
  FOREIGN KEY (lecturer_id) REFERENCES lecturers(user_id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS students (
  user_id UUID PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  middle_name VARCHAR(255),
  last_name VARCHAR(255) NOT NULL,
  group_id UUID,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS labs (
  id UUID PRIMARY KEY,
  lecturer_id UUID NOT NULL,
  subject_id UUID NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY (lecturer_id) REFERENCES lecturers(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lab_files (
  id UUID PRIMARY KEY,
  lab_id UUID NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  FOREIGN KEY (lab_id) REFERENCES labs(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lab_submissions (
  id UUID PRIMARY KEY,
  lab_id UUID NOT NULL,
  student_id UUID NOT NULL,
  grade INT,
  submitted_at TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(user_id) ON DELETE CASCADE,
  FOREIGN KEY (lab_id) REFERENCES labs(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lab_submission_files (
  id UUID PRIMARY KEY,
  lab_submission_id UUID NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  FOREIGN KEY (lab_submission_id) REFERENCES lab_submissions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lab_groups (
  lab_id UUID NOT NULL,
  group_id UUID NOT NULL,
  PRIMARY KEY (lab_id, group_id),
  FOREIGN KEY (lab_id) REFERENCES labs(id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  refresh_token TEXT NOT NULL,
  ip_address INET NOT NULL,
  user_agent TEXT NOT NULL,
  unique_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  is_revoked BOOLEAN DEFAULT FALSE NOT NULL,
  UNIQUE(user_id, unique_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS temp_tokens (
  user_id UUID NOT NULL UNIQUE,
  temp_token TEXT NOT NULL,
  code VARCHAR(6) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
    `
    try {
      await pool.query(queryText)
      console.log('Все таблицы созданы (если их не было).')
    } catch (error) {
      console.error('Ошибка при создании таблиц:', error)
    }
  }
}

export default new Table()
