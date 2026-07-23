-- CHRONOS Knowledge Base Seed - Fontes Bibliográficas
-- Referências verificáveis para os 10 personagens

-- Fontes de Cleópatra
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_cleopatra', 'Plutarco', 'Vidas Paralelas - Vida de Antônio', 'Vidas Paralelas', 75, 'fact'),
('char_cleopatra', 'Dião Cássio', 'História Romana, Livros 42-51', 'História Romana', 230, 'fact'),
('char_cleopatra', 'Duane W. Roller', 'Cleopatra: A Biography', 'Cleopatra: A Biography', 2010, 'fact'),
('char_cleopatra', 'Stacy Schiff', 'Cleopatra: A Life', 'Cleopatra: A Life', 2010, 'fact');

-- Fontes de Alexandre
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_alexandre', 'Arriano', 'Anábase de Alexandre', 'Anábase de Alexandre', 150, 'fact'),
('char_alexandre', 'Plutarco', 'Vidas Paralelas - Vida de Alexandre', 'Vidas Paralelas', 75, 'fact'),
('char_alexandre', 'Robin Lane Fox', 'Alexander the Great', 'Alexander the Great', 1973, 'fact'),
('char_alexandre', 'Peter Green', 'Alexander of Macedon', 'Alexander of Macedon, 356-323 B.C.', 1991, 'fact');

-- Fontes de Júlio César
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_cesar', 'Júlio César', 'Commentarii de Bello Gallico', 'De Bello Gallico', -50, 'fact'),
('char_cesar', 'Suetônio', 'Vidas dos Doze Césares - Divino Júlio', 'Vidas dos Doze Césares', 121, 'fact'),
('char_cesar', 'Adrian Goldsworthy', 'Caesar: Life of a Colossus', 'Caesar: Life of a Colossus', 2006, 'fact'),
('char_cesar', 'Tom Holland', 'Rubicon: The Last Years of the Roman Republic', 'Rubicon', 2003, 'fact');

-- Fontes de Sócrates
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_socrates', 'Platão', 'Apologia de Sócrates', 'Diálogos de Platão', -399, 'fact'),
('char_socrates', 'Xenofonte', 'Memoráveis', 'Memoráveis', -371, 'fact'),
('char_socrates', 'W.K.C. Guthrie', 'Socrates', 'A History of Greek Philosophy, Vol. III', 1969, 'fact'),
('char_socrates', 'Gregory Vlastos', 'Socrates: Ironist and Moral Philosopher', 'Socrates: Ironist and Moral Philosopher', 1991, 'fact');

-- Fontes de Leonardo da Vinci
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_davinci', 'Giorgio Vasari', 'Vidas dos Artistas - Leonardo', 'Le Vite', 1550, 'fact'),
('char_davinci', 'Walter Isaacson', 'Leonardo da Vinci', 'Leonardo da Vinci', 2017, 'fact'),
('char_davinci', 'Martin Kemp', 'Leonardo da Vinci: The Marvellous Works of Nature and Man', 'Leonardo da Vinci', 2006, 'fact'),
('char_davinci', 'Carlo Pedretti', 'Leonardo: A Study in Chronology and Style', 'Leonardo', 1973, 'fact');

-- Fontes de Napoleão
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_napoleao', 'Andrew Roberts', 'Napoleon: A Life', 'Napoleon: A Life', 2014, 'fact'),
('char_napoleao', 'Adam Zamoyski', 'Napoleon: A Life', 'Napoleon: A Life', 2018, 'fact'),
('char_napoleao', 'Las Cases', 'Mémorial de Sainte-Hélène', 'Mémorial de Sainte-Hélène', 1823, 'fact'),
('char_napoleao', 'Jean Tulard', 'Napoléon ou le Mythe du Sauveur', 'Napoléon', 1977, 'fact');

-- Fontes de Carlos Magno
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_carlosmagno', 'Eginardo', 'Vita Karoli Magni', 'Vita Karoli Magni', 830, 'fact'),
('char_carlosmagno', 'Alessandro Barbero', 'Charlemagne: Father of a Continent', 'Charlemagne', 2004, 'fact'),
('char_carlosmagno', 'Rosamond McKitterick', 'Charlemagne: The Formation of a European Identity', 'Charlemagne', 2008, 'fact');

-- Fontes de Ramsés II
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_ramses', 'Kenneth Kitchen', 'Pharaoh Triumphant: The Life and Times of Ramesses II', 'Pharaoh Triumphant', 1982, 'fact'),
('char_ramses', 'Joyce Tyldesley', 'Ramesses: Egypt''s Greatest Pharaoh', 'Ramesses', 2000, 'fact'),
('char_ramses', 'Maneton', 'Aegyptiaca (fragmentos)', 'Aegyptiaca', -280, 'fact');

-- Fontes de Gêngis Khan
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_genghis', 'Jack Weatherford', 'Genghis Khan and the Making of the Modern World', 'Genghis Khan', 2004, 'fact'),
('char_genghis', 'Rashid al-Din', 'Jami'' al-tawarikh (Compêndio de Crônicas)', 'Jami al-tawarikh', 1307, 'fact'),
('char_genghis', 'Autor Desconhecido', 'A História Secreta dos Mongóis', 'Historia Secreta dos Mongóis', 1240, 'fact'),
('char_genghis', 'Frank McLynn', 'Genghis Khan: His Conquests, His Empire, His Legacy', 'Genghis Khan', 2015, 'fact');

-- Fontes de Churchill
INSERT INTO knowledge_sources (entity_id, autor, titulo, livro, ano_publicacao, confiabilidade) VALUES
('char_churchill', 'Winston Churchill', 'The Second World War (6 volumes)', 'The Second World War', 1953, 'fact'),
('char_churchill', 'Martin Gilbert', 'Churchill: A Life', 'Churchill: A Life', 1991, 'fact'),
('char_churchill', 'Andrew Roberts', 'Churchill: Walking with Destiny', 'Churchill: Walking with Destiny', 2018, 'fact'),
('char_churchill', 'Roy Jenkins', 'Churchill: A Biography', 'Churchill', 2001, 'fact');
