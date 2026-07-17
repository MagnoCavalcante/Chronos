/**
 * Copyright 2026 Google LLC
 *
 * SPDX-License-Identifier: Apache-2.0
 */

export interface MythologyDetail {
  title: string;
  details: string;
  bullets: string[];
  scientificNote: string;
}

export const folcloreBrasileiroData: Record<string, MythologyDetail> = {
  'Introdução': {
    title: 'Introdução ao Folclore Brasileiro',
    details: 'O Folclore Brasileiro é o amálgama cultural das tradições orais, mitos, crenças e festividades originadas do sincretismo entre as culturas indígenas nativas, os colonizadores europeus (essencialmente portugueses) e as populações africanas trazidas na diáspora. Trata-se de uma expressão viva da identidade nacional, onde a vastidão e os mistérios da natureza tropical atuam como pano de fundo para narrativas morais, ecológicas e explicativas do cotidiano.',
    bullets: [
      'Sincretismo Multicultural: Fusão harmônica e tensa de elementos ameríndios, luso-ibéricos e afro-brasileiros.',
      'Oralidade e Tradição: Transmissão intergeracional baseada no relato de causos em comunidades ribeirinhas, sertanejas e litorâneas.',
      'Conexão Ecológica: Presença de figuras míticas que agem diretamente na mediação entre a exploração humana e o equilíbrio natural.'
    ],
    scientificNote: 'A consolidação acadêmica do folclore como ciência no Brasil teve seu ápice com a fundação da Comissão Nacional de Folclore em 1947, liderada por intelectuais como Luís da Câmara Cascudo, que propôs uma metodologia rigorosa de catalogação comparativa das lendas nacionais.'
  },
  'Cosmologia': {
    title: 'Cosmologia e Espiritualidade Terrena',
    details: 'Diferente de religiões estruturadas com deuses celestes distantes e panteões burocráticos, a cosmologia folclórica brasileira é animista, imanente e telúrica. O plano visível coexiste e interage constantemente com portais invisíveis protegidos por entidades encantadas. A Mata (Floresta) e as Águas não são meros recursos naturais, mas espaços sagrados providos de consciência, onde leis místicas regulam o respeito mútuo entre caçadores, pescadores e o meio ambiente.',
    bullets: [
      'Encantados e Passagens: Crença em seres que não morreram, mas "se encantaram", passando a habitar o interior de pedras, rios e árvores.',
      'O Limiar do Crepúsculo: A maior parte das aparições e manifestações sobrenaturais ocorre em horários de transição cósmica, como o meio-dia, o pôr do sol e a meia-noite.',
      'Justiça Animista: A natureza se vinga de abusos ambientais através de ilusões sensoriais, sons inexplicáveis e labirintos mentais provocados pelas entidades.'
    ],
    scientificNote: 'O conceito de "encantaria" é central nas religiões de matriz indígena e afro-brasileira no Norte e Nordeste, representando uma ontologia onde o sagrado reside no ambiente material imediato, e não em um céu transcendental.'
  },
  'Origem do mundo': {
    title: 'Gênese e Mitos de Criação',
    details: 'As narrativas de criação originais provêm das cosmogonias das diversas etnias indígenas (como Tupi-Guarani, Carajá e Ianomâmi), que posteriormente receberam camadas de interpretação cristã por padres jesuítas e lendas de matriz iorubá e banta. A criação do mundo é atribuída a Tupã, a divindade suprema associada ao trovão e à luz celestial, que moldou a terra e gerou os astros regentes.',
    bullets: [
      'Tupã e a Criação: O sopro vital de Tupã moldou as montanhas e florestas do topo do outeiro sagrado.',
      'Casamento do Sol e da Lua: O ciclo diário é governado por Guaraci (o Sol) e Jaci (a Lua), cujo amor cósmico dita o ritmo das colheitas e marés.',
      'Surgimento dos Rios: Lendas amazônicas narram que rios gigantescos nasceram de lágrimas de dor de divindades apaixonadas ou de serpentes gigantescas escavando o solo.'
    ],
    scientificNote: 'A catequização jesuítica traduziu o deus tupi Monan ou Tupã como o "Deus Cristão", o que transformou as ricas narrativas animistas originais em uma estrutura de combate maniqueísta entre o bem (Tupã) e o mal (Anhangá).'
  },
  'Principais deuses': {
    title: 'Divindades e Forças da Natureza',
    details: 'Embora o folclore moderno tenha secularizado muitas dessas figuras na forma de "lendas", as matrizes mitológicas originais adoravam uma série de entidades regentes das forças naturais, paixões humanas e fenômenos meteorológicos, que continuam reverenciadas sob a forma de seres fantásticos e protetores.',
    bullets: [
      'Tupã: O grande criador do universo material, manifestado na luz, no calor e no som do trovão.',
      'Jaci: A mãe-lua, governante da noite, protetora dos amantes, das plantas e do misticismo noturno.',
      'Guaraci: O pai-sol, doador da energia vital, protetor de todas as criaturas diurnas e guardião do dia.',
      'Rudá: O mensageiro do amor e da paixão, encarregado de unir os corações e pintar o céu com as cores do arco-íris.'
    ],
    scientificNote: 'Muitos desses deuses foram documentados primeiramente no século XVI por cronistas europeus como André Thevet e Jean de Léry, que ficaram impressionados com a complexidade da teologia tupi e a ausência de templos físicos.'
  },
  'Heróis': {
    title: 'Heróis Populares e Figuras de Resistência',
    details: 'Os heróis da tradição folclórica brasileira raramente são guerreiros blindados ou conquistadores imperiais. Eles são, tipicamente, figuras oprimidas que utilizam a astúcia para superar a tirania, ou almas puras agraciadas pelo divino para corrigir injustiças sociais ou históricas do período colonial e imperial.',
    bullets: [
      'O Negrinho do Pastoreio: Pequeno escravizado injustamente martirizado que, sob a proteção da Virgem Maria, ressurge montado em um cavalo baio para ajudar a encontrar causas e objetos perdidos.',
      'Zumbi dos Palmares: Líder histórico que se tornou lenda folclórica de invencibilidade e liberdade contra o jugo da escravidão colonial.',
      'Macunaíma: O "herói sem nenhum caráter", síntese mítica da identidade brasileira que transita entre a floresta e a cidade, encarnando a metamorfose constante e a malandragem adaptativa.'
    ],
    scientificNote: 'A lenda do Negrinho do Pastoreio é um poderoso documento do sincretismo católico-abolicionista do Sul do Brasil, coletada de forma escrita por João Simões Lopes Neto no início do século XX.'
  },
  'Criaturas': {
    title: 'Bestiário e Criaturas Fantásticas',
    details: 'O bestiário brasileiro é um dos mais ricos do mundo, habitado por seres que encarnam a defesa ativa da floresta contra invasores, ou que personificam as travessuras e mistérios da vida rural e urbana.',
    bullets: [
      'Curupira: Menino de cabelos flamejantes e pés voltados para trás, cujas pegadas enganam os caçadores. É o protetor supremo da fauna e flora.',
      'Saci-Pererê: Jovem de uma perna só, portador de um gorro vermelho mágico e um cachimbo. Domina os redemoinhos de vento e adora pregar peças domésticas.',
      'Mula sem Cabeça: Mulher amaldiçoada que se transforma em um equino que galopa soltando labaredas pelo pescoço, simbolizando a moralidade e os tabus coloniais.',
      'Boitatá: Serpente de fogo de olhos gigantescos e brilhantes que queima aqueles que incendeiam as matas sem necessidade.'
    ],
    scientificNote: 'A figura do Curupira é a mais antiga criatura documentada no Brasil: o jesuíta José de Anchieta escreveu sobre ele em 1560, relatando o terror que causava tanto nos indígenas quanto nos colonos portugueses.'
  },
  'Objetos lendários': {
    title: 'Artefatos de Poder e Símbolos Místicos',
    details: 'Os objetos míticos do folclore concentram poderes mágicos e regras de feitiçaria rígidas. Quem obtém o controle desses artefatos passa a controlar ou aprisionar as entidades fantásticas, ligando o mundo humano ao plano sobrenatural.',
    bullets: [
      'Carapuça Vermelha do Saci: O gorro que concede invisibilidade, velocidade extraordinária e poderes de teletransporte ao Saci. Se retirado, o Saci perde seus poderes e deve obedecer a quem o tomou.',
      'Garrafa de Vidro com Cruz: O único recipiente capaz de aprisionar um Saci. Deve-se capturá-lo jogando uma peneira de taquara sobre um redemoinho, retirar sua carapuça e colocá-lo na garrafa arrolhada com uma cruz.',
      'Flauta de Taquara do Curupira: Instrumento mágico cujo som confunde os sentidos, hipnotiza os cães e faz os caçadores se perderem eternamente na mata fechada.'
    ],
    scientificNote: 'A carapuça vermelha do Saci tem forte influência do barrete frígio europeu (símbolo de liberdade e emancipação), inserido na lenda quando esta migrou do sul indígena para o imaginário do sudeste colonial.'
  },
  'Locais sagrados': {
    title: 'Geografia Mística e Santuários da Natureza',
    details: 'A geografia folclórica abrange biomas misteriosos e pontos geográficos reais carregados de histórias e lendas que explicam fenômenos naturais ou ocultam portais para reinos fantásticos de encantados.',
    bullets: [
      'O Reino das Águas Doces: O leito do Rio Amazonas e seus afluentes profundos, lar da Iara e das cidades subaquáticas onde o Boto-cor-de-rosa conduz os humanos seduzidos.',
      'A Mata Fechada: Território sagrado governado pela Caipora e pelo Curupira, onde o silêncio absoluto é quebrado apenas pelo sopro de advertência das entidades.',
      'As Minas e Serras da Mãe-do-Ouro: Enclaves montanhosos iluminados por globos de fogo que flutuam indicando veios de ouro puro escondidos e protegidos.'
    ],
    scientificNote: 'A sacralização de pontos fluviais e florestais reflete o conhecimento geográfico e ecológico ancestral das tribos ribeirinhas, servindo como zonas de preservação onde a exploração predatória era proibida pelo medo do sobrenatural.'
  },
  'Linha do tempo da tradição': {
    title: 'Ciclos Históricos do Imaginário Nacional',
    details: 'A evolução do folclore nacional reflete a própria história social do Brasil. Longe de ser estática, a tradição passou por ciclos de transformação profunda, desde o isolamento ecológico indígena até a apropriação tecnológica digital moderna.',
    bullets: [
      'Era Pré-Cabralina (Até 1500): Mitos puramente animistas e rituais de comunhão com a terra de raiz tupi, caribe e jê.',
      'Fusão Colonial (Séculos XVI - XVIII): Sincretismo de lendas ibéricas (lobisomens, bruxas, o bicho-papão) e a chegada dos contos de orixás e encantados da África.',
      'Sertanização e Regionalismo (Século XIX): Consolidação de figuras híbridas em ambientes específicos (sertão, pampa, floresta tropical).',
      'Modernismo e Redescoberta (Século XX - XXI): Registro acadêmico sistemático por intelectuais e transição para os meios de comunicação em massa.'
    ],
    scientificNote: 'A historiografia folclórica divide o estudo nacional em antes e depois da publicação da "Geografia dos Mitos Brasileiros" (1947), que mapeou espacialmente as correntes migratórias de cada lenda.'
  },
  'Árvore genealógica dos deuses': {
    title: 'Cosmogonia e Linhagens Sobrenaturais',
    details: 'As linhagens do folclore conectam as divindades criadoras celestes aos seres protetores das florestas e das águas, estabelecendo uma hierarquia de parentesco e responsabilidade espiritual na guarda do equilíbrio cósmico e ecológico.',
    bullets: [
      'Tupã (O Criador Supremo): O pai de toda a existência material, doador da luz e da ordem.',
      'Guaraci (Sol) e Jaci (Lua): Irmãos e consortes cósmicos criados por Tupã para governar o ciclo temporal. Guaraci protege o dia e a fauna diurna; Jaci cuida da noite, da intuição e dos rituais.',
      'Rudá (Deus do Amor): Criado para harmonizar as relações terrestres e divinas.',
      'Os Protetores da Terra: Curupira, Caipora e Iara atuam como comandantes espirituais diretos das criaturas inferiores e dos elementos naturais.'
    ],
    scientificNote: 'Embora a árvore tupi-guarani seja a mais sistemática, o folclore moderno também incorpora linhagens sincretizadas onde santos e orixás operam como guardiões diretos de biomas e povos.'
  },
  'Mapa de origem': {
    title: 'Cartografia Mística do Brasil',
    details: 'Cada região geográfica brasileira desenvolveu narrativas únicas influenciadas diretamente pela vegetação local, ocupação histórica e imigração populacional predominantemente estabelecida na área.',
    bullets: [
      'Região Norte: O Boto-cor-de-rosa, a Iara (mãe-d\'água), a Cobra Grande (Boiaçu) e a Vitória-Régia dominam os rios caudalosos.',
      'Região Nordeste: O Cabeça de Cuia nos rios piauienses, a Caipora e o vaqueiro misterioso assombram a caatinga rural.',
      'Região Sudeste e Centro-Oeste: O Saci-Pererê, a Mula sem Cabeça e o Lobisomem habitam as fazendas e matas ciliares históricas.',
      'Região Sul: O Negrinho do Pastoreio e o Boitatá (fogo-fátuo) cruzam os vastos pampas e campos frios de araucárias.'
    ],
    scientificNote: 'A distribuição espacial dos mitos prova que o folclore não é homogêneo, mas sim uma resposta imaginativa direta à geografia física e ao isolamento demográfico do interior do país.'
  },
  'Obras literárias relacionadas': {
    title: 'O Cânone Literário do Folclore',
    details: 'O resgate literário do folclore salvou centenas de tradições orais de desaparecerem com a urbanização. Escritores modernos transformaram a matéria-prima mitológica em alta literatura acadêmica, infanto-juvenil e de ficção nacional.',
    bullets: [
      'Dicionário do Folclore Brasileiro (Luís da Câmara Cascudo): A maior obra de referência enciclopédica sobre crenças e costumes nacionais.',
      'Macunaíma (Mário de Andrade): Obra-prima modernista que desconstrói a identidade nacional misturando dezenas de lendas e dialetos regionais.',
      'Lendas do Sul (João Simões Lopes Neto): Coletânea de contos folclóricos que imortalizou a alma e as narrativas do pampa gaúcho.',
      'O Sítio do Picapau Amarelo (Monteiro Lobato): Popularização infantojuvenil que introduziu o Saci e a Cuca no imaginário de gerações de leitores urbanos.'
    ],
    scientificNote: 'A literatura folclórica brasileira desempenhou papel central no movimento modernista de 1922, que buscava romper com a cópia estética europeia e fundar uma arte legitimamente nacional e sincrética.'
  },
  'Influência na cultura moderna': {
    title: 'Sobrevivência e Expressão na Cultura Pop',
    details: 'Longe de estar confinado a livros de história antigos, o folclore brasileiro experimenta um renascimento vigoroso no século XXI, sendo reinterpretado pela ficção científica, séries de streaming internacionais, artes visuais e jogos.',
    bullets: [
      'Festas e Celebrações: O Carnaval, o Bumba meu Boi do Maranhão, e as ricas Festas Juninas preservam encenações míticas originais.',
      'Cidade Invisível (Netflix): Série de suspense que reimagina as criaturas mitológicas (Saci, Curupira, Boto, Iara) vivendo disfarçadas na metrópole moderna do Rio de Janeiro.',
      'Jogos Eletrônicos: Títulos indie nacionais usam a mitologia brasileira para criar narrativas fantásticas de ação e exploração.'
    ],
    scientificNote: 'A ressignificação contemporânea do folclore atua como um movimento político e cultural de soberania criativa, valorizando o patrimônio nacional frente à hegemonia cultural de mitologias estrangeiras.'
  },
  'Fontes': {
    title: 'Evidências e Testemunhos Históricos',
    details: 'A reconstrução histórica do folclore é amparada por ricas fontes primárias textuais que datam desde a chegada da frota portuguesa em 1500, estendendo-se por relatórios coloniais e cadernos de campo etnográficos de pesquisadores nacionais e estrangeiros.',
    bullets: [
      'Carta de Pero Vaz de Caminha (1500): Primeiras impressões sobre a relação espiritual e o modo de vida das populações nativas do litoral baiano.',
      'Cartas de José de Anchieta (1560): Relatos detalhados sobre as crenças indígenas e o medo do Curupira (designado por ele como "demônios da floresta").',
      'Viagens Philosophicas (Alexandre Rodrigues Ferreira): Documentação científica iluminista do século XVIII mapeando mitos fluviais da Amazônia.',
      'Coleção Rondon: Registro fotográfico, fonográfico e etnográfico sistemático das etnias do interior do Brasil no início do século XX.'
    ],
    scientificNote: 'A maior parte das fontes originais está sob custódia de instituições públicas como a Biblioteca Nacional no Rio de Janeiro e o Arquivo Histórico Ultramarino em Lisboa.'
  },
  'Bibliografia': {
    title: 'Bibliografia Acadêmica Recomendada',
    details: 'Para os estudantes e cientistas sociais que desejam aprofundar-se no estudo empírico e estrutural das manifestações tradicionais brasileiras, as seguintes obras constituem a base científica indispensável:',
    bullets: [
      'CASCUDO, Luís da Câmara. Geografia dos Mitos Brasileiros. Rio de Janeiro: José Olympio, 1947.',
      'CASCUDO, Luís da Câmara. Dicionário do Folclore Brasileiro. Rio de Janeiro: Instituto Nacional do Livro, 1954.',
      'FERNANDES, Florestan. O Folclore em Questão. São Paulo: Hucitec, 1978.',
      'ANDRADE, Mário de. Danças Dramáticas do Brasil. Belo Horizonte: Itatiaia, 1982.',
      'SIMÕES LOPES NETO, João. Contos Gauchescos e Lendas do Sul. Porto Alegre, 1913.'
    ],
    scientificNote: 'Estes estudos demonstram que as lendas não são falsidades infantis, mas sim códigos sociológicos altamente sofisticados que explicam a formação social, moral e psicológica do povo brasileiro.'
  }
};
