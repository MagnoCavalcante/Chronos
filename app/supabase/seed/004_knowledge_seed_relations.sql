-- CHRONOS Knowledge Base Seed - Relações (Grafo de Conhecimento)
-- Conecta personagens entre si e com civilizações/eventos/localizações

-- Relações de Cleópatra
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_cleopatra', 'char_cesar', 'character', 'Júlio César', 'aliado_politico', 'Aliança política e pessoal (48-44 a.C.)'),
('char_cleopatra', 'char_alexandre', 'character', 'Alexandre, o Grande', 'heranca_cultural', 'Herdeira da dinastia ptolemaica fundada por general de Alexandre'),
('char_cleopatra', 'civ_egito_ptolemaico', 'civilization', 'Egito Ptolemaico', 'governante', 'Última faraó ativa'),
('char_cleopatra', 'loc_alexandria', 'location', 'Alexandria', 'local_nascimento', 'Nasceu e morreu em Alexandria'),
('char_cleopatra', 'evt_batalha_accio', 'event', 'Batalha de Áccio', 'participante', 'Derrota decisiva em 31 a.C.');

-- Relações de Alexandre
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_alexandre', 'char_socrates', 'character', 'Sócrates', 'influencia_intelectual', 'Aristóteles (professor de Alexandre) foi aluno de Platão, que foi aluno de Sócrates'),
('char_alexandre', 'civ_macedonia', 'civilization', 'Macedônia', 'governante', 'Rei da Macedônia de 336 a.C.'),
('char_alexandre', 'civ_persia', 'civilization', 'Império Persa', 'conquistador', 'Conquistou o Império Aquemênida'),
('char_alexandre', 'loc_alexandria', 'location', 'Alexandria', 'fundador', 'Fundou a cidade em 331 a.C.'),
('char_alexandre', 'loc_babilonia', 'location', 'Babilônia', 'local_morte', 'Morreu na Babilônia em 323 a.C.');

-- Relações de Júlio César
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_cesar', 'char_cleopatra', 'character', 'Cleópatra VII', 'aliado_politico', 'Aliança política e pessoal no Egito'),
('char_cesar', 'char_napoleao', 'character', 'Napoleão Bonaparte', 'inspiracao', 'César foi modelo de liderança para Napoleão'),
('char_cesar', 'civ_roma', 'civilization', 'República Romana', 'governante', 'Ditador perpétuo'),
('char_cesar', 'loc_roma', 'location', 'Roma', 'capital', 'Centro de poder e local de morte'),
('char_cesar', 'evt_rubicao', 'event', 'Travessia do Rubicão', 'protagonista', 'Desafiou o Senado em 49 a.C.');

-- Relações de Sócrates
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_socrates', 'civ_atenas', 'civilization', 'Atenas Clássica', 'cidadao', 'Cidadão ateniense'),
('char_socrates', 'char_alexandre', 'character', 'Alexandre, o Grande', 'influencia_indireta', 'Mestre de Platão → Aristóteles → Alexandre'),
('char_socrates', 'loc_atenas', 'location', 'Atenas', 'local_vida', 'Viveu e morreu em Atenas');

-- Relações de Leonardo
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_davinci', 'civ_renascimento', 'civilization', 'Renascimento Italiano', 'representante', 'Arquétipo do homem universal renascentista'),
('char_davinci', 'loc_florenca', 'location', 'Florença', 'formacao', 'Formação artística no ateliê de Verrocchio'),
('char_davinci', 'loc_milao', 'location', 'Milão', 'trabalho', 'Última Ceia e trabalhos para Sforza');

-- Relações de Napoleão
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_napoleao', 'char_cesar', 'character', 'Júlio César', 'inspiracao', 'César como modelo de liderança'),
('char_napoleao', 'char_carlosmagno', 'character', 'Carlos Magno', 'inspiracao', 'Invocou legado de Carlos Magno na coroação'),
('char_napoleao', 'char_churchill', 'character', 'Winston Churchill', 'antagonismo_historico', 'Tradição britânica anti-napoleônica influenciou Churchill'),
('char_napoleao', 'civ_franca', 'civilization', 'França', 'governante', 'Imperador dos Franceses (1804-1815)'),
('char_napoleao', 'evt_waterloo', 'event', 'Batalha de Waterloo', 'protagonista', 'Derrota final em 1815');

-- Relações de Carlos Magno
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_carlosmagno', 'char_napoleao', 'character', 'Napoleão Bonaparte', 'inspirou', 'Napoleão via Carlos Magno como precedente imperial'),
('char_carlosmagno', 'civ_carolingio', 'civilization', 'Império Carolíngio', 'fundador', 'Fundador do Império Carolíngio'),
('char_carlosmagno', 'loc_aachen', 'location', 'Aachen', 'capital', 'Capital do império e local de morte');

-- Relações de Ramsés II
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_ramses', 'char_cleopatra', 'character', 'Cleópatra VII', 'mesma_civilizacao', 'Ambos faraós do Egito (1200 anos de distância)'),
('char_ramses', 'civ_egito', 'civilization', 'Egito Antigo', 'governante', 'Faraó da XIX Dinastia'),
('char_ramses', 'loc_abu_simbel', 'location', 'Abu Simbel', 'construtor', 'Construiu os templos de Abu Simbel');

-- Relações de Gêngis Khan
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_genghis', 'civ_mongol', 'civilization', 'Império Mongol', 'fundador', 'Fundador do Império Mongol'),
('char_genghis', 'char_alexandre', 'character', 'Alexandre, o Grande', 'comparacao', 'Frequentemente comparados como grandes conquistadores'),
('char_genghis', 'evt_rota_seda', 'event', 'Pax Mongolica', 'facilitador', 'Unificou e protegeu a Rota da Seda');

-- Relações de Churchill
INSERT INTO knowledge_relations (source_entity_id, target_id, target_type, target_name, relation_type, descricao) VALUES
('char_churchill', 'char_napoleao', 'character', 'Napoleão Bonaparte', 'estudioso', 'Estudou profundamente as campanhas napoleônicas'),
('char_churchill', 'civ_imperio_britanico', 'civilization', 'Império Britânico', 'defensor', 'Último grande defensor do Império Britânico'),
('char_churchill', 'evt_ww2', 'event', 'Segunda Guerra Mundial', 'lider', 'Líder britânico durante a guerra'),
('char_churchill', 'loc_londres', 'location', 'Londres', 'capital', 'Governou de Londres durante o Blitz');
