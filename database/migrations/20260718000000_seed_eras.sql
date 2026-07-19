-- Migration: Seed initial eras of the CHRONOS ecosystem
-- Description: Insere os registros oficiais das oito Eras históricas fundamentais.
-- Sprint: 4.1.10
-- Date: 18/07/2026
-- Author: Equipe de Engenharia CHRONOS
--
-- Idempotência: Utiliza ON CONFLICT (slug) DO UPDATE para garantir que o script
-- possa ser executado de forma segura e repetida, atualizando as colunas caso o registro já exista.

BEGIN;

-- 1. Pré-História
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'pre-historia',
    'Pré-História',
    'Origens e Escrita',
    E'A Pré-História abrange o vasto período desde o surgimento dos primeiros ancestrais humanos (hominídeos) até o desenvolvimento dos primeiros sistemas de escrita na Mesopotâmia e no Egito. É caracterizada pela evolução das ferramentas de pedra, pelo domínio do fogo, pelo desenvolvimento da linguagem oral, pela transição do nomadismo caçador-coletor para o sedentarismo agrícola (Revolução Neolítica) e pela domesticação de animais.',
    'O período mais longo da história humana, estendendo-se do surgimento dos primeiros hominídeos até a invenção da escrita por volta de 4000 a.C.',
    -2500000,
    -4000,
    1,
    '#708090',
    'hourglass',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- 2. Antiguidade
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'antiguidade',
    'Antiguidade',
    'Grandes Impérios',
    E'A Antiguidade marca o surgimento das primeiras grandes civilizações humanas dotadas de escrita, sistemas de leis estruturados, religiões complexas e arquitetura monumental. Período caracterizado pelas sociedades da Mesopotâmia (Sumérios, Acádios, Babilônios), do Egito Antigo, da Pérsia e do Vale do Indo. Destaca-se pelo início da metalurgia do bronze e do ferro e pela centralização política.',
    'A era do surgimento da escrita e das primeiras grandes civilizações do Crescente Fértil, Egito, Mesopotâmia e Pérsia antiga.',
    -4000,
    -800,
    2,
    '#D2B48C',
    'temple',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- 3. Antiguidade Clássica
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'antiguidade-classica',
    'Antiguidade Clássica',
    'Berço do Ocidente',
    E'A Antiguidade Clássica destaca o auge cultural, artístico, filosófico e político da Grécia Antiga e da Roma Antiga no Mediterrâneo. É a era da democracia ateniense, da filosofia socrática, do Império de Alexandre, o Grande, e da consolidação da República e posterior Império Romano. Suas bases moldaram de maneira definitiva o pensamento científico, as leis, a arquitetura e a arte do Ocidente.',
    'O florescimento cultural, filosófico e político das civilizações grega e romana, pilares do pensamento ocidental moderno.',
    -800,
    476,
    3,
    '#FFD700',
    'temple',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- 4. Idade Média
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'idade-media',
    'Idade Média',
    'Feudalismo e Reinos',
    E'A Idade Média, que se estende da queda de Roma até a queda de Constantinopla, é caracterizada pela descentralização política na Europa Ocidental através do sistema feudal, pela emergência de grandes impérios (como o Bizantino e o Carolíngio), pela expansão do Islã e pela hegemonia cultural e social da Igreja Católica. É marcada por intensa produção teológica, surgimento das universidades e pelas Cruzadas.',
    'Período feudal marcado pela fragmentação política, consolidação de reinos europeus, ascensão do Islã e hegemonia da Igreja Católica.',
    476,
    1453,
    4,
    '#8B0000',
    'castle',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- 5. Renascimento
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'renascimento',
    'Renascimento',
    'Artes e Ciência',
    E'O Renascimento representa um vigoroso movimento de renovação cultural, artística e científica na Europa, inspirado nos valores humanistas e na recuperação do saber filosófico da Antiguidade Clássica. Iniciado na Itália, caracterizou-se pela valorização do homem (antropocentrismo), pelo racionalismo, pelo empirismo científico e por avanços artísticos tridimensionais (perspectiva).',
    'Movimento revolucionário de renovação nas artes, ciências e filosofia fundado no humanismo e no racionalismo.',
    1350,
    1600,
    5,
    '#4682B4',
    'history',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- 6. Idade Moderna
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'idade-moderna',
    'Idade Moderna',
    'Navegações e Imprensa',
    E'A Idade Moderna destaca-se pelo início da globalização através das Grandes Navegações, que conectaram os continentes de maneira permanente. É marcada pelo estabelecimento do Absolutismo monárquico na Europa, pela Reforma Protestante que quebrou o monopólio católico, pelo mercantilismo econômico, pela colonização das Américas e pelo surgimento do Iluminismo no século XVIII.',
    'Era de expansão marítima global, mercantilismo, absolutismo de reis, reformas religiosas e o surgimento do Iluminismo.',
    1453,
    1789,
    6,
    '#FF8C00',
    'public',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- 7. Revolução Industrial
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'revolucao-industrial',
    'Revolução Industrial',
    'Vapor e Carvão',
    E'A Revolução Industrial compreende a transição radical dos métodos de produção artesanal para os processos mecanizados baseados em fábricas de larga escala, impulsionados pela máquina a vapor, estradas de ferro e exploração do carvão. Iniciada na Grã-Bretanha, essa era gerou um êxodo rural maciço, o crescimento vertiginoso das cidades e assentou as bases do capitalismo industrial moderno.',
    'A transição fundamental da manufatura e do artesanato para a mecanização industrial de fábricas de larga escala.',
    1760,
    1914,
    7,
    '#4F4F4F',
    'history',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- 8. Idade Contemporânea
INSERT INTO eras (
    slug,
    nome,
    titulo_curto,
    descricao,
    descricao_resumida,
    inicio_ano,
    fim_ano,
    ordem_cronologica,
    cor_hex,
    icon_key,
    publication_status,
    ativo,
    created_at,
    updated_at
) VALUES (
    'idade-contemporanea',
    'Idade Contemporânea',
    'Mundo Globalizado',
    E'A Idade Contemporânea abrange as grandes transformações sociais, científicas, políticas e ideológicas do mundo contemporâneo. Iniciada com a Revolução Francesa, inclui as duas Guerras Mundiais, a Guerra Fria, a descolonização, a revolução espacial, o surgimento da informática, a proliferação da internet e os desafios ambientais e tecnológicos da nossa própria época.',
    'Do final do século XVIII até o presente. Período caracterizado por conflitos globais, revolução tecnológica digital e globalização.',
    1789,
    2026,
    8,
    '#008080',
    'public',
    'published',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (slug) DO UPDATE SET
    nome = EXCLUDED.nome,
    titulo_curto = EXCLUDED.titulo_curto,
    descricao = EXCLUDED.descricao,
    descricao_resumida = EXCLUDED.descricao_resumida,
    inicio_ano = EXCLUDED.inicio_ano,
    fim_ano = EXCLUDED.fim_ano,
    ordem_cronologica = EXCLUDED.ordem_cronologica,
    cor_hex = EXCLUDED.cor_hex,
    icon_key = EXCLUDED.icon_key,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

COMMIT;
