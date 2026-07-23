-- CHRONOS Knowledge Base Seed - Curiosidades e Debates

-- Curiosidades de Cleópatra
INSERT INTO knowledge_curiosities (entity_id, titulo, conteudo, tipo, confiabilidade) VALUES
('char_cleopatra', 'Cleópatra não era egípcia', 'Cleópatra era de origem macedônia/grega. A dinastia ptolemaica descendia de Ptolemeu I, general de Alexandre. Porém, ela foi a primeira da dinastia a aprender egípcio.', 'curiosidade', 'fact'),
('char_cleopatra', 'A beleza lendária', 'Moedas da época mostram Cleópatra com nariz proeminente e queixo forte. Historiadores antigos enfatizavam sua inteligência e voz, não beleza física. A imagem de beleza extraordinária é uma criação posterior.', 'equivoco', 'fact'),
('char_cleopatra', 'Suicídio por serpente', 'A história de que Cleópatra morreu pela picada de uma áspide (cobra) vem de fontes romanas. Alguns historiadores modernos questionam esta versão, sugerindo veneno ingerido.', 'mito', 'hypothesis');

-- Curiosidades de Alexandre
INSERT INTO knowledge_curiosities (entity_id, titulo, conteudo, tipo, confiabilidade) VALUES
('char_alexandre', 'Heterocromia', 'Fontes antigas descrevem Alexandre com olhos de cores diferentes (um azul, um castanho). Esta condição é chamada heterocromia.', 'curiosidade', 'theory'),
('char_alexandre', 'O nó górdio', 'Segundo a lenda, Alexandre cortou o nó górdio com sua espada. Historiadores debatem se isso realmente ocorreu ou é um acréscimo literário posterior.', 'mito', 'theory'),
('char_alexandre', 'Bucéfalo', 'Seu cavalo Bucéfalo o acompanhou por toda a carreira militar. Quando morreu na Índia, Alexandre fundou uma cidade em sua homenagem (Bucéfala).', 'curiosidade', 'fact');

-- Curiosidades de César
INSERT INTO knowledge_curiosities (entity_id, titulo, conteudo, tipo, confiabilidade) VALUES
('char_cesar', 'Veni, Vidi, Vici', 'A famosa frase foi usada para descrever sua rápida vitória sobre Farnaces II do Ponto em 47 a.C., não como frase genérica.', 'curiosidade', 'fact'),
('char_cesar', 'Cesariana', 'O procedimento cirúrgico NÃO recebe esse nome por causa do nascimento de César. Mães que passavam por cesariana na época não sobreviviam, e a mãe de César viveu décadas após seu nascimento.', 'equivoco', 'fact'),
('char_cesar', 'Et tu, Brute?', 'Segundo Suetônio, as últimas palavras de César foram em grego: "Kai su, teknon?" (Tu também, filho?), não a frase em latim popularizada por Shakespeare.', 'mito', 'theory');

-- Curiosidades de Sócrates
INSERT INTO knowledge_curiosities (entity_id, titulo, conteudo, tipo, confiabilidade) VALUES
('char_socrates', 'Nunca escreveu nada', 'Sócrates nunca escreveu uma única linha. Tudo que sabemos vem de seus alunos, principalmente Platão e Xenofonte, que podem ter projetado suas próprias ideias no mestre.', 'curiosidade', 'fact'),
('char_socrates', 'Soldado corajoso', 'Antes de filósofo, Sócrates foi soldado. Lutou em Potideia, Anfípolis e Délio, onde foi elogiado por sua coragem e resistência física.', 'curiosidade', 'fact');

-- Curiosidades de Leonardo
INSERT INTO knowledge_curiosities (entity_id, titulo, conteudo, tipo, confiabilidade) VALUES
('char_davinci', 'Escrita espelhada', 'Leonardo escrevia da direita para a esquerda (escrita espelhada). Debate: proteção contra cópia, conforto para canhoto, ou hábito pessoal.', 'curiosidade', 'fact'),
('char_davinci', 'Vegetariano', 'Registros sugerem que Leonardo era vegetariano, algo raríssimo na época. Vasari menciona que ele comprava pássaros engaiolados apenas para libertá-los.', 'curiosidade', 'theory'),
('char_davinci', 'Mona Lisa', 'A Mona Lisa mede apenas 77x53cm. Leonardo trabalhou nela por mais de 16 anos e nunca a entregou ao comissionador, levando-a consigo até a morte.', 'curiosidade', 'fact');

-- Curiosidades de Napoleão
INSERT INTO knowledge_curiosities (entity_id, titulo, conteudo, tipo, confiabilidade) VALUES
('char_napoleao', 'Napoleão não era baixo', 'Com 1,70m, Napoleão tinha estatura média para a época. O mito da baixa estatura veio da confusão entre medidas francesas e inglesas, e da propaganda britânica.', 'equivoco', 'fact'),
('char_napoleao', 'Pedra de Rosetta', 'A expedição científica de Napoleão ao Egito (1798) resultou na descoberta da Pedra de Rosetta, que permitiu decifrar os hieróglifos egípcios.', 'curiosidade', 'fact');

-- Curiosidades de Gêngis Khan
INSERT INTO knowledge_curiosities (entity_id, titulo, conteudo, tipo, confiabilidade) VALUES
('char_genghis', 'Descendência genética', 'Estudos genéticos estimam que cerca de 0,5% da população masculina mundial (16 milhões) pode descender diretamente de Gêngis Khan.', 'curiosidade', 'fact'),
('char_genghis', 'Tumba perdida', 'O local exato do túmulo de Gêngis Khan permanece desconhecido. Segundo a lenda, todos que participaram do funeral foram executados para manter o segredo.', 'curiosidade', 'theory');

-- Debates Históricos

-- Debate sobre Cleópatra
INSERT INTO knowledge_debates (entity_id, titulo, descricao, posicoes, status_atual) VALUES
('char_cleopatra', 'Causa da morte de Cleópatra', 'Como Cleópatra realmente morreu?', '["Picada de áspide (cobra egípcia) - versão tradicional de Plutarco","Veneno ingerido - teoria moderna baseada na implausibilidade da cobra","Assassinato por ordem de Otaviano - teoria minoritária"]', 'disputed');

-- Debate sobre Alexandre
INSERT INTO knowledge_debates (entity_id, titulo, descricao, posicoes, status_atual) VALUES
('char_alexandre', 'Causa da morte de Alexandre', 'O que causou a morte de Alexandre aos 32 anos?', '["Febre tifoide agravada por alcoolismo - teoria mais aceita","Envenenamento político por generais rivais","Malária ou febre do Nilo Ocidental","Pancreatite aguda"]', 'disputed');

-- Debate sobre César
INSERT INTO knowledge_debates (entity_id, titulo, descricao, posicoes, status_atual) VALUES
('char_cesar', 'Intenções monárquicas', 'César pretendia estabelecer uma monarquia permanente?', '["Sim, buscava poder absoluto ao estilo helenístico","Não, suas reformas visavam salvar a República de sua própria disfunção","Evolução gradual: inicialmente republicano, tornou-se autocrático"]', 'disputed');

-- Debate sobre Ramsés II
INSERT INTO knowledge_debates (entity_id, titulo, descricao, posicoes, status_atual) VALUES
('char_ramses', 'Ramsés e o Êxodo bíblico', 'Ramsés II é o faraó do Êxodo?', '["Cronologia compatível (XIII século a.C.) - posição tradicional","Não há evidência arqueológica do Êxodo como descrito na Bíblia","Se houve evento histórico por trás, foi menor que o relato bíblico"]', 'disputed');

-- Debate sobre Churchill
INSERT INTO knowledge_debates (entity_id, titulo, descricao, posicoes, status_atual) VALUES
('char_churchill', 'Churchill e o colonialismo', 'Como avaliar o legado colonial de Churchill?', '["Herói da liberdade que salvou a democracia do fascismo","Imperialista que manteve sistema colonial opressivo e contribuiu para a fome de Bengala (1943)","Ambos: produto de sua época, com vícios coloniais mas virtudes democráticas"]', 'disputed');
