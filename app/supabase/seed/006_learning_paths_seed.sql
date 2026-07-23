-- CHRONOS Sprint 8.3.0 - Learning Paths Seed Data
-- 8 trilhas com módulos reais

-- ============================================================
-- 1. Egito Antigo
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000001', 'Egito Antigo', 'Explore a fascinante civilização do Nilo, dos faraós às pirâmides.', 'antiquity', 'beginner', 90, 3, 9, 200, 'egypt_master', 1);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'Surgimento do Egito', 'As origens da civilização egípcia.', 1, 3),
('b1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'Reino Antigo', 'A era das grandes pirâmides.', 2, 3),
('b1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', 'Reino Novo', 'O auge do poder egípcio.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000001', 'civ_egypt_origins', 'civilization', 'Alto e Baixo Egito', 1),
('b1000000-0000-0000-0000-000000000001', 'evt_unification', 'event', 'Unificação do Egito', 2),
('b1000000-0000-0000-0000-000000000001', 'char_narmer', 'character', 'Narmer', 3),
('b1000000-0000-0000-0000-000000000002', 'evt_pyramids', 'event', 'Construção das Pirâmides', 1),
('b1000000-0000-0000-0000-000000000002', 'char_khufu', 'character', 'Quéops', 2),
('b1000000-0000-0000-0000-000000000002', 'loc_giza', 'location', 'Gizé', 3),
('b1000000-0000-0000-0000-000000000003', 'char_ramses', 'character', 'Ramsés II', 1),
('b1000000-0000-0000-0000-000000000003', 'char_tutankhamun', 'character', 'Tutancâmon', 2),
('b1000000-0000-0000-0000-000000000003', 'evt_battle_kadesh', 'event', 'Batalha de Kadesh', 3);

-- ============================================================
-- 2. Império Romano
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000002', 'Império Romano', 'Da fundação de Roma à queda do Império Ocidental.', 'civilizations', 'intermediate', 120, 3, 9, 250, 'rome_master', 2);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000004', 'a1000000-0000-0000-0000-000000000002', 'República Romana', 'As origens de Roma e a era republicana.', 1, 3),
('b1000000-0000-0000-0000-000000000005', 'a1000000-0000-0000-0000-000000000002', 'Alto Império', 'A Pax Romana e os grandes imperadores.', 2, 3),
('b1000000-0000-0000-0000-000000000006', 'a1000000-0000-0000-0000-000000000002', 'Queda de Roma', 'O declínio e a queda do Império Ocidental.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000004', 'evt_founding_rome', 'event', 'Fundação de Roma', 1),
('b1000000-0000-0000-0000-000000000004', 'char_julius_caesar', 'character', 'Júlio César', 2),
('b1000000-0000-0000-0000-000000000004', 'evt_punic_wars', 'event', 'Guerras Púnicas', 3),
('b1000000-0000-0000-0000-000000000005', 'char_augustus', 'character', 'Augusto', 1),
('b1000000-0000-0000-0000-000000000005', 'evt_pax_romana', 'event', 'Pax Romana', 2),
('b1000000-0000-0000-0000-000000000005', 'loc_colosseum', 'location', 'Coliseu', 3),
('b1000000-0000-0000-0000-000000000006', 'evt_fall_rome', 'event', 'Queda de Roma', 1),
('b1000000-0000-0000-0000-000000000006', 'char_constantine', 'character', 'Constantino', 2),
('b1000000-0000-0000-0000-000000000006', 'evt_division_empire', 'event', 'Divisão do Império', 3);

-- ============================================================
-- 3. Grécia Antiga
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000003', 'Grécia Antiga', 'O berço da democracia, filosofia e artes.', 'antiquity', 'beginner', 100, 3, 9, 200, 'greece_master', 3);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000007', 'a1000000-0000-0000-0000-000000000003', 'Cidades-Estado', 'Atenas, Esparta e o mundo grego.', 1, 3),
('b1000000-0000-0000-0000-000000000008', 'a1000000-0000-0000-0000-000000000003', 'Filosofia Grega', 'De Sócrates a Aristóteles.', 2, 3),
('b1000000-0000-0000-0000-000000000009', 'a1000000-0000-0000-0000-000000000003', 'Alexandre o Grande', 'A conquista do mundo conhecido.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000007', 'civ_athens', 'civilization', 'Atenas', 1),
('b1000000-0000-0000-0000-000000000007', 'civ_sparta', 'civilization', 'Esparta', 2),
('b1000000-0000-0000-0000-000000000007', 'evt_persian_wars', 'event', 'Guerras Persas', 3),
('b1000000-0000-0000-0000-000000000008', 'char_socrates', 'character', 'Sócrates', 1),
('b1000000-0000-0000-0000-000000000008', 'char_plato', 'character', 'Platão', 2),
('b1000000-0000-0000-0000-000000000008', 'char_aristotle', 'character', 'Aristóteles', 3),
('b1000000-0000-0000-0000-000000000009', 'char_alexander', 'character', 'Alexandre o Grande', 1),
('b1000000-0000-0000-0000-000000000009', 'evt_battle_gaugamela', 'event', 'Batalha de Gaugamela', 2),
('b1000000-0000-0000-0000-000000000009', 'civ_hellenistic', 'civilization', 'Mundo Helenístico', 3);

-- ============================================================
-- 4. Idade Média
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000004', 'Idade Média', 'Feudalismo, cruzadas e o surgimento das nações.', 'middleAges', 'intermediate', 110, 3, 9, 250, 'medieval_master', 4);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000010', 'a1000000-0000-0000-0000-000000000004', 'Alta Idade Média', 'Queda de Roma e feudalismo.', 1, 3),
('b1000000-0000-0000-0000-000000000011', 'a1000000-0000-0000-0000-000000000004', 'As Cruzadas', 'Guerras santas e comércio.', 2, 3),
('b1000000-0000-0000-0000-000000000012', 'a1000000-0000-0000-0000-000000000004', 'Baixa Idade Média', 'Peste, renascimento das cidades.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000010', 'char_charlemagne', 'character', 'Carlos Magno', 1),
('b1000000-0000-0000-0000-000000000010', 'evt_feudalism', 'event', 'Surgimento do Feudalismo', 2),
('b1000000-0000-0000-0000-000000000010', 'civ_frankish', 'civilization', 'Império Carolíngio', 3),
('b1000000-0000-0000-0000-000000000011', 'evt_first_crusade', 'event', 'Primeira Cruzada', 1),
('b1000000-0000-0000-0000-000000000011', 'evt_third_crusade', 'event', 'Terceira Cruzada', 2),
('b1000000-0000-0000-0000-000000000011', 'char_saladin', 'character', 'Saladino', 3),
('b1000000-0000-0000-0000-000000000012', 'evt_black_death', 'event', 'Peste Negra', 1),
('b1000000-0000-0000-0000-000000000012', 'evt_hundred_years_war', 'event', 'Guerra dos Cem Anos', 2),
('b1000000-0000-0000-0000-000000000012', 'char_joan_of_arc', 'character', 'Joana d''Arc', 3);

-- ============================================================
-- 5. Renascimento
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000005', 'Renascimento', 'A revolução cultural que mudou a Europa.', 'modernAge', 'intermediate', 80, 3, 9, 200, 'renaissance_master', 5);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000013', 'a1000000-0000-0000-0000-000000000005', 'Origens na Itália', 'Florença e o Quattrocento.', 1, 3),
('b1000000-0000-0000-0000-000000000014', 'a1000000-0000-0000-0000-000000000005', 'Grandes Mestres', 'Da Vinci, Michelangelo, Rafael.', 2, 3),
('b1000000-0000-0000-0000-000000000015', 'a1000000-0000-0000-0000-000000000005', 'Renascimento Europeu', 'A expansão além da Itália.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000013', 'civ_florence', 'civilization', 'Florença Renascentista', 1),
('b1000000-0000-0000-0000-000000000013', 'char_medici', 'character', 'Família Médici', 2),
('b1000000-0000-0000-0000-000000000013', 'evt_printing_press', 'event', 'Invenção da Imprensa', 3),
('b1000000-0000-0000-0000-000000000014', 'char_da_vinci', 'character', 'Leonardo da Vinci', 1),
('b1000000-0000-0000-0000-000000000014', 'char_michelangelo', 'character', 'Michelangelo', 2),
('b1000000-0000-0000-0000-000000000014', 'art_sistine_chapel', 'artifact', 'Capela Sistina', 3),
('b1000000-0000-0000-0000-000000000015', 'evt_reformation', 'event', 'Reforma Protestante', 1),
('b1000000-0000-0000-0000-000000000015', 'char_erasmus', 'character', 'Erasmo de Roterdã', 2),
('b1000000-0000-0000-0000-000000000015', 'char_shakespeare', 'character', 'Shakespeare', 3);

-- ============================================================
-- 6. Revolução Francesa
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000006', 'Revolução Francesa', 'Liberdade, igualdade e fraternidade.', 'modernAge', 'advanced', 100, 3, 9, 300, 'french_rev_master', 6);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000016', 'a1000000-0000-0000-0000-000000000006', 'Causas', 'O Antigo Regime e suas crises.', 1, 3),
('b1000000-0000-0000-0000-000000000017', 'a1000000-0000-0000-0000-000000000006', 'A Revolução', 'Da Bastilha ao Terror.', 2, 3),
('b1000000-0000-0000-0000-000000000018', 'a1000000-0000-0000-0000-000000000006', 'Consequências', 'Napoleão e a Europa pós-revolução.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000016', 'evt_ancien_regime', 'event', 'Antigo Regime', 1),
('b1000000-0000-0000-0000-000000000016', 'char_louis_xvi', 'character', 'Luís XVI', 2),
('b1000000-0000-0000-0000-000000000016', 'evt_estates_general', 'event', 'Estados Gerais', 3),
('b1000000-0000-0000-0000-000000000017', 'evt_storming_bastille', 'event', 'Queda da Bastilha', 1),
('b1000000-0000-0000-0000-000000000017', 'char_robespierre', 'character', 'Robespierre', 2),
('b1000000-0000-0000-0000-000000000017', 'evt_reign_of_terror', 'event', 'Período do Terror', 3),
('b1000000-0000-0000-0000-000000000018', 'char_napoleon', 'character', 'Napoleão Bonaparte', 1),
('b1000000-0000-0000-0000-000000000018', 'evt_napoleonic_wars', 'event', 'Guerras Napoleônicas', 2),
('b1000000-0000-0000-0000-000000000018', 'evt_congress_vienna', 'event', 'Congresso de Viena', 3);

-- ============================================================
-- 7. Segunda Guerra Mundial
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000007', 'Segunda Guerra Mundial', 'O maior conflito da história humana.', 'greatWars', 'advanced', 140, 3, 9, 350, 'ww2_master', 7);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000019', 'a1000000-0000-0000-0000-000000000007', 'Ascensão do Nazismo', 'Da crise à guerra.', 1, 3),
('b1000000-0000-0000-0000-000000000020', 'a1000000-0000-0000-0000-000000000007', 'O Conflito', 'Frentes de batalha e estratégias.', 2, 3),
('b1000000-0000-0000-0000-000000000021', 'a1000000-0000-0000-0000-000000000007', 'Fim e Consequências', 'Holocausto, bombas atômicas e pós-guerra.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000019', 'char_hitler', 'character', 'Adolf Hitler', 1),
('b1000000-0000-0000-0000-000000000019', 'evt_treaty_versailles', 'event', 'Tratado de Versalhes', 2),
('b1000000-0000-0000-0000-000000000019', 'evt_invasion_poland', 'event', 'Invasão da Polônia', 3),
('b1000000-0000-0000-0000-000000000020', 'evt_dday', 'event', 'Dia D', 1),
('b1000000-0000-0000-0000-000000000020', 'evt_stalingrad', 'event', 'Batalha de Stalingrado', 2),
('b1000000-0000-0000-0000-000000000020', 'char_churchill', 'character', 'Winston Churchill', 3),
('b1000000-0000-0000-0000-000000000021', 'evt_holocaust', 'event', 'Holocausto', 1),
('b1000000-0000-0000-0000-000000000021', 'evt_hiroshima', 'event', 'Hiroshima e Nagasaki', 2),
('b1000000-0000-0000-0000-000000000021', 'evt_united_nations', 'event', 'Criação da ONU', 3);

-- ============================================================
-- 8. História do Brasil Colonial
-- ============================================================
INSERT INTO learning_paths (id, name, description, category, difficulty, estimated_minutes, total_modules, total_contents, xp_reward, badge_code, "order")
VALUES ('a1000000-0000-0000-0000-000000000008', 'Brasil Colonial', 'Dos povos originários à independência.', 'brazilHistory', 'beginner', 100, 3, 9, 200, 'brazil_colonial_master', 8);

INSERT INTO path_modules (id, path_id, title, description, "order", total_contents) VALUES
('b1000000-0000-0000-0000-000000000022', 'a1000000-0000-0000-0000-000000000008', 'Descobrimento', 'A chegada dos portugueses.', 1, 3),
('b1000000-0000-0000-0000-000000000023', 'a1000000-0000-0000-0000-000000000008', 'Período Colonial', 'Açúcar, ouro e escravidão.', 2, 3),
('b1000000-0000-0000-0000-000000000024', 'a1000000-0000-0000-0000-000000000008', 'Caminho para Independência', 'Inconfidência e chegada da corte.', 3, 3);

INSERT INTO path_contents (module_id, entity_id, entity_type, entity_name, "order") VALUES
('b1000000-0000-0000-0000-000000000022', 'char_cabral', 'character', 'Pedro Álvares Cabral', 1),
('b1000000-0000-0000-0000-000000000022', 'evt_discovery_brazil', 'event', 'Descobrimento do Brasil', 2),
('b1000000-0000-0000-0000-000000000022', 'civ_indigenous', 'civilization', 'Povos Originários', 3),
('b1000000-0000-0000-0000-000000000023', 'evt_sugar_cycle', 'event', 'Ciclo do Açúcar', 1),
('b1000000-0000-0000-0000-000000000023', 'evt_gold_rush', 'event', 'Ciclo do Ouro', 2),
('b1000000-0000-0000-0000-000000000023', 'evt_slavery_brazil', 'event', 'Escravidão no Brasil', 3),
('b1000000-0000-0000-0000-000000000024', 'char_tiradentes', 'character', 'Tiradentes', 1),
('b1000000-0000-0000-0000-000000000024', 'evt_inconfidencia', 'event', 'Inconfidência Mineira', 2),
('b1000000-0000-0000-0000-000000000024', 'evt_court_brazil', 'event', 'Chegada da Corte Portuguesa', 3);
