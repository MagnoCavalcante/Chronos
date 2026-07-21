-- Migration: Seed civilizations and historical locations of the CHRONOS ecosystem
-- Description: Cria as tabelas e insere os registros reais de homologação e validação.
-- Sprint: 5.2.0
-- Date: 19/07/2026
-- Author: Equipe de Engenharia CHRONOS

BEGIN;

-- 1. Criação da tabela 'civilizations' caso não exista para compatibilidade local
CREATE TABLE IF NOT EXISTS civilizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(255),
    description TEXT NOT NULL,
    summary TEXT,
    start_year INTEGER NOT NULL,
    end_year INTEGER,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'published',
    ativo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. Criação da tabela 'historical_locations' caso não exista para compatibilidade local
CREATE TABLE IF NOT EXISTS historical_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(255),
    description TEXT NOT NULL,
    summary TEXT,
    latitude DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    longitude DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    location_type VARCHAR(100) NOT NULL DEFAULT 'settlement',
    parent_location_id UUID,
    modern_country VARCHAR(255) NOT NULL DEFAULT '',
    modern_region VARCHAR(255) NOT NULL DEFAULT '',
    start_year INTEGER NOT NULL DEFAULT 0,
    end_year INTEGER,
    cover_image_url TEXT,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'published',
    ativo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 3. Inserção de 15 Civilizações reais
INSERT INTO civilizations (id, slug, name, short_name, description, summary, start_year, end_year, publication_status, ativo)
VALUES
('00000000-0000-0000-0000-000000000001', 'egito-antigo', 'Egito Antigo', 'Egito', 'Uma das civilizações mais antigas do mundo, conhecida pelas pirâmides, faraós e escrita hieroglífica.', 'Civilização do Nilo e arquitetura monumental.', -3100, -30, 'published', true),
('00000000-0000-0000-0000-000000000002', 'imperio-romano', 'Império Romano', 'Roma', 'Vasto império mediterrâneo que unificou leis, arquitetura e influenciou a cultura ocidental por milênios.', 'Maior superpotência militar e política da antiguidade clássica.', -27, 476, 'published', true),
('00000000-0000-0000-0000-000000000003', 'grecia-antiga', 'Grécia Antiga', 'Grécia', 'Berço da democracia ocidental, da filosofia de Sócrates e Platão, das Olimpíadas e das artes teatrais.', 'Inovadores em filosofia, política e ciência.', -800, -146, 'published', true),
('00000000-0000-0000-0000-000000000004', 'imperio-persa', 'Império Persa', 'Pérsia', 'Grande império asiático fundado por Ciro, o Grande, célebre pela Estrada Real e tolerância cultural.', 'O império aquemênida que desafiou as cidades-estado gregas.', -550, -330, 'published', true),
('00000000-0000-0000-0000-000000000005', 'civilizacao-maia', 'Civilização Maia', 'Maias', 'Civilização mesoamericana destacada por sua escrita glífica sofisticada, matemática e observações astronômicas.', 'Mestres do calendário e arquitetura na selva centro-americana.', -2000, 1697, 'published', true),
('00000000-0000-0000-0000-000000000006', 'imperio-mongol', 'Império Mongol', 'Mongóis', 'O maior império contíguo da história terrestre, unificado por Gengis Khan conectando Ásia e Europa.', 'Guerreiros nômades das estepes asiáticas.', 1206, 1368, 'published', true),
('00000000-0000-0000-0000-000000000007', 'civilizacao-inca', 'Civilização Inca', 'Incas', 'Império andino colossal que desenvolveu o sistema de registros Quipu e redes complexas de estradas de pedra.', 'Construtores de cidades nas nuvens andinas.', 1438, 1572, 'published', true),
('00000000-0000-0000-0000-000000000008', 'imperio-bizantino', 'Império Bizantino', 'Bizâncio', 'Continuação oriental do Império Romano com capital em Constantinopla, famoso pela preservação cultural clássica.', 'O império cristão ortodoxo que durou mil anos após a queda de Roma.', 330, 1453, 'published', true),
('00000000-0000-0000-0000-000000000009', 'imperio-muria', 'Império Máuria', 'Máuria', 'Império indiano que atingiu seu apogeu sob Ashoka, o Grande, promovendo o Budismo e pilares filosóficos.', 'Primeiro grande império unificado do subcontinente indiano.', -322, -185, 'published', true),
('00000000-0000-0000-0000-000000000010', 'civilizacao-viking', 'Civilização Viking', 'Vikings', 'Exploradores, guerreiros e comerciantes nórdicos célebres por seus navios (drakkar) e explorações transatlânticas.', 'Navegadores audazes e colonizadores escandinavos.', 793, 1066, 'published', true),
('00000000-0000-0000-0000-000000000011', 'dinastia-han', 'Dinastia Han', 'Han', 'Era de ouro da história chinesa caracterizada pela abertura da Rota da Seda e consolidação do Confucionismo.', 'A dinastia que moldou a identidade cultural da China.', -202, 220, 'published', true),
('00000000-0000-0000-0000-000000000012', 'civilizacao-fenicia', 'Civilização Fenícia', 'Fenícios', 'Comerciantes marítimos mediterrâneos criadores do primeiro alfabeto fonético simplificado e pigmentos de púrpura.', 'Senhores do comércio marítimo e colonização costeira antiga.', -1500, -300, 'published', true),
('00000000-0000-0000-0000-000000000013', 'civilizacao-asteca', 'Civilização Asteca', 'Astecas', 'Poderosa confederação mesoamericana que ergueu a esplêndida capital Tenochtitlán sobre lagos do vale mexicano.', 'Império guerreiro e matemático do México Central.', 1325, 1521, 'published', true),
('00000000-0000-0000-0000-000000000014', 'reino-de-axum', 'Reino de Axum', 'Axum', 'Poderoso império comercial africano localizado na moderna Etiópia, ligando rotas entre Roma, Pérsia e Índia.', 'Primeira grande nação africana a adotar o cristianismo.', 100, 940, 'published', true),
('00000000-0000-0000-0000-000000000015', 'imperio-otomano', 'Império Otomano', 'Otomanos', 'Estado transcontinental que substituiu o Império Bizantino e controlou rotas comerciais por mais de seis séculos.', 'Ponte islâmica duradoura entre o Oriente e o Ocidente.', 1299, 1922, 'published', true)
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    description = EXCLUDED.description,
    summary = EXCLUDED.summary,
    start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = now();

-- 4. Inserção de 20 Localizações Históricas
INSERT INTO historical_locations (id, slug, name, short_name, description, summary, latitude, longitude, location_type, parent_location_id, modern_country, modern_region, start_year, end_year, cover_image_url, publication_status, ativo)
VALUES
('10000000-0000-0000-0000-000000000001', 'roma-antiga', 'Roma', 'Roma', 'Centro administrativo e monumental do Império Romano, famosa pelo Coliseu, Fórum e termas.', 'Capital monumental do império.', 41.8902, 12.4922, 'city', NULL, 'Itália', 'Lazio', -753, NULL, 'https://images.unsplash.com/photo-1552832230-c0197dd311b5', 'published', true),
('10000000-0000-0000-0000-000000000002', 'atenas-classica', 'Atenas', 'Atenas', 'Coração intelectual e político da Grécia Antiga, contendo a imponente Acrópole e o Partenon.', 'Célula de origem da democracia clássica.', 37.9715, 23.7257, 'city', NULL, 'Grécia', 'Ática', -3000, NULL, 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963', 'published', true),
('10000000-0000-0000-0000-000000000003', 'alexandria', 'Alexandria', 'Alexandria', 'Metrópole costeira egípcia famosa pelo Farol, pela Grande Biblioteca e fusão cultural helenística.', 'Capital cultural do período ptolemaico.', 31.2001, 29.9187, 'city', NULL, 'Egito', 'Alexandria', -331, NULL, 'https://images.unsplash.com/photo-1582967788606-a171c1080cb0', 'published', true),
('10000000-0000-0000-0000-000000000004', 'machu-picchu', 'Machu Picchu', 'Machu Picchu', 'Santuário montanhoso inca no topo dos Andes, revelando engenharia hidráulica avançada.', 'Cadeia de templos andinos escondidos na serra.', -13.1631, -72.5450, 'archaeological_site', NULL, 'Peru', 'Cusco', 1450, 1572, 'https://images.unsplash.com/photo-1587595431973-160d0d94adb1', 'published', true),
('10000000-0000-0000-0000-000000000005', 'constantinopla', 'Constantinopla', 'Constantinopla', 'Capital fortificada do Império Bizantino e do posterior Império Otomano, guardando o estreito de Bósforo.', 'Ponto de conexão comercial e religioso eurasiático.', 41.0082, 28.9784, 'city', NULL, 'Turquia', 'Istambul', 330, 1922, 'https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b', 'published', true),
('10000000-0000-0000-0000-000000000006', 'babilonia', 'Babilônia', 'Babilônia', 'Famosa capital mesopotâmica conhecida por suas muralhas colossais, portões esmaltados e Jardins Suspensos.', 'Berço do primeiro código jurídico de Hamurabi.', 32.5361, 44.4211, 'city', NULL, 'Iraque', 'Babil', -2300, -141, 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f', 'published', true),
('10000000-0000-0000-0000-000000000007', 'pompeia', 'Pompéia', 'Pompéia', 'Cidade romana incrivelmente preservada sob as cinzas vulcânicas da grande erupção do Vesúvio.', 'Retrato fossilizado da vida romana cotidiana.', 40.7512, 14.4869, 'archaeological_site', NULL, 'Itália', 'Campânia', -600, 79, 'https://images.unsplash.com/photo-1563212626-d62f6b86e7a2', 'published', true),
('10000000-0000-0000-0000-000000000008', 'cartago', 'Carthago', 'Cartago', 'Poderosa cidade mercante fenícia no norte africano, destruída e refundada durante as Guerras Púnicas.', 'Rivais mortais da República de Roma.', 36.8531, 10.3230, 'city', NULL, 'Tunísia', 'Tunis', -814, 698, 'https://images.unsplash.com/photo-1508672019048-805c876b67e2', 'published', true),
('10000000-0000-0000-0000-000000000009', 'giza', 'Platô de Gizé', 'Gizé', 'Complexo funerário egípcio abrigando as três Grandes Pirâmides de Quéops, Quéfren e Miquerinos e a Esfinge.', 'Cemitério de realeza da era clássica faraônica.', 29.9792, 31.1342, 'archaeological_site', NULL, 'Egito', 'Giza', -2580, NULL, 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750', 'published', true),
('10000000-0000-0000-0000-000000000010', 'petra', 'Petra', 'Petra', 'Capital nabateia esculpida diretamente nos penhascos rochosos, célebre pelo templo "Al-Khazneh".', 'O tesouro esculpido no canyon de areia.', 30.3285, 35.4444, 'archaeological_site', NULL, 'Jordânia', 'Ma''an', -312, 663, 'https://images.unsplash.com/photo-1501233349932-fee1450a5afd', 'published', true),
('10000000-0000-0000-0000-000000000011', 'persepolis', 'Persépolis', 'Persépolis', 'Capital cerimonial do Império Aquemênida Persa de rara sofisticação artística, saqueada por Alexandre.', 'Palácios majestosos do rei dos reis persa.', 29.9344, 52.8897, 'archaeological_site', NULL, 'Irã', 'Fars', -515, -330, 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e', 'published', true),
('10000000-0000-0000-0000-000000000012', 'chichen-itza', 'Chichén Itzá', 'Chichén Itzá', 'Importante centro urbano maia abrigando a imponente pirâmide de degraus chamada "El Castillo".', 'Capital astronômica do império maia.', 20.6843, -88.5678, 'archaeological_site', NULL, 'México', 'Iucatã', 600, 1200, 'https://images.unsplash.com/photo-1518638150341-db7a4d5a9b70', 'published', true),
('10000000-0000-0000-0000-000000000013', 'bagda', 'Bagdá', 'Bagdá', 'Capital espiritual e científica da era de ouro islâmica, famosa pela extinta "Casa da Sabedoria".', 'Coração do califado abássida medieval.', 33.3152, 44.3661, 'city', NULL, 'Iraque', 'Baghdad', 762, NULL, 'https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b', 'published', true),
('10000000-0000-0000-0000-000000000014', 'kyoto', 'Quioto', 'Quioto', 'Antiga capital imperial japonesa renomada por seus templos budistas clássicos, jardins zen e santuários.', 'Centro político e religioso feudal do arquipélago.', 35.0116, 135.7681, 'city', NULL, 'Japão', 'Kansai', 794, NULL, 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e', 'published', true),
('10000000-0000-0000-0000-000000000015', 'tula', 'Tula', 'Tula', 'Capital dos toltecas célebre pelas gigantescas estátuas de basaltos representando guerreiros armados.', 'Sítio arqueológico sagrado do centro mexicano.', 20.0519, -99.3456, 'archaeological_site', NULL, 'México', 'Hidalgo', 900, 1150, 'https://images.unsplash.com/photo-1518638150341-db7a4d5a9b70', 'published', true),
('10000000-0000-0000-0000-000000000016', 'tebas', 'Tebas', 'Tebas', 'Antiga capital do Egito Faraônico, famosa pelo Templo de Karnak, Luxor e o Vale dos Reis.', 'O santuário religioso supremo dos deuses egípcios.', 25.6872, 32.6396, 'city', NULL, 'Egito', 'Luxor', -3200, -30, 'https://images.unsplash.com/photo-1543722530-d2c32013a1e6', 'published', true),
('10000000-0000-0000-0000-000000000017', 'londres', 'Londinium', 'Londres', 'Fundada como posto comercial militar romano nas margens do Rio Tâmisa no primeiro século.', 'De fortificação militar a metrópole mercantil.', 51.5074, -0.1278, 'city', NULL, 'Reino Unido', 'Inglaterra', 43, NULL, 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad', 'published', true),
('10000000-0000-0000-0000-000000000018', 'palenque', 'Palenque', 'Palenque', 'Santuário maia incrivelmente decorado no sul mexicano, célebre pela tumba de Pacal, o Grande.', 'Sítio arqueológico clássico na selva mexicana.', 17.4847, -91.9958, 'archaeological_site', NULL, 'México', 'Chiapas', 226, 799, 'https://images.unsplash.com/photo-1518638150341-db7a4d5a9b70', 'published', true),
('10000000-0000-0000-0000-000000000019', 'kyiv', 'Kiev', 'Kiev', 'Coração medieval da Rus de Kiev, crucial rota de comércio fluvial e berço eslavo cristão.', 'Capital histórica do império eslavo oriental.', 50.4501, 30.5234, 'city', NULL, 'Ucrânia', 'Kyiv Oblast', 482, NULL, 'https://images.unsplash.com/photo-1563212626-d62f6b86e7a2', 'published', true),
('10000000-0000-0000-0000-000000000020', 'machu-picchu-templo', 'Templo do Sol', 'Templo do Sol', 'Templo semicircular dedicado ao deus Inti dentro do santuário andino de Machu Picchu.', 'Área sagrada de adoração solar.', -13.1631, -72.5450, 'religious_site', '10000000-0000-0000-0000-000000000004', 'Peru', 'Cusco', 1450, 1572, 'https://images.unsplash.com/photo-1587595431973-160d0d94adb1', 'published', true)
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    description = EXCLUDED.description,
    summary = EXCLUDED.summary,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    location_type = EXCLUDED.location_type,
    parent_location_id = EXCLUDED.parent_location_id,
    modern_country = EXCLUDED.modern_country,
    modern_region = EXCLUDED.modern_region,
    start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year,
    cover_image_url = EXCLUDED.cover_image_url,
    publication_status = EXCLUDED.publication_status,
    ativo = EXCLUDED.ativo,
    updated_at = now();

COMMIT;
