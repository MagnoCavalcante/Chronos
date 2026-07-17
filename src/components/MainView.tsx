/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState, useMemo, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import {
  Compass,
  Flame,
  Search,
  Bookmark,
  Filter,
  CheckCircle,
  LogOut,
  Shield,
  BookOpen,
  Info,
  ChevronRight,
  TrendingUp,
  FileText,
  AlertCircle,
  Sparkles,
  ChevronLeft,
  Globe,
  Network,
  ArrowRight,
  Database,
  GitBranch,
  Cpu,
  Calendar,
  Map
} from 'lucide-react';
import { Tab, User, HistoryCard, Screen, KGNode, KGRelationship, EntityType, EvidenceLevel } from '../types';
import ConceptCard from './ConceptCard';
import BottomNav from './BottomNav';
import { CHRONOSKnowledgeEngine } from '../lib/knowledgeGraphEngine';
import { folcloreBrasileiroData } from '../data/folcloreData';

// Instantiate the singleton Knowledge Graph engine
const kgEngine = new CHRONOSKnowledgeEngine();

const ENTITY_TYPE_TRANSLATIONS: Record<EntityType, string> = {
  PERSONAGEM: 'Personagem',
  EVENTO: 'Evento',
  CIVILIZACAO: 'Civilização',
  IMPERIO: 'Império',
  GUERRA: 'Guerra',
  TRATADO: 'Tratado',
  PAIS: 'País',
  CIDADE: 'Cidade',
  RELIGIAO: 'Religião',
  FILOSOFIA: 'Filosofia',
  MOVIMENTO: 'Movimento',
  TECNOLOGIA: 'Tecnologia',
  OBJETO_HISTORICO: 'Objeto Histórico',
  CONSTRUCAO: 'Construção',
  LIVRO: 'Livro',
  DOCUMENTO: 'Documento',
  FONTE: 'Fonte',
  AUTOR: 'Autor',
  DESCOBERTA: 'Descoberta',
  DATA: 'Data',
  PERIODO_HISTORICO: 'Período Histórico',
  MITOLOGIA: 'Mitologia',
  DEUS: 'Deus',
  CRIATURA_MITOLOGICA: 'Criatura Mitológica',
  ARTEFATO_MITOLOGICO: 'Artefato Mitológico'
};

const RELATIONSHIP_TYPE_TRANSLATIONS: Record<string, string> = {
  PARTICIPATED_IN: 'Participou de',
  OCCURRED_IN: 'Ocorreu em',
  BELONGS_TO: 'Pertence a',
  PART_OF_CIVILIZATION: 'Faz parte da civilização',
  HAS_BATTLE: 'Possui batalha',
  CITES_DOCUMENT: 'Cita documento',
  PROVES_EVENT: 'Comprova evento',
  WROTE_BOOK: 'Escreveu livro',
  REFERENCES_THEME: 'Referencia tema',
  INFLUENCED: 'Influenciou',
  RULED_EMPIRE: 'Governou império',
  CREATED_TECH: 'Criou tecnologia/descoberta',
  CONSTRUCTED_BY: 'Erguido por',
  LOCATED_AT: 'Localizado em',
  TEMPORAL_ANCHOR: 'Ancorado temporalmente em',
  BELONGS_TO_MYTHOLOGY: 'Pertence à mitologia',
  ASSOCIATED_WITH: 'Associado com'
};

interface MainViewProps {
  user: User;
  onLogout: () => void;
  onNavigate: (screen: Screen) => void;
  onEnterEpoch?: (year: number) => void;
  initialYear?: number;
}

export default function MainView({ user, onLogout, onNavigate, onEnterEpoch, initialYear }: MainViewProps) {
  const [activeTab, setActiveTab] = useState<Tab>('home');
  const [userState, setUserState] = useState<User>(user);
  const [masteredCards, setMasteredCards] = useState<string[]>([]);
  const [activePeriod, setActivePeriod] = useState<string>('Todos');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [selectedMythology, setSelectedMythology] = useState<string | null>(null);
  const [activeMythologySection, setActiveMythologySection] = useState<string>('Introdução');

  // Infinite Timeline & Global Simultaneous Events State
  const TIMELINE_STEPS = [
    {
      id: 'sumeria',
      year: -3200,
      label: '3200 a.C.',
      era: 'Antiguidade Oriental',
      title: 'A Aurora da Escrita',
      description: 'A invenção da escrita cuneiforme na Mesopotâmia marca o início do registro documental humano e o nascimento da própria História.',
      meanwhile: [
        { region: 'Egito Antigo', event: 'Período Pré-Dinástico tardio; início da unificação das terras do Alto e Baixo Egito sob o lendário Rei Narmer.' },
        { region: 'América Latina', event: 'Desenvolvimento e expansão do cultivo primário do milho na Mesoamérica e as primeiras cerâmicas andinas.' },
        { region: 'Ásia (China)', event: 'Surgimento das primeiras culturas neolíticas organizadas e canais de cultivo de arroz ao longo do Rio Amarelo.' },
        { region: 'Europa', event: 'Início da construção das primeiras estruturas megalíticas de Stonehenge nas planícies da atual Inglaterra.' }
      ],
      mapUrl: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
      mapLabel: 'Crescente Fértil & Vale do Nilo'
    },
    {
      id: 'grecia-classica',
      year: -500,
      label: '500 a.C.',
      era: 'Antiguidade Clássica',
      title: 'O Século de Ouro da Filosofia',
      description: 'O surgimento da democracia ateniense e a efervescência das principais correntes intelectuais e filosóficas que moldaram o pensamento ocidental.',
      meanwhile: [
        { region: 'China', event: 'Período das Cem Escolas de Pensamento, dominado pela sabedoria de Confúcio e pelo nascimento do Taoísmo de Laozi.' },
        { region: 'América', event: 'Ascensão da Civilização Zapoteca na Mesoamérica e expansão do centro urbano de Monte Albán.' },
        { region: 'Índia', event: 'Surgimento e pregação de Siddhartha Gautama (o Buda), desafiando a estrutura de castas védica.' },
        { region: 'África', event: 'Desenvolvimento da metalurgia do ferro pela cultura Nok na região da atual Nigéria.' }
      ],
      mapUrl: 'https://images.unsplash.com/photo-1507608869274-d3177c8bb4c7?auto=format&fit=crop&w=800&q=80',
      mapLabel: 'Hélade Clássica e Cidades-Estado'
    },
    {
      id: 'roma-republica',
      year: -49,
      label: '49 a.C.',
      era: 'Antiguidade Clássica Romana',
      title: 'A Sorte está Lançada',
      description: 'Júlio César lidera a XIII Legião através do rio Rubicão, quebrando as leis constitucionais e deflagrando a Grande Guerra Civil contra Pompeu.',
      meanwhile: [
        { region: 'China Imperial', event: 'A Dinastia Han Ocidental consolida o comércio global transcontinental por meio da expansão da Rota da Seda.' },
        { region: 'América', event: 'Teotihuacán expande suas primeiras fundações monumentais e planeja as imponentes pirâmides no Vale do México.' },
        { region: 'Egito Ptolemaico', event: 'A rainha Cleópatra VII disputa o trono contra seu irmão Ptolemeu XIII, buscando alianças com generais romanos.' },
        { region: 'Índia', event: 'O florescente Império Satavahana domina as rotas comerciais marítimas e patrocina templos escavados em rochas.' }
      ],
      mapUrl: 'https://images.unsplash.com/photo-1507608869274-d3177c8bb4c7?auto=format&fit=crop&w=800&q=80',
      mapLabel: 'Expansão do Império e Províncias Romanas'
    },
    {
      id: 'queda-roma',
      year: 476,
      label: '476 d.C.',
      era: 'Antiguidade Tardia / Idade Média',
      title: 'O Fim de um Império',
      description: 'O líder germânico Odoacro depõe o jovem imperador romano Rômulo Augusto, decretando o fim do Império Romano do Ocidente.',
      meanwhile: [
        { region: 'Império Bizantino', event: 'Constantinopla ergue fortificações intransponíveis sob a égide imperial do Oriente romano.' },
        { region: 'América do Sul', event: 'Florescimento da cultura mística Nazca nos desertos andinos, criando as monumentais linhas geoglíficas.' },
        { region: 'Ásia (Japão)', event: 'Período Kofun tardio; consolidação das primeiras dinastias reais unificadas na planície de Yamato.' },
        { region: 'África Oriental', event: 'O Reino de Aksum domina as rotas comerciais do Mar Vermelho, cunhando moedas de ouro próprias.' }
      ],
      mapUrl: 'https://images.unsplash.com/photo-1543128639-4cb7e6eeef1b?auto=format&fit=crop&w=800&q=80',
      mapLabel: 'Fragmentação da Europa Ocidental em Reinos Germânicos'
    },
    {
      id: 'tordesilhas',
      year: 1492,
      label: '1492 d.C.',
      era: 'Idade Moderna',
      title: 'O Encontro de Mundos',
      description: 'A expedição espanhola atinge as ilhas do Caribe, iniciando o processo de colonização global e precipitando o Tratado de Tordesilhas.',
      meanwhile: [
        { region: 'Brasil Pré-Cabralino', event: 'Milhares de comunidades indígenas das etnias tupi e jê dominam com maestria a costa atlântica sul-americana.' },
        { region: 'China Imperial (Ming)', event: 'A dinastia Ming reconstrói trechos cruciais da Grande Muralha e enriquece as artes com porcelanas célebres.' },
        { region: 'Japão Feudal', event: 'Período Sengoku; guerras entre samurais locais desintegram o poder central do Shogunato Ashikaga.' },
        { region: 'Império Otomano', event: 'O sultão Bayezid II acolhe e protege milhares de intelectuais e judeus expulsos da península Ibérica.' }
      ],
      mapUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=800&q=80',
      mapLabel: 'Partição de Tordesilhas e Rotas Marítimas Globais'
    },
    {
      id: 'revolucao-francesa',
      year: 1789,
      label: '1789 d.C.',
      era: 'Idade Contemporânea',
      title: 'A Era das Revoluções',
      description: 'O assalto popular à Bastilha em Paris encerra o Antigo Regime Absolutista, espalhando os ideais de direitos humanos pelo globo.',
      meanwhile: [
        { region: 'Brasil Colonial', event: 'A conspiração da Inconfidência Mineira tenta libertar a capitania de Minas Gerais diante do peso da Derrama real.' },
        { region: 'Estados Unidos', event: 'George Washington toma posse formal como o primeiro presidente constitucional da jovem república americana.' },
        { region: 'Império Otomano', event: 'Início das reformas militares e administrativas sob o sultão Selim III para modernizar as fronteiras islâmicas.' },
        { region: 'Ásia (China Qing)', event: 'O imperador Qianlong atinge o auge da expansão territorial e da opulência cultural antes do declínio dinástico.' }
      ],
      mapUrl: 'https://images.unsplash.com/photo-1513829096999-4978602297f7?auto=format&fit=crop&w=800&q=80',
      mapLabel: 'Europa Revolucionária e Focos Iluministas'
    },
    {
      id: 'pouso-lua',
      year: 1969,
      label: '1969 d.C.',
      era: 'Idade Contemporânea Tardia',
      title: 'Um Pequeno Passo para o Homem',
      description: 'A tripulação da Apollo 11 caminha pela primeira vez no solo lunar, estabelecendo o zênite tecnológico e científico da Guerra Fria.',
      meanwhile: [
        { region: 'América Latina', event: 'Proliferação de regimes ditatoriais sob o contexto de disputas geopolíticas ideológicas da Guerra Fria.' },
        { region: 'Vietnã', event: 'Conflito armado na Indochina atinge seu auge de combates táticos e massivos protestos pacifistas globais.' },
        { region: 'África', event: 'Segunda grande onda de declarações de independência e lutas contra o domínio colonial europeu.' },
        { region: 'Japão', event: 'Auge do "milagre econômico pós-guerra", despontando como superpotência de eletrônicos de consumo e infraestrutura.' }
      ],
      mapUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=800&q=80',
      mapLabel: 'Ordem Geopolítica Bipolar da Guerra Fria'
    }
  ];

  const [currentTimelineIndex, setCurrentTimelineIndex] = useState<number>(() => {
    if (typeof initialYear === 'number') {
      const idx = TIMELINE_STEPS.findIndex(step => step.year === initialYear);
      if (idx !== -1) return idx;
    }
    return 2; // Default is 49 a.C. or 476 d.C.
  });
  const [viewingDossier, setViewingDossier] = useState<boolean>(() => {
    if (typeof initialYear === 'number') {
      const idx = TIMELINE_STEPS.findIndex(step => step.year === initialYear);
      return idx !== -1;
    }
    return false;
  });

  useEffect(() => {
    if (typeof initialYear === 'number') {
      const idx = TIMELINE_STEPS.findIndex(step => step.year === initialYear);
      if (idx !== -1) {
        setCurrentTimelineIndex(idx);
        setViewingDossier(true);
      }
    }
  }, [initialYear]);

  const [selectedNodeDetailsId, setSelectedNodeDetailsId] = useState<string | null>(null);

  // Knowledge Graph exploration states
  const [searchSubTab, setSearchSubTab] = useState<'cards' | 'graph'>('graph');
  const [graphQuery, setGraphQuery] = useState<string>('');
  const [selectedNodeId, setSelectedNodeId] = useState<string>('char-cesar');
  const [pathStartId, setPathStartId] = useState<string>('char-cesar');
  const [pathEndId, setPathEndId] = useState<string>('god-jupiter');
  const [pathResult, setPathResult] = useState<{ node: KGNode; relationship?: KGRelationship }[] | null>(null);
  const [pathError, setPathError] = useState<string | null>(null);

  const mythologies = [
    { id: 'grega', name: 'Mitologia Grega', region: 'Hélade (Grécia Antiga)', era: 'Século XII a.C. - Século IV d.C.', color: 'border-amber-500/20 text-amber-700 bg-amber-500/5 hover:bg-amber-500/10' },
    { id: 'romana', name: 'Mitologia Romana', region: 'Roma Antiga', era: 'Século VIII a.C. - Século V d.C.', color: 'border-rose-500/20 text-rose-700 bg-rose-500/5 hover:bg-rose-500/10' },
    { id: 'nordica', name: 'Mitologia Nórdica', region: 'Escandinávia', era: 'Século VIII d.C. - Século XI d.C.', color: 'border-amber-600/20 text-amber-800 bg-amber-600/5 hover:bg-amber-600/10' },
    { id: 'egipcia', name: 'Mitologia Egípcia', region: 'Vale do Nilo (Egito Antigo)', era: '3100 a.C. - Século IV d.C.', color: 'border-yellow-600/20 text-yellow-800 bg-yellow-600/5 hover:bg-yellow-600/10' },
    { id: 'celta', name: 'Mitologia Celta', region: 'Europa Ocidental', era: 'Século VI a.C. - Século VI d.C.', color: 'border-emerald-600/20 text-emerald-800 bg-emerald-600/5 hover:bg-emerald-600/10' },
    { id: 'mesopotamica', name: 'Mitologia Mesopotâmica', region: 'Crescente Fértil (Suméria, Babilônia)', era: '3500 a.C. - Século VI a.C.', color: 'border-amber-700/20 text-amber-900 bg-amber-700/5 hover:bg-amber-700/10' },
    { id: 'japonesa', name: 'Mitologia Japonesa', region: 'Arquipélago Japonês (Xintoísmo)', era: 'Século VII d.C. - Presente', color: 'border-red-600/20 text-red-800 bg-red-600/5 hover:bg-red-600/10' },
    { id: 'chinesa', name: 'Mitologia Chinesa', region: 'Planície do Rio Amarelo', era: '2000 a.C. - Presente', color: 'border-orange-600/20 text-orange-800 bg-orange-600/5 hover:bg-orange-600/10' },
    { id: 'maia', name: 'Mitologia Maia', region: 'Mesoamérica (Península de Iucatã)', era: '2000 a.C. - Século XVI d.C.', color: 'border-teal-600/20 text-teal-800 bg-teal-600/5 hover:bg-teal-600/10' },
    { id: 'asteca', name: 'Mitologia Asteca', region: 'Mesoamérica (Vale do México)', era: 'Século XIII d.C. - Século XVI d.C.', color: 'border-yellow-700/20 text-yellow-900 bg-yellow-700/5 hover:bg-yellow-700/10' },
    { id: 'inca', name: 'Mitologia Inca', region: 'Região Andina (América do Sul)', era: 'Século XII d.C. - Século XVI d.C.', color: 'border-yellow-500/20 text-yellow-750 bg-yellow-500/5 hover:bg-yellow-500/10' },
    { id: 'hindu', name: 'Mitologia Hindu', region: 'Subcontinente Indiano (Vedas)', era: '1500 a.C. - Presente', color: 'border-purple-600/20 text-purple-800 bg-purple-600/5 hover:bg-purple-600/10' },
    { id: 'brasileiro', name: 'Folclore Brasileiro', region: 'Brasil (América do Sul)', era: 'Século XVI - Presente', color: 'border-emerald-500/20 text-emerald-800 bg-emerald-500/5 hover:bg-emerald-500/10' }
  ];

  const mythologySections = [
    { title: 'Introdução', description: 'Visão geral da tradição mitológica, contexto histórico-geográfico de surgimento e importância sociocultural do estudo.' },
    { title: 'Cosmologia', description: 'Como a tradição compreendia a organização do cosmos, o plano divino, o mundo físico e o submundo.' },
    { title: 'Origem do mundo', description: 'O mito da criação original (teogonia/cosmogonia), separação dos elementos primordiais e ascensão das divindades.' },
    { title: 'Principais deuses', description: 'Catálogo de divindades soberanas, seus domínios sagrados, atributos rituais e símbolos sagrados associados.' },
    { title: 'Heróis', description: 'Narrativas de semideuses, guerreiros mortais agraciados pelo divino e suas sagas de superação de limites.' },
    { title: 'Criaturas', description: 'Feras místicas, guardiões de portais, monstros elementais e seres fantásticos descritos nos manuscritos literários.' },
    { title: 'Objetos lendários', description: 'Armas divinas, cálices rituais, amuletos celestes, relíquias de poder e artefatos de relevância simbólica.' },
    { title: 'Locais sagrados', description: 'Santuários, montanhas místicas, templos oraculares, rios transcendentais e moradas divinas descritas.' },
    { title: 'Linha do tempo da tradição', description: 'Estruturação sequencial das eras mitológicas (ex: Idade de Ouro, Idade de Prata) e ciclos cosmogônicos.' },
    { title: 'Árvore genealógica dos deuses', description: 'Esquema de parentesco, consórcios sagrados e progênies divinas das dinastias sobrenaturais.' },
    { title: 'Mapa de origem', description: 'Geografia mística sobreposta à cartografia do mundo antigo, identificando locais rituais.' },
    { title: 'Obras literárias relacionadas', description: 'Códices, epopeias, hinos litúrgicos e manuscritos originais preservados onde as narrativas são contadas.' },
    { title: 'Influência na cultura moderna', description: 'Apropriações semânticas, termos artísticos, representações na ficção científica, psicologia analítica e cultura popular contemporânea.' },
    { title: 'Fontes', description: 'Evidências textuais, tabuletas arqueológicas, inscrições epigráficas e fragmentos históricos de sustentação acadêmica da tradição.' },
    { title: 'Bibliografia', description: 'Compilado de monografias, traduções críticas e estudos mitológicos contemporâneos recomendados.' }
  ];

  // Rigorous Academic Dataset covering different epochs & reliability scores
  const mockCards: HistoryCard[] = [
    {
      id: 'tordesilhas',
      category: 'História',
      period: 'Idade Moderna',
      title: 'O Tratado de Tordesilhas (1494)',
      era: 'Fim do Século XV (1494)',
      evidenceLevel: 'high',
      summary: 'A divisão diplomática e cartográfica do Novo Mundo entre as coroas de Castela e Portugal chancelada pela Igreja Católica.',
      fact: {
        title: 'O Acordo Diplomático Real',
        description: 'O tratado foi assinado em 7 de junho de 1494 na vila espanhola de Tordesilhas. Os originais em pergaminho estão preservados no Archivo General de Indias em Sevilha e no Arquivo Nacional da Torre do Tombo em Lisboa, constituindo prova documental absoluta de sua assinatura.'
      },
      interpretation: {
        title: 'Interpretação Geopolítica',
        description: 'Historiadores debatem se Portugal já tinha conhecimento prévio da existência do território sul-americano antes de 1500, o que justificaria a insistência de D. João II em mover a linha divisória papal de 100 para 370 léguas a oeste do arquipélago de Cabo Verde.'
      },
      hypothesis: {
        title: 'A Tese das Viagens Secretas',
        description: 'Alguns historiadores navais levantam a hipótese de que caravelas portuguesas realizaram incursões secretas de reconhecimento na costa leste do Brasil entre 1493 e 1494, reportando sigilosamente os ventos e correntes ao rei.'
      },
      timeline: [
        { year: '1493', event: 'O Papa Alexandre VI promulga a bula Inter Coetera dividindo as terras descobertas.' },
        { year: '1494', event: 'Representantes de Portugal e Castela reúnem-se na vila de Tordesilhas e redefinem o meridiano.' },
        { year: '1506', event: 'O Papa Júlio II emite a bula Ea Quae, ratificando formalmente o tratado geopolítico.' }
      ],
      characters: [
        { name: 'D. João II', role: 'Rei de Portugal', bio: 'Estrategista diplomático astuto que liderou a pressão portuguesa pela mudança da linha de partilha.' },
        { name: 'Reis Católicos', role: 'Monarcas de Aragão e Castela', bio: 'Isabel I e Fernando II, os quais autorizaram as negociações após a primeira viagem de Colombo.' }
      ],
      sources: [
        { id: 'src-tor-1', title: 'História dos Descobrimentos Portugueses', author: 'Jaime Cortesão', year: 1960, type: 'book', details: 'Volume II, Cap. IV' },
        { id: 'src-tor-2', title: 'Tratado de Tordesillas: Pergaminho de Ratificação', author: 'Chancelaria Real', year: 1494, type: 'document', details: 'Gaveta 15, Maço 1' },
        { id: 'src-tor-3', title: 'Cartografia e Diplomacia no Século XV', author: 'Luís de Albuquerque', year: 1983, type: 'article', details: 'Revista de Estudos Históricos, nº 12' }
      ]
    },
    {
      id: 'alexandria',
      category: 'História',
      period: 'Antiguidade',
      title: 'O Incêndio da Biblioteca de Alexandria',
      era: 'Século III a.C. - Século IV d.C.',
      evidenceLevel: 'good',
      summary: 'A investigação sobre a perda material da maior biblioteca do mundo antigo. Mito de catástrofe única vs. Realidade arqueológica.',
      fact: {
        title: 'Destruição Progressiva Documentada',
        description: 'O acervo sofreu múltiplos estragos e perdas progressivas ao longo de séculos, incluindo a destruição parcial acidental na guerra civil de Júlio César (48 a.C.), o cerco de Aureliano (272 d.C.) e o fechamento do Serapeum por ordem de Teodósio I (391 d.C.).'
      },
      interpretation: {
        title: 'Análise da Decadência Material',
        description: 'A historiografia tradicional buscava culpar um único evento traumático (como a invasão islâmica ou o fanatismo cristão). Pesquisas atuais interpretam que a biblioteca definhou gradualmente devido ao corte de subsídios públicos imperiais, falta de escribas qualificados e obsolescência dos suportes físicos de papiro.'
      },
      hypothesis: {
        title: 'Dispersão Prévia de Coleções',
        description: 'Vários helenistas argumentam que os manuscritos mais valiosos foram dispersados ou vendidos para acervos particulares em Roma, Constantinopla e Atenas muito antes da depredação final das estruturas físicas do templo egípcio.'
      },
      timeline: [
        { year: '48 a.C.', event: 'O porto de Alexandria é incendiado durante a campanha militar de Júlio César contra Pompeu.' },
        { year: '272 d.C.', event: 'O Imperador Aureliano devasta o distrito real (Brouchion) onde se situava a sede central.' },
        { year: '391 d.C.', event: 'Templos pagãos são fechados e saqueados após o edito de Teodósio I, afetando a biblioteca satélite.' }
      ],
      characters: [
        { name: 'Ptolomeu I Sóter', role: 'Faraó do Egito Ptolomaico', bio: 'Fundador do Museu e da Grande Biblioteca de Alexandria, estabelecendo o polo intelectual.' },
        { name: 'Hipátia de Alexandria', role: 'Matemática e Filósofa', bio: 'Última grande docente vinculada às instituições académicas alexandrinas clássicas.' }
      ],
      sources: [
        { id: 'src-ale-1', title: 'The Vanished Library: A Wonder of the Ancient World', author: 'Luciano Canfora', year: 1989, type: 'book', details: 'Páginas 85-110' },
        { id: 'src-ale-2', title: 'Alexandria in Late Antiquity: Topography and Social Conflict', author: 'Christopher Haas', year: 2002, type: 'book', details: 'Capítulo III' },
        { id: 'src-ale-3', title: 'Excavations in the Royal Quarter of Alexandria', author: 'Franck Goddio', year: 2008, type: 'archaeological', details: 'Relatório Científico IEASM' }
      ]
    },
    {
      id: 'romadecline',
      category: 'História',
      period: 'Idade Média',
      title: 'A Queda do Império Romano do Ocidente',
      era: 'Século V (476 d.C.)',
      evidenceLevel: 'debate',
      summary: 'A desintegração da autoridade imperial na Itália e a transição para a era medieval. Um debate historiográfico clássico de múltiplas teses.',
      fact: {
        title: 'A Deposição de Rômulo Augusto',
        description: 'Em setembro de 476 d.C., o líder mercenário germânico Odoacro depôs o jovem usurpador imperial Rômulo Augusto. Odoacro não reivindicou o título imperial, mas enviou as insígnias reais para Constantinopla, declarando-se regente territorial.'
      },
      interpretation: {
        title: 'Monocausa Clássica vs. Multicausalidade',
        description: 'No século XVIII, Edward Gibbon propôs que o cristianismo e o enfraquecimento moral minaram as instituições. A historiografia moderna liderada por Peter Heather rejeita a ideia de "decadência interna pura", enfatizando o impacto logístico insustentável das migrações de povos bárbaros impulsionados pelos hunos.'
      },
      hypothesis: {
        title: 'Tese Climática e Pandêmica',
        description: 'Historiadores ambientais propõem que o declínio romano coincidiu com uma fase de instabilidade climática severa (Pequena Idade do Gelo do Ano 536) e surtos epidemiológicos severos que dizimaram a mão de obra camponesa e a arrecadação de impostos.'
      },
      timeline: [
        { year: '410 d.C.', event: 'Roma é saqueada pelos visigodos sob comando de Alarico, abalando o prestígio imperial.' },
        { year: '476 d.C.', event: 'Odoacro assume o controle militar da Itália, extinguindo a linhagem oficial de imperadores ocidentais.' },
        { year: '541 d.C.', event: 'A Peste de Justiniano assola o Mediterrâneo, inviabilizando tentativas persistentes de reconquista.' }
      ],
      characters: [
        { name: 'Rômulo Augusto', role: 'Último Imperador Ocidental', bio: 'Adolescente entronizado pelo pai que serviu como figura decorativa no desfecho da corte de Ravena.' },
        { name: 'Odoacro', role: 'Rei dos Hérulos e General', bio: 'Oficial militar germânico que destituiu a autoridade fantoche romana e governou sob vassalagem de Bizâncio.' }
      ],
      sources: [
        { id: 'src-rom-1', title: 'The Fall of the Roman Empire: A New History', author: 'Peter Heather', year: 2005, type: 'book', details: 'Capítulo VII' },
        { id: 'src-rom-2', title: 'The Fate of Rome: Climate, Disease, and the End of an Empire', author: 'Kyle Harper', year: 2017, type: 'book', details: 'Parte III, pág. 120-165' },
        { id: 'src-rom-3', title: 'History of the Decline and Fall of the Roman Empire', author: 'Edward Gibbon', year: 1776, type: 'book', details: 'Edição Crítica de 1994' }
      ]
    },
    {
      id: 'reiartur',
      category: 'História',
      period: 'Idade Média',
      title: 'A Historicidade do Rei Artur',
      era: 'Idade das Trevas Britânica (Século VI)',
      evidenceLevel: 'hypothesis',
      summary: 'A busca por vestígios materiais e contemporâneos do lendário líder guerreiro da Távola Redonda. Lenda vs. Realidade Arqueológica.',
      fact: {
        title: 'Silêncio Documental Contemporâneo',
        description: 'Não existe qualquer menção a um líder chamado "Artur" nas crônicas e tratados britânicos autênticos sobreviventes do século VI, tais como o "De Excidio et Conquestu Britanniae" escrito pelo monge Gildas.'
      },
      interpretation: {
        title: 'Construção Mítica de Identidade',
        description: 'A maioria dos medievalistas contemporâneos interpreta Artur não como um homem real singular, mas como um amálgama literário — uma figura mítica composta para simbolizar a brava resistência militar dos bretões romano-celtas contra a invasão anglo-saxã.'
      },
      hypothesis: {
        title: 'O General Riothamus',
        description: 'Pesquisadores como Geoffrey Ashe propõem a hipótese de que o modelo real que inspirou as lendas arturianas teria sido Riothamus, um chefe militar bretão-romano de comprovada atividade na Gália em meados de 470 d.C.'
      },
      timeline: [
        { year: '516 d.C.', event: 'Batalha do Monte Badon, onde guerreiros britões impõem séria derrota tática aos saxões.' },
        { year: '830 d.C.', event: 'A crônica "Historia Brittonum" registra formalmente a primeira menção de Artur como general britânico.' },
        { year: '1136 d.C.', event: 'Geoffrey de Monmouth publica sua crônica fictícia, fundando os mitos medievais cavaleirescos.' }
      ],
      characters: [
        { name: 'Gildas Sapiens', role: 'Historiador e Monge', bio: 'Único cronista britânico sobrevivente do século VI; descreveu as batalhas saxãs mas nunca citou o nome de Artur.' },
        { name: 'Geoffrey de Monmouth', role: 'Clérigo e Escritor', bio: 'Autor galês medieval cujos manuscritos altamente ficcionalizados deram origem ao mito do rei lendário.' }
      ],
      sources: [
        { id: 'src-art-1', title: 'The Discovery of King Arthur', author: 'Geoffrey Ashe', year: 1985, type: 'book', details: 'Cap. II, pág. 45-70' },
        { id: 'src-art-2', title: 'Historia Brittonum', author: 'Atribuído a Nênio', year: 830, type: 'document', details: 'Seção 56 (Códice Harleiano)' },
        { id: 'src-art-3', title: 'Arthurian Literature in the Middle Ages', author: 'Roger Sherman Loomis', year: 1959, type: 'book', details: 'Capítulo I' }
      ]
    },
    {
      id: 'sumeria',
      category: 'História',
      period: 'Antiguidade',
      title: 'A Invenção da Escrita Cuneiforme (c. 3200 a.C.)',
      era: 'Antiguidade Oriental (c. 3200 a.C.)',
      evidenceLevel: 'high',
      summary: 'A transição da proto-escrita para o sistema cuneiforme na Mesopotâmia meridional, inaugurando a história documental registrada.',
      fact: {
        title: 'Evidências Epigráficas de Uruk',
        description: 'Tabuletas de argila encontradas no nível IV do templo de Eanna em Uruk contêm registros contábeis pictográficos que demonstram a evolução de fichas físicas de argila (calculi) para marcas abstratas cunhadas, representando mercadorias e transações rituais.'
      },
      interpretation: {
        title: 'A Tese de Denise Schmandt-Besserat',
        description: 'A arqueologia debate as pressões sociais para o nascimento da escrita. A arqueóloga Denise Schmandt-Besserat demonstrou que a escrita cuneiforme evoluiu diretamente de um sistema tridimensional de fichas de contabilidade, refutando a teoria de que surgiu puramente como expressão poética ou religiosa primária.'
      },
      hypothesis: {
        title: 'Monogênese vs. Poligênese da Escrita',
        description: 'Embora o consenso aponte para a Suméria como o primeiro foco de escrita silábico-logográfica, pesquisadores levantam a hipótese de desenvolvimento independente simultâneo no Vale do Nilo e na China, desafiando a difusão cultural mesopotâmica direta.'
      },
      timeline: [
        { year: '3400 a.C.', event: 'Uso generalizado de "bullae" de argila seladas contendo fichas geométricas de contabilidade.' },
        { year: '3200 a.C.', event: 'Primeiras tabuletas de argila gravadas com estiletes de junco em Uruk, contendo escrita proto-cuneiforme.' },
        { year: '2600 a.C.', event: 'A escrita cuneiforme torna-se completamente fonetizada e capaz de registrar literatura e leis.' }
      ],
      characters: [
        { name: 'Enmerkar', role: 'Rei Lendário de Uruk', bio: 'Segundo a Epopeia de Enmerkar, ele teria inventado a escrita em tabuleta pois seu mensageiro estava com a boca pesada e incapaz de repetir o discurso.' },
        { name: 'Denise Schmandt-Besserat', role: 'Arqueóloga e Historiadora', bio: 'Pioneira no estudo dos sistemas de contabilidade neolíticos e na decifração da origem física da escrita cuneiforme.' }
      ],
      sources: [
        { id: 'src-sum-1', title: 'Before Writing: From Counting to Cuneiform', author: 'Denise Schmandt-Besserat', year: 1992, type: 'book', details: 'Volume I, University of Texas Press' },
        { id: 'src-sum-2', title: 'Archaic Bookkeeping: Writing and Techniques of Economic Administration', author: 'Hans J. Nissen', year: 1993, type: 'book', details: 'Cap. II, pág. 11-35' }
      ]
    },
    {
      id: 'grecia-classica',
      category: 'História',
      period: 'Antiguidade',
      title: 'O Florescimento da Democracia e Filosofia em Atenas (c. 500 a.C.)',
      era: 'Antiguidade Clássica (c. 500 a.C.)',
      evidenceLevel: 'high',
      summary: 'As reformas democráticas de Clístenes e a consolidação do pensamento filosófico e das artes cênicas na Atenas clássica.',
      fact: {
        title: 'As Reformas de Clístenes (508 a.C.)',
        description: 'Clístenes reorganizou a população de Atenas em dez tribos baseadas em distritos geográficos (demos) em vez de linhagens familiares, fundando a Eclésia e o Conselho dos 500 (Bulé), estabelecendo a isonomia (igualdade perante a lei) documentada em inscrições de pedra.'
      },
      interpretation: {
        title: 'O Caráter de Classe da Democracia Ateniense',
        description: 'Historiadores políticos debatem as limitações estruturais da democracia grega. Enquanto os liberais clássicos a celebravam como liberdade pura, críticos contemporâneos demonstram que ela dependia diretamente da escravidão de massa de prisioneiros estrangeiros e da exclusão total das mulheres da esfera política.'
      },
      hypothesis: {
        title: 'A Influência Egípcia na Filosofia Pré-Socrática',
        description: 'Embora a filosofia seja descrita tradicionalmente como um "milagre grego" autônomo, hipóteses revisionistas sugerem forte herança de conhecimentos geométricos e cosmológicos adquiridos por Tales e Pitágoras em viagens aos templos do Baixo Egito.'
      },
      timeline: [
        { year: '508 a.C.', event: 'Clístenes assume o poder e institui a reorganização política democrática de Atenas.' },
        { year: '490 a.C.', event: 'Batalha de Maratona; forças atenienses derrotam a invasão persa de Dario I, salvaguardando a polis.' },
        { year: '461 a.C.', event: 'Início da Era de Péricles; financiamento estatal de teatros, templos no Acrópole e assembleias populares.' }
      ],
      characters: [
        { name: 'Clístenes', role: 'Pai da Democracia', bio: 'Aristocrata reformador que quebrou o poder dos clãs tradicionais atenientes e introduziu o sufrágio geográfico.' },
        { name: 'Sexto Empírico', role: 'Historiador e Filósofo', bio: 'Registrou compilações de debates céticos e das correntes metodológicas que definiam as discussões na ágora.' }
      ],
      sources: [
        { id: 'src-gre-1', title: 'A Constituição dos Atenienses', author: 'Atribuído a Aristóteles', year: -320, type: 'document', details: 'Seções 20-22, Papiros de Londres' },
        { id: 'src-gre-2', title: 'The Ancient Greeks: An Introduction', author: 'John V. A. Fine', year: 1983, type: 'book', details: 'Capítulo 9' }
      ]
    },
    {
      id: 'revolucao-francesa',
      category: 'História',
      period: 'Idade Moderna',
      title: 'A Revolução Francesa e a Queda da Bastilha (1789)',
      era: 'Idade Moderna (1789)',
      evidenceLevel: 'high',
      summary: 'O levante popular de 14 de julho de 1789 em Paris que desmantelou o absolutismo Bourbon e promulgou a Declaração dos Direitos do Homem.',
      fact: {
        title: 'A Tomada da Bastilha',
        description: 'Em 14 de julho de 1789, uma multidão armada cercou e tomou a prisão-fortaleza da Bastilha, buscando pólvora e libertando prisioneiros simbólicos. Os relatórios oficiais do governador de Launay e os diários reais de Luís XVI registram o colapso imediato da autoridade real na capital.'
      },
      interpretation: {
        title: 'A Tese Revisionista de François Furet',
        description: 'Divergindo da visão marxista clássica (uma revolução burguesa linear), François Furet e historiadores revisionistas argumentam que 1789 foi um colapso democrático onde a política discursiva e a retórica de soberania popular substituíram os conflitos de classe estruturais de curto prazo.'
      },
      hypothesis: {
        title: 'O Impacto Climático e a Erupção do Laki',
        description: 'Pesquisadores de paleoclima levantam a hipótese de que a erupção do vulcão Laki na Islândia em 1783 causou perturbações atmosféricas globais, provocando invernos rigorosos e quebras de safra sucessivas na França, catalisando a fome extrema que motivou a revolta camponesa.'
      },
      timeline: [
        { year: '1789', event: 'Reunião dos Estados Gerais; o Terceiro Estado se autoproclama Assembleia Nacional.' },
        { year: '1789', event: 'Queda da Bastilha em 14 de julho; promulgação da Declaração dos Direitos do Homem em agosto.' },
        { year: '1793', event: 'Execução do rei Luís XVI e início do período do Terror jacobino liderado por Robespierre.' }
      ],
      characters: [
        { name: 'Luís XVI', role: 'Rei de França', bio: 'Monarca absolutista deposto cuja indecisão política e crise fiscal culminaram no colapso do Antigo Regime.' },
        { name: 'Maximilien Robespierre', role: 'Líder Jacobino', bio: 'Advogado e político radical que personificou a fase mais violenta e virtuosa da Revolução Francesa.' }
      ],
      sources: [
        { id: 'src-rev-1', title: 'Pensar a Revolução Francesa', author: 'François Furet', year: 1978, type: 'book', details: 'Edição Gallimard, Páginas 45-80' },
        { id: 'src-rev-2', title: 'The French Revolution: A History', author: 'Thomas Carlyle', year: 1837, type: 'book', details: 'Volume I, Cap. III' }
      ]
    },
    {
      id: 'pouso-lua',
      category: 'História',
      period: 'Idade Moderna',
      title: 'A Apollo 11 e o Pouso Lunar da Humanidade (1969)',
      era: 'Idade Contemporânea (1969)',
      evidenceLevel: 'high',
      summary: 'A alunissagem histórica do Módulo Lunar Eagle na Lua, consolidando o apogeu tecnológico da corrida espacial durante a Guerra Fria.',
      fact: {
        title: 'A Alunissagem no Mar da Tranquilidade',
        description: 'Em 20 de julho de 1969, Neil Armstrong e Buzz Aldrin pousaram o módulo lunar "Eagle" na Lua. A missão foi transmitida ao vivo para 600 milhões de telespectadores e é documentada por mais de 400 kg de amostras de rocha lunar coletadas, registros de rádio da NASA e refletores laser deixados na superfície.'
      },
      interpretation: {
        title: 'A Corrida Espacial como Substituto de Guerra',
        description: 'Historiadores de relações internacionais interpretam o programa Apollo não puramente como aventura científica, mas como uma guerra de propaganda substituta crucial entre as duas superpotências nucleares (EUA e URSS) para demonstrar superioridade ideológica.'
      },
      hypothesis: {
        title: 'Teorias de Conspiração de Fraude Lunar',
        description: 'Apesar de refutadas de forma absoluta por evidências físicas, científicas e historiográficas, hipóteses marginais sugerem que o pouso foi filmado em estúdio de cinema pelo diretor Stanley Kubrick a mando do governo americano.'
      },
      timeline: [
        { year: '1961', event: 'O presidente John F. Kennedy declara a meta de enviar um homem à Lua antes do fim da década.' },
        { year: '1969', event: 'Lançamento do Saturno V em 16 de julho; pouso lunar e caminhada histórica em 20 de julho.' },
        { year: '1972', event: 'A missão Apollo 17 encerra o programa de exploração lunar tripulado da NASA.' }
      ],
      characters: [
        { name: 'Neil Armstrong', role: 'Comandante da Apollo 11', bio: 'Primeiro ser humano a caminhar na Lua, eternizado pela frase "um pequeno passo para um homem, um salto gigante para a humanidade".' },
        { name: 'Wernher von Braun', role: 'Diretor Técnico da NASA', bio: 'Pioneiro da engenharia de foguetes alemã, projetista chefe do colossal foguete lançador Saturno V.' }
      ],
      sources: [
        { id: 'src-lua-1', title: 'First Man: The Life of Neil A. Armstrong', author: 'James R. Hansen', year: 2005, type: 'book', details: 'Capítulo 18, Simon & Schuster' },
        { id: 'src-lua-2', title: 'Apollo 11 Mission Report', author: 'NASA Science Directorate', year: 1969, type: 'document', details: 'Documento Técnico MSC-00171' }
      ]
    }
  ];

  const handleMasterCard = (id: string, xpEarned: number) => {
    if (!masteredCards.includes(id)) {
      setMasteredCards((prev) => [...prev, id]);
      setUserState((prev) => {
        const nextXp = prev.xp + xpEarned;
        const nextLevel = Math.floor(nextXp / 150) + 1;
        return {
          ...prev,
          xp: nextXp,
          level: nextLevel,
          streak: prev.streak + 1
        };
      });
    }
  };

  const periods = ['Todos', 'Antiguidade', 'Idade Média', 'Idade Moderna'];

  const filteredCards = mockCards.filter((card) => {
    const matchesPeriod = activePeriod === 'Todos' || card.period === activePeriod;
    const matchesSearch =
      card.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      card.summary.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesPeriod && matchesSearch;
  });

  // Calculate saved sources count based on user interaction (each card has multiple sources)
  const savedSourcesCount = masteredCards.length * 2 || 1;

  // Get nodes for current timeline step dynamically from CKE
  const stepNodes = (() => {
    const all = kgEngine.getAllNodes();
    const step = TIMELINE_STEPS[currentTimelineIndex];
    if (step.id === 'sumeria') {
      return all.filter(n => n.id === 'civ-sumeria' || n.id === 'tech-cuneiforme' || n.id === 'doc-hamurabi');
    }
    if (step.id === 'grecia-classica') {
      // Find nodes with Greek connection, or return general mythological / classic nodes
      const filtered = all.filter(n => 
        n.id.includes('grecia') || 
        n.id.includes('atena') || 
        n.tags.some(t => t.toLowerCase().includes('greg') || t.toLowerCase().includes('clássico')) ||
        n.keywords.some(k => k.toLowerCase().includes('greg') || k.toLowerCase().includes('atena'))
      );
      return filtered.length > 0 ? filtered : all.filter(n => n.evidenceLevel === 'mythological').slice(0, 3);
    }
    if (step.id === 'roma-republica') {
      return all.filter(n => 
        n.id === 'char-cesar' || 
        n.id === 'char-pompeu' || 
        n.id === 'evt-rubicao' || 
        n.id === 'war-guerra-civil-roma' || 
        n.id === 'book-bello-gallico' || 
        n.id === 'civ-roma' || 
        n.id === 'city-roma' || 
        n.id === 'char-cleopatra' || 
        n.id === 'city-alexandria' || 
        n.id === 'const-biblioteca-alexandria' || 
        n.id === 'myth-romana' || 
        n.id === 'god-jupiter'
      );
    }
    if (step.id === 'queda-roma') {
      return all.filter(n => n.id === 'evt-queda-roma' || n.id === 'char-romulo-augusto' || n.id === 'imp-bizantino');
    }
    if (step.id === 'tordesilhas') {
      return all.filter(n => n.id === 'evt-descobrimento-america' || n.id === 'doc-tordesilhas');
    }
    if (step.id === 'revolucao-francesa') {
      return all.filter(n => n.id === 'char-montesquieu' || n.id === 'evt-bastilha' || n.id === 'evt-inconfidencia');
    }
    if (step.id === 'pouso-lua') {
      return all.filter(n => n.id === 'evt-pouso-lua');
    }
    return [];
  })();

  // Navigate to any node and snap the timeline to its closest historical period
  const handleNavigateToNode = (id: string) => {
    setSelectedNodeDetailsId(id);
    const node = kgEngine.getNode(id);
    if (node) {
      // Find the timeline step that is closest to this node's year
      const nodeYear = kgEngine['parseEraToComparableYear'](node.era);
      let closestIdx = 0;
      let minDiff = Infinity;
      TIMELINE_STEPS.forEach((step, idx) => {
        const diff = Math.abs(step.year - nodeYear);
        if (diff < minDiff) {
          minDiff = diff;
          closestIdx = idx;
        }
      });
      setCurrentTimelineIndex(closestIdx);
    }
  };

  return (
    <div id="main-view-layout" className="min-h-screen bg-slate-50 text-slate-850 pb-24 font-sans antialiased">
      {/* Dynamic Header */}
      <header id="main-header" className="sticky top-0 bg-white/95 backdrop-blur-md border-b border-slate-200/60 px-6 py-4.5 z-30 shadow-xs">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-xl bg-slate-900 text-amber-400 flex items-center justify-center font-serif font-bold text-xl shadow-xs border border-slate-800">
              C
            </div>
            <div>
              <span className="font-serif font-extrabold text-base text-slate-950 block leading-tight tracking-wider">CHRONOS</span>
              <span className="text-[9px] font-mono tracking-widest text-amber-600 uppercase font-semibold">Conhecimento através do tempo</span>
            </div>
          </div>

          {/* Core Academic Progression Indicators */}
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 bg-amber-50/50 px-3 py-1.5 rounded-full border border-amber-200/40 text-amber-900 shadow-3xs" title="Dias seguidos de atividade">
              <Flame className="w-4 h-4 text-amber-500 fill-current animate-pulse" />
              <span className="font-mono text-xs font-bold">{userState.streak} d</span>
            </div>

            <div className="flex items-center gap-1.5 bg-slate-900 px-3 py-1.5 rounded-full text-white shadow-3xs" title="Nível acadêmico atual">
              <BookOpen className="w-3.5 h-3.5 text-amber-400" />
              <span className="font-mono text-xs font-bold">Nível {userState.level}</span>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="max-w-4xl mx-auto px-6 py-6">
        {/* TAB: HOME */}
        {activeTab === 'home' && (
          <div id="tab-home" className="space-y-8 animate-fade-in">
            {viewingDossier ? (
              /* THE IMMERSIVE HISTORICAL DOSSIER SCREEN (ERA DETAILS) */
              <div className="space-y-6">
                {/* Back bar */}
                <div className="flex items-center justify-between">
                  <button
                    onClick={() => {
                      setViewingDossier(false);
                    }}
                    className="inline-flex items-center gap-1.5 text-xs font-mono font-bold uppercase tracking-wider text-slate-600 hover:text-amber-800 transition-all bg-white hover:bg-slate-50 px-4 py-2 rounded-xl border border-slate-200 shadow-3xs cursor-pointer"
                  >
                    <ChevronLeft className="w-4 h-4 text-slate-500" />
                    <span>Voltar à Corrente do Tempo</span>
                  </button>

                  <div className="text-right">
                    <span className="text-[10px] font-mono font-bold text-amber-800 uppercase tracking-widest bg-amber-50 px-2.5 py-1 rounded-full border border-amber-200/30">
                      {TIMELINE_STEPS[currentTimelineIndex].era}
                    </span>
                  </div>
                </div>

                {/* Big Title of the Entered Era */}
                <div className="bg-slate-900 rounded-2xl p-6 text-white shadow-md relative overflow-hidden border border-slate-800">
                  <div className="absolute right-0 bottom-0 top-0 w-1/4 bg-gradient-to-l from-amber-500/10 to-transparent pointer-events-none" />
                  <span className="text-amber-400 font-mono text-[9px] uppercase tracking-widest font-bold">Investigação Histórica Ativa</span>
                  <h2 className="text-2xl sm:text-3xl font-serif font-bold text-amber-50 mt-1">
                    Dossiê: {TIMELINE_STEPS[currentTimelineIndex].title} ({TIMELINE_STEPS[currentTimelineIndex].label})
                  </h2>
                  <p className="text-slate-300 text-xs sm:text-sm font-serif mt-2 leading-relaxed">
                    {TIMELINE_STEPS[currentTimelineIndex].description}
                  </p>
                </div>

                {/* ConceptCard or fallback */}
                {(() => {
                  const currentStep = TIMELINE_STEPS[currentTimelineIndex];
                  let cardId = currentStep.id;
                  if (currentStep.id === 'roma-republica') cardId = 'alexandria';
                  const card = mockCards.find(c => c.id === cardId);
                  if (card) {
                    return (
                      <ConceptCard
                        card={card}
                        isMastered={masteredCards.includes(card.id)}
                        onMasterCard={handleMasterCard}
                      />
                    );
                  }
                  return (
                    <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center flex flex-col items-center justify-center min-h-[300px]">
                      <AlertCircle className="w-10 h-10 text-slate-300 mb-2" />
                      <p className="text-slate-500 text-sm font-serif">Dossiê de investigação indisponível para esta era.</p>
                    </div>
                  );
                })()}

                {/* "ENQUANTO ISSO NO MUNDO..." PANEL ALSO SHOWN INSIDE DOSSIER FOR CONTEXT! */}
                <div className="bg-amber-500/[0.01] border-2 border-amber-500/10 rounded-2xl p-6 shadow-3xs space-y-5">
                  <div className="flex items-center gap-2 border-b border-amber-500/10 pb-3">
                    <Globe className="w-5 h-5 text-amber-700" />
                    <div>
                      <h3 className="text-base font-serif font-bold text-slate-900 leading-tight">Contexto Global Simultâneo</h3>
                      <span className="text-[9px] font-mono text-slate-400 uppercase">Enquanto isso em outras regiões...</span>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {TIMELINE_STEPS[currentTimelineIndex].meanwhile.map((item, idx) => (
                      <div key={idx} className="p-4 bg-white border border-slate-200/80 rounded-xl space-y-1.5 shadow-3xs hover:shadow-2xs transition-all border-l-4 border-l-amber-600">
                        <span className="text-[9px] font-mono uppercase text-amber-800 tracking-wider font-extrabold">
                          {item.region}
                        </span>
                        <p className="text-xs text-slate-600 font-serif leading-relaxed">
                          {item.event}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ) : (
              /* THE TIMELINE VIEW STREAM */
              <>
                {/* Elegant Welcome Header & Progress */}
                <div className="bg-slate-900 rounded-2xl p-6 text-white shadow-md relative overflow-hidden border border-slate-800">
                  <div className="absolute right-0 bottom-0 top-0 w-1/4 bg-gradient-to-l from-amber-500/10 to-transparent pointer-events-none" />
                  <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                      <span className="text-amber-400 font-mono text-[9px] uppercase tracking-widest font-bold">Motor de Conhecimento CHRONOS</span>
                      <h2 className="text-xl sm:text-2xl font-serif font-bold text-amber-50 mt-0.5">
                        Bem-vindo ao CHRONOS, {userState.name}
                      </h2>
                      <p className="text-slate-300 text-xs sm:text-sm font-serif mt-1">
                        Viaje interativamente através do tempo guiado por evidências acadêmicas rigorosas.
                      </p>
                    </div>
                <div className="bg-slate-800/80 p-3 rounded-xl border border-slate-700 shrink-0 text-center md:text-right">
                  <span className="text-[9px] font-mono uppercase text-slate-400 block font-semibold">Investigações Consolidadas</span>
                  <span className="text-base font-mono font-bold text-amber-400">{masteredCards.length} / {mockCards.length} Temas</span>
                </div>
              </div>
            </div>

            {/* THE INFINITE TIMELINE NAVIGATION (HEART OF THE APP) */}
            <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-xs space-y-6">
              <div className="flex items-center justify-between border-b border-slate-100 pb-3">
                <div className="flex items-center gap-2">
                  <Calendar className="w-5 h-5 text-amber-600" />
                  <h3 className="text-base font-serif font-bold text-slate-900">Linha do Tempo Infinita</h3>
                </div>
                <span className="text-[10px] font-mono text-slate-400 tracking-wider">Deslize ou clique para viajar</span>
              </div>

              {/* Horizontally Scrollable Timeline Track */}
              <div className="relative py-4 px-2 bg-slate-50 rounded-xl border border-slate-100 overflow-hidden">
                <div className="absolute left-0 right-0 top-1/2 -translate-y-1/2 h-1 bg-slate-200 pointer-events-none z-0" />
                
                {/* Active range progress bar highlight */}
                <div 
                  className="absolute left-0 top-1/2 -translate-y-1/2 h-1 bg-amber-500 transition-all duration-500 ease-out pointer-events-none z-0"
                  style={{ 
                    left: '8%',
                    width: `${(currentTimelineIndex / (TIMELINE_STEPS.length - 1)) * 84}%` 
                  }}
                />

                <div className="flex justify-between items-center relative z-10 gap-2 overflow-x-auto scrollbar-none py-1">
                  {TIMELINE_STEPS.map((step, idx) => {
                    const isActive = currentTimelineIndex === idx;
                    return (
                      <button
                        key={step.id}
                        onClick={() => {
                          setCurrentTimelineIndex(idx);
                          setSelectedNodeDetailsId(null);
                        }}
                        className={`flex flex-col items-center gap-1.5 focus:outline-none transition-all group px-3.5 py-2.5 rounded-xl shrink-0 ${
                          isActive 
                            ? 'bg-slate-900 text-white scale-105 shadow-3xs border border-slate-800' 
                            : 'hover:bg-slate-200/50 text-slate-500'
                        }`}
                      >
                        <span className={`text-[10px] font-mono font-bold tracking-tight uppercase ${isActive ? 'text-amber-400' : 'text-slate-400 group-hover:text-slate-800'}`}>
                          {step.label}
                        </span>
                        <div className={`w-3.5 h-3.5 rounded-full border-2 transition-all flex items-center justify-center ${
                          isActive 
                            ? 'bg-amber-400 border-white' 
                            : 'bg-white border-slate-300 group-hover:border-slate-500'
                        }`}>
                          {isActive && <div className="w-1.5 h-1.5 bg-slate-900 rounded-full" />}
                        </div>
                        <span className="text-[9px] font-serif font-medium line-clamp-1 max-w-[80px] text-center opacity-80">
                          {step.title}
                        </span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Prev/Next timeline controls */}
              <div className="flex justify-between items-center gap-4 bg-slate-50/50 p-2.5 rounded-xl border border-slate-200/50">
                <button
                  disabled={currentTimelineIndex === 0}
                  onClick={() => {
                    if (currentTimelineIndex > 0) {
                      setCurrentTimelineIndex(prev => prev - 1);
                      setSelectedNodeDetailsId(null);
                    }
                  }}
                  className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-xs font-mono font-bold uppercase text-slate-600 disabled:opacity-40 transition-all cursor-pointer"
                >
                  <ChevronLeft className="w-4 h-4" />
                  <span>Voltar Era</span>
                </button>
                <div className="text-center">
                  <span className="text-[10px] font-mono font-bold text-amber-800 uppercase tracking-widest bg-amber-50 px-2.5 py-1 rounded-full border border-amber-200/30">
                    {TIMELINE_STEPS[currentTimelineIndex].era}
                  </span>
                </div>
                <button
                  disabled={currentTimelineIndex === TIMELINE_STEPS.length - 1}
                  onClick={() => {
                    if (currentTimelineIndex < TIMELINE_STEPS.length - 1) {
                      setCurrentTimelineIndex(prev => prev + 1);
                      setSelectedNodeDetailsId(null);
                    }
                  }}
                  className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-xs font-mono font-bold uppercase text-slate-600 disabled:opacity-40 transition-all cursor-pointer"
                >
                  <span>Avançar Era</span>
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>

              {/* Stop Year Epoch Presentation */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-2">
                <div className="md:col-span-2 space-y-3">
                  <div className="flex items-baseline gap-2.5">
                    <span className="text-3xl font-mono font-extrabold tracking-tight text-slate-900">
                      {TIMELINE_STEPS[currentTimelineIndex].label}
                    </span>
                    <span className="text-lg font-serif font-bold text-slate-800">
                      • {TIMELINE_STEPS[currentTimelineIndex].title}
                    </span>
                  </div>
                  <p className="text-xs sm:text-sm text-slate-600 font-serif leading-relaxed">
                    {TIMELINE_STEPS[currentTimelineIndex].description}
                  </p>
                  
                  {onEnterEpoch && (
                    <button
                      id="enter-epoch-btn"
                      onClick={() => onEnterEpoch(TIMELINE_STEPS[currentTimelineIndex].year)}
                      className="inline-flex items-center gap-2 mt-2 px-4 py-2 bg-gradient-to-r from-amber-600 to-amber-500 hover:from-amber-500 hover:to-amber-400 active:scale-[0.98] text-white rounded-xl shadow-md font-mono text-xs uppercase tracking-wider font-bold transition-all border border-amber-400/40 cursor-pointer"
                    >
                      <Compass className="w-3.5 h-3.5 animate-spin [animation-duration:8s]" />
                      <span>Entrar nesta Época</span>
                    </button>
                  )}
                </div>

                {/* Conceptual Period Map Panel */}
                <div className="md:col-span-1 bg-slate-50 border border-slate-200 rounded-xl overflow-hidden shadow-3xs flex flex-col justify-between">
                  <div className="p-3 border-b border-slate-200 bg-white flex items-center gap-1.5">
                    <Map className="w-4 h-4 text-slate-500" />
                    <span className="text-[10px] font-mono uppercase tracking-wider text-slate-500 font-bold">Mapa Conceitual do Teatro</span>
                  </div>
                  <div className="relative h-24 bg-slate-200">
                    <img 
                      src={TIMELINE_STEPS[currentTimelineIndex].mapUrl} 
                      alt="Mapa histórico conceitual" 
                      referrerPolicy="no-referrer"
                      className="w-full h-full object-cover grayscale opacity-80" 
                    />
                    <div className="absolute inset-0 bg-slate-900/35 flex items-center justify-center p-2">
                      <span className="text-[10px] font-sans font-extrabold tracking-wider text-white uppercase text-center bg-slate-950/85 px-2 py-1 rounded border border-slate-700">
                        {TIMELINE_STEPS[currentTimelineIndex].mapLabel}
                      </span>
                    </div>
                  </div>
                  <div className="p-2.5 bg-white text-center">
                    <span className="text-[8px] font-mono text-slate-400 uppercase tracking-widest block font-semibold">Coordenadas Geográficas Ativas</span>
                  </div>
                </div>
              </div>
            </div>

            {/* DYNAMIC CHRONOS KNOWLEDGE GRAPH DISCOVERED ENTITIES GRID */}
            <div className="space-y-4">
              <div className="flex items-center justify-between border-b border-slate-200 pb-2">
                <span className="text-xs font-mono font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                  <Database className="w-4 h-4" />
                  <span>Entidades Relevantes Mapeadas ({stepNodes.length})</span>
                </span>
                <span className="text-[9px] font-mono text-slate-400 uppercase">Consultando CKE v1.1</span>
              </div>

              {stepNodes.length > 0 ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                  {stepNodes.map((node) => {
                    const isMyth = node.evidenceLevel === 'mythological';
                    return (
                      <button
                        key={node.id}
                        onClick={() => setSelectedNodeDetailsId(node.id)}
                        className={`w-full text-left p-4 rounded-xl border bg-white shadow-3xs hover:shadow-2xs hover:border-amber-500 hover:bg-slate-50/30 transition-all flex flex-col justify-between min-h-[140px] group cursor-pointer ${
                          isMyth ? 'border-amber-200/60 bg-amber-500/[0.005]' : 'border-slate-200'
                        }`}
                      >
                        <div className="w-full">
                          <div className="flex justify-between items-start w-full gap-2">
                            <span className="text-[8px] font-mono font-bold uppercase bg-slate-100 text-slate-500 px-1.5 py-0.5 rounded border border-slate-200/50">
                              {ENTITY_TYPE_TRANSLATIONS[node.type] || node.type}
                            </span>
                            <span className={`text-[7px] font-mono uppercase tracking-widest font-extrabold px-1.5 py-0.5 rounded border ${
                              node.evidenceLevel === 'high' ? 'bg-emerald-50 text-emerald-800 border-emerald-100' :
                              node.evidenceLevel === 'good' ? 'bg-blue-50 text-blue-800 border-blue-100' :
                              node.evidenceLevel === 'debate' ? 'bg-amber-50 text-amber-800 border-amber-100' :
                              node.evidenceLevel === 'hypothesis' ? 'bg-rose-50 text-rose-800 border-rose-100' :
                              'bg-amber-50 text-amber-900 border-amber-200'
                            }`}>
                              {node.evidenceLevel === 'mythological' ? 'Mito' : node.evidenceLevel.toUpperCase()}
                            </span>
                          </div>
                          <h4 className="font-serif font-bold text-slate-900 text-sm mt-3 group-hover:text-amber-800 transition-colors line-clamp-1">{node.name}</h4>
                          <p className="text-slate-400 text-[10px] font-mono mt-1.5 leading-tight line-clamp-2 italic">"{node.summary}"</p>
                        </div>
                        <div className="mt-3 flex items-center justify-between text-[8px] font-mono text-slate-400 group-hover:text-amber-800 border-t border-slate-100 pt-2 w-full">
                          <span>INSPECIONAR DADOS</span>
                          <ArrowRight className="w-3 h-3 transition-transform group-hover:translate-x-1" />
                        </div>
                      </button>
                    );
                  })}
                </div>
              ) : (
                <div className="bg-white border border-slate-200 rounded-xl p-8 text-center">
                  <p className="text-slate-400 text-xs font-serif italic">Nenhuma entidade catalogada diretamente neste ponto de ancoragem.</p>
                </div>
              )}
            </div>

            {/* DYNAMIC DETAILED INSPECTOR PANEL OVERLAY */}
            <AnimatePresence>
              {selectedNodeDetailsId && (() => {
                const node = kgEngine.getNode(selectedNodeDetailsId);
                if (!node) return null;
                const neighbors = kgEngine.getNeighbors(node.id);
                const isMythological = node.evidenceLevel === 'mythological';
                return (
                  <motion.div
                    initial={{ opacity: 0, y: 15 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: 15 }}
                    className="bg-slate-900 text-white rounded-2xl p-6 border border-slate-800 shadow-md space-y-6 relative overflow-hidden"
                  >
                    <div className="absolute right-0 top-0 w-48 h-48 bg-amber-500/[0.02] rounded-full blur-3xl pointer-events-none" />
                    
                    {/* Inspector Header */}
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-slate-800 pb-4">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="text-[8px] font-mono font-extrabold uppercase px-2 py-0.5 bg-amber-500/10 text-amber-300 border border-amber-500/20 rounded-full tracking-wider">
                            {ENTITY_TYPE_TRANSLATIONS[node.type] || node.type}
                          </span>
                          <span className="text-[9px] font-mono text-slate-400">{node.era}</span>
                        </div>
                        <h3 className="text-xl font-serif font-bold text-amber-50 mt-1">{node.name}</h3>
                      </div>
                      <div className="flex flex-col items-start sm:items-end">
                        <span className="text-[8px] font-mono uppercase tracking-widest text-slate-400">Rigor de Evidência Científica</span>
                        <span className={`text-[9px] font-mono font-bold uppercase tracking-wider px-2.5 py-0.5 rounded border mt-0.5 ${
                          node.evidenceLevel === 'high' ? 'bg-emerald-950/80 text-emerald-300 border-emerald-800' :
                          node.evidenceLevel === 'good' ? 'bg-blue-950/80 text-blue-300 border-blue-800' :
                          node.evidenceLevel === 'debate' ? 'bg-amber-950/80 text-amber-300 border-amber-800' :
                          node.evidenceLevel === 'hypothesis' ? 'bg-rose-950/80 text-rose-300 border-rose-800' :
                          'bg-amber-900/40 text-amber-200 border-amber-700/80'
                        }`}>
                          {node.evidenceLevel === 'mythological' ? 'Estudo Temático e Mitologia' : node.evidenceLevel.toUpperCase()}
                        </span>
                      </div>
                    </div>

                    {/* Scientific details */}
                    <div className="space-y-4">
                      <div className="p-3 bg-slate-950 rounded-xl border border-slate-850 font-serif text-xs leading-relaxed italic text-slate-300">
                        "{node.summary}"
                      </div>
                      <div className="space-y-1.5">
                        <span className="text-[8px] font-mono font-bold text-slate-400 uppercase tracking-widest">Descrição Historiográfica Detalhada</span>
                        <p className="text-xs text-slate-300 font-serif leading-relaxed">
                          {node.description}
                        </p>
                      </div>
                      {node.justification && (
                        <div className="space-y-1.5 p-3.5 bg-amber-500/[0.02] rounded-xl border border-amber-500/10">
                          <span className="text-[8px] font-mono font-bold text-amber-400 uppercase tracking-widest">Fundamentação e Nível de Consenso</span>
                          <p className="text-xs text-slate-300 font-serif leading-relaxed">
                            {node.justification}
                          </p>
                        </div>
                      )}
                    </div>

                    {/* Interactive Relationships network */}
                    <div className="space-y-3">
                      <span className="text-[8px] font-mono font-bold text-slate-400 uppercase tracking-widest block">Relacionamentos Ativos no Grafo (Clique para viajar)</span>
                      {neighbors.length > 0 ? (
                        <div className="flex flex-wrap gap-2">
                          {neighbors.map((n, idx) => (
                            <button
                              key={idx}
                              onClick={() => handleNavigateToNode(n.node.id)}
                              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-slate-800 bg-slate-950 hover:border-amber-500 transition-all text-xs text-slate-300 shadow-3xs group text-left cursor-pointer"
                            >
                              <span className="text-amber-400 font-semibold uppercase text-[7px] font-mono bg-slate-900 px-1.5 py-0.5 rounded border border-slate-800">
                                {RELATIONSHIP_TYPE_TRANSLATIONS[n.relationship.type] || n.relationship.type}
                              </span>
                              <span>{n.direction === 'outgoing' ? '→' : '←'}</span>
                              <strong className="font-serif text-white group-hover:text-amber-300">{n.node.name}</strong>
                            </button>
                          ))}
                        </div>
                      ) : (
                        <p className="text-slate-500 text-xs font-serif italic">Nenhum relacionamento mapeado para este nó.</p>
                      )}
                    </div>

                    {/* Sources listed inside Node */}
                    <div className="p-4 rounded-xl bg-slate-950 border border-slate-850 space-y-2.5">
                      <span className="text-[8px] font-mono font-bold text-slate-400 uppercase tracking-widest block">Fontes Bibliográficas Rastreáveis</span>
                      {node.sources && node.sources.length > 0 ? (
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {node.sources.map((s, idx) => (
                            <div key={idx} className="text-xs font-serif text-slate-300 border-l-2 border-amber-500/50 pl-3 py-1 bg-slate-900/40 rounded-r-lg p-2 border border-slate-800/20">
                              <strong className="text-white block text-[11px] truncate">{s.title}</strong>
                              <span className="text-slate-400 text-[10px] font-mono block mt-0.5">{s.author} ({s.year})</span>
                            </div>
                          ))}
                        </div>
                      ) : (
                        <p className="text-slate-500 text-[10px] font-serif italic">Aresta de relevância indireta/autointegrada.</p>
                      )}
                    </div>

                    <div className="flex justify-end pt-2">
                      <button
                        onClick={() => setSelectedNodeDetailsId(null)}
                        className="bg-slate-800 text-slate-300 hover:text-white px-4 py-2 rounded-xl text-xs font-mono font-bold uppercase transition-all border border-slate-700 hover:bg-slate-700 cursor-pointer"
                      >
                        Fechar Inspeção
                      </button>
                    </div>
                  </motion.div>
                );
              })()}
            </AnimatePresence>

            {/* "ENQUANTO ISSO NO MUNDO..." PANEL */}
            <div className="bg-amber-500/[0.01] border-2 border-amber-500/10 rounded-2xl p-6 shadow-3xs space-y-5">
              <div className="flex items-center gap-2 border-b border-amber-500/10 pb-3">
                <Globe className="w-5 h-5 text-amber-700" />
                <div>
                  <h3 className="text-base font-serif font-bold text-slate-900 leading-tight">Enquanto isso no mundo...</h3>
                  <span className="text-[9px] font-mono text-slate-400 uppercase">Visão Histórica Simultânea e Global</span>
                </div>
              </div>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {TIMELINE_STEPS[currentTimelineIndex].meanwhile.map((item, idx) => (
                  <div key={idx} className="p-4 bg-white border border-slate-200/80 rounded-xl space-y-1.5 shadow-3xs hover:shadow-2xs transition-all border-l-4 border-l-amber-600">
                    <span className="text-[9px] font-mono uppercase text-amber-800 tracking-wider font-extrabold">
                      {item.region}
                    </span>
                    <p className="text-xs text-slate-600 font-serif leading-relaxed">
                      {item.event}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            {/* INTEGRATED SEMANTIC CONNECTION EXPLORER */}
            <div className="bg-slate-900 text-white rounded-2xl p-6 border border-slate-800 relative overflow-hidden shadow-md space-y-6">
              <div className="absolute right-0 top-0 w-32 h-32 bg-amber-500/[0.04] rounded-full blur-2xl pointer-events-none" />
              
              <div className="flex items-center gap-2">
                <div className="p-1.5 rounded-lg bg-amber-500/10 text-amber-400 border border-amber-500/20">
                  <GitBranch className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-base font-serif font-bold text-amber-100 leading-tight">Explorador de Conexões Semânticas</h3>
                  <span className="text-[9px] font-mono text-slate-400 uppercase block mt-0.5 font-bold">Mapeamento de nexos causais históricos</span>
                </div>
              </div>

              <p className="text-slate-400 text-xs font-serif leading-relaxed">
                Descubra conexões e relações entre quaisquer duas entidades históricas ou mitológicas da nossa base de dados. Escolha uma trilha recomendada ou selecione os nós de origem e destino abaixo.
              </p>

              {/* Preset Shortcuts */}
              <div className="space-y-2">
                <span className="text-[8px] font-mono uppercase tracking-widest text-slate-400 block font-semibold">Trilhas Recomendadas para Testar</span>
                <div className="flex flex-wrap gap-2">
                  <button
                    onClick={() => {
                      setPathStartId('char-montesquieu');
                      setPathEndId('evt-inconfidencia');
                      const path = kgEngine.findConnectionPath('char-montesquieu', 'evt-inconfidencia');
                      setPathResult(path);
                      setPathError(null);
                    }}
                    className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-750 text-[11px] font-serif text-slate-200 border border-slate-700/80 hover:border-amber-500/60 transition-all flex items-center gap-1 cursor-pointer"
                  >
                    🏛️ <strong className="font-sans font-medium text-amber-300">Relação de Poder:</strong> Montesquieu até Inconfidência Mineira
                  </button>
                  <button
                    onClick={() => {
                      setPathStartId('civ-sumeria');
                      setPathEndId('doc-hamurabi');
                      const path = kgEngine.findConnectionPath('civ-sumeria', 'doc-hamurabi');
                      setPathResult(path);
                      setPathError(null);
                    }}
                    className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-750 text-[11px] font-serif text-slate-200 border border-slate-700/80 hover:border-amber-500/60 transition-all flex items-center gap-1 cursor-pointer"
                  >
                    📖 <strong className="font-sans font-medium text-amber-300">Origem das Leis:</strong> Suméria até Cód. de Hamurabi
                  </button>
                  <button
                    onClick={() => {
                      setPathStartId('char-cesar');
                      setPathEndId('const-biblioteca-alexandria');
                      const path = kgEngine.findConnectionPath('char-cesar', 'const-biblioteca-alexandria');
                      setPathResult(path);
                      setPathError(null);
                    }}
                    className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-750 text-[11px] font-serif text-slate-200 border border-slate-700/80 hover:border-amber-500/60 transition-all flex items-center gap-1 cursor-pointer"
                  >
                    👑 <strong className="font-sans font-medium text-amber-300">Tríade do Nilo:</strong> Júlio César até Biblioteca Alexandria
                  </button>
                </div>
              </div>

              {/* Selector Inputs */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 items-end bg-slate-950 p-4 rounded-xl border border-slate-850">
                <div className="space-y-1.5">
                  <label className="text-[9px] font-mono text-slate-400 uppercase tracking-widest block font-semibold">Origem (Nó A)</label>
                  <select
                    value={pathStartId}
                    onChange={(e) => setPathStartId(e.target.value)}
                    className="block w-full bg-slate-900 border border-slate-850 text-slate-200 text-xs rounded-xl p-2.5 focus:outline-none focus:border-amber-500 font-serif"
                  >
                    {kgEngine.getAllNodes().map(n => (
                      <option key={n.id} value={n.id}>{n.name} ({ENTITY_TYPE_TRANSLATIONS[n.type] || n.type})</option>
                    ))}
                  </select>
                </div>

                <div className="space-y-1.5">
                  <label className="text-[9px] font-mono text-slate-400 uppercase tracking-widest block font-semibold">Destino (Nó B)</label>
                  <select
                    value={pathEndId}
                    onChange={(e) => setPathEndId(e.target.value)}
                    className="block w-full bg-slate-900 border border-slate-850 text-slate-200 text-xs rounded-xl p-2.5 focus:outline-none focus:border-amber-500 font-serif"
                  >
                    {kgEngine.getAllNodes().map(n => (
                      <option key={n.id} value={n.id}>{n.name} ({ENTITY_TYPE_TRANSLATIONS[n.type] || n.type})</option>
                    ))}
                  </select>
                </div>

                <button
                  onClick={() => {
                    if (pathStartId === pathEndId) {
                      setPathError("Por favor, selecione duas entidades diferentes.");
                      setPathResult(null);
                    } else {
                      const path = kgEngine.findConnectionPath(pathStartId, pathEndId);
                      if (path) {
                        setPathResult(path);
                        setPathError(null);
                      } else {
                        setPathResult(null);
                        setPathError("Nenhum caminho lógico pôde ser traçado até a profundidade máxima de 4 níveis de conexões.");
                      }
                    }
                  }}
                  className="bg-amber-500 text-slate-950 hover:bg-amber-400 px-4 py-2.5 rounded-xl text-xs font-mono font-bold uppercase tracking-wider transition-all shadow-xs h-10 flex items-center justify-center gap-2 cursor-pointer font-bold"
                >
                  <Cpu className="w-4 h-4" />
                  <span>Calcular Caminho</span>
                </button>
              </div>

              {/* Pathfinder Output */}
              <AnimatePresence mode="wait">
                {pathError && (
                  <motion.div
                    initial={{ opacity: 0, y: 5 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0 }}
                    className="bg-rose-500/10 border border-rose-500/30 p-3.5 rounded-xl text-xs text-rose-300 font-serif"
                  >
                    {pathError}
                  </motion.div>
                )}

                {pathResult && (
                  <motion.div
                    initial={{ opacity: 0, y: 5 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0 }}
                    className="bg-slate-950 border border-slate-850 p-5 rounded-xl space-y-4 shadow-inner"
                  >
                    <span className="text-[9px] font-mono font-bold text-amber-500 uppercase tracking-widest block font-bold">Cadeia de Relações Tracada por Algoritmo Semântico</span>
                    
                    <div className="flex flex-col md:flex-row md:items-center gap-4 flex-wrap justify-center py-2">
                      {pathResult.map((step, stepIdx) => {
                        const nodeColor = step.node.evidenceLevel === 'mythological' 
                          ? 'border-amber-500/40 text-amber-300 bg-amber-500/5 hover:border-amber-400' 
                          : 'border-slate-700 text-slate-100 bg-slate-900 hover:border-amber-500';

                        return (
                          <div key={stepIdx} className="flex flex-col md:flex-row md:items-center gap-4">
                            {/* Entity Node */}
                            <button 
                              onClick={() => handleNavigateToNode(step.node.id)}
                              className={`px-4 py-3 rounded-xl border text-center font-serif flex flex-col justify-center max-w-xs transition-all hover:bg-slate-800 cursor-pointer ${nodeColor}`}
                            >
                              <span className="text-[7px] font-mono uppercase text-slate-400 tracking-wider mb-0.5">{ENTITY_TYPE_TRANSLATIONS[step.node.type] || step.node.type}</span>
                              <strong className="text-xs block">{step.node.name}</strong>
                              <span className="text-[8px] font-mono text-slate-400 mt-1 uppercase tracking-wider">{step.node.era}</span>
                            </button>

                            {/* Directed Relationship Link Edge */}
                            {stepIdx < pathResult.length - 1 && pathResult[stepIdx + 1]?.relationship && (
                              <div className="flex flex-row md:flex-col items-center justify-center gap-2">
                                <div className="h-0.5 w-8 bg-slate-700 hidden md:block" />
                                <span className="text-[8px] font-mono uppercase text-amber-400/80 tracking-widest bg-slate-900 px-2 py-0.5 rounded border border-slate-800 text-center">
                                  {RELATIONSHIP_TYPE_TRANSLATIONS[pathResult[stepIdx + 1].relationship?.type || ''] || pathResult[stepIdx + 1].relationship?.type}
                                </span>
                                <div className="h-0.5 w-8 bg-slate-700 hidden md:block" />
                                {/* Mobile/vertical indicator arrow */}
                                <span className="text-slate-500 block md:hidden text-lg">↓</span>
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>

                    <div className="bg-slate-900 p-3 rounded-lg border border-slate-800 text-[11px] font-serif text-slate-400 text-center">
                      <strong>Nexo Causal Concluído:</strong> O motor semântico confirmou relevância causal de nível <strong>{pathResult.length - 1}</strong> entre as entidades. Clique em qualquer card acima para viajar até sua era correspondente.
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </>
        )}
      </div>
    )}

        {/* TAB: SEARCH / BASE DOCUMENTAL & SEMANTIC GRAPH */}
        {activeTab === 'search' && (
          <div id="tab-search" className="space-y-6">
            {/* Premium segmented control to switch views */}
            <div className="flex bg-slate-100 p-1 rounded-xl max-w-xs sm:max-w-md mx-auto sm:mx-0 border border-slate-200">
              <button
                id="subtab-cards-btn"
                onClick={() => setSearchSubTab('cards')}
                className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-mono font-bold uppercase tracking-wider transition-all ${
                  searchSubTab === 'cards'
                    ? 'bg-white text-slate-900 shadow-3xs border border-slate-200/50'
                    : 'text-slate-500 hover:text-slate-800'
                }`}
              >
                Provas e Fatos
              </button>
              <button
                id="subtab-graph-btn"
                onClick={() => {
                  setSearchSubTab('graph');
                  // Trigger pathfinding on load
                  const initialPath = kgEngine.findConnectionPath('char-cesar', 'god-jupiter');
                  setPathResult(initialPath);
                }}
                className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-mono font-bold uppercase tracking-wider transition-all ${
                  searchSubTab === 'graph'
                    ? 'bg-white text-slate-900 shadow-3xs border border-slate-200/50'
                    : 'text-slate-500 hover:text-slate-800'
                }`}
              >
                Grafo de Conhecimento
              </button>
            </div>

            {searchSubTab === 'cards' ? (
              <div className="space-y-6">
                {/* Explaining choice of Base Documental */}
                <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm">
                  <h2 className="text-xl font-serif font-bold text-slate-900 mb-2">Base Documental</h2>
                  <div className="bg-amber-50/50 rounded-xl p-3.5 border border-amber-100/50 text-xs text-amber-950 font-serif leading-relaxed mb-4">
                    <strong>Justificativa da Nomenclatura:</strong> Escolhemos <strong>"Base Documental"</strong> para esta área de exploração pois, ao contrário de uma simples "Biblioteca", esta aba representa o centro de validação científica do aplicativo. Ela foca no registro formal das provas historiográficas, permitindo rastrear onde cada afirmação factual foi coletada.
                  </div>
                  <p className="text-slate-500 text-xs font-serif leading-relaxed mb-4">
                    Pesquise por títulos, períodos ou termos-chave nas investigações catalogadas. Todos os dados e links referenciam artigos, teses e manuscritos reais e de elevado prestígio.
                  </p>

                  {/* Search Box */}
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Search className="h-4 w-4 text-slate-400" />
                    </div>
                    <input
                      id="library-search-input"
                      type="text"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      placeholder="Pesquisar por Tordesilhas, Alexandria, Roma, Artur..."
                      className="block w-full pl-10 pr-3 py-2.5 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-all bg-slate-50/50"
                    />
                  </div>
                </div>

                <div className="space-y-3">
                  <h3 className="text-xs font-mono font-bold text-slate-500 uppercase tracking-widest flex items-center gap-1.5">
                    <Filter className="w-3.5 h-3.5" />
                    <span>Registros Catalogados ({filteredCards.length})</span>
                  </h3>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {filteredCards.map((card) => (
                      <div
                        key={card.id}
                        onClick={() => {
                          const stepIdx = TIMELINE_STEPS.findIndex(step => {
                            if (card.id === 'alexandria') return step.id === 'roma-republica';
                            if (card.id === 'reiartur') return step.id === 'tordesilhas';
                            return step.id === card.id;
                          });
                          if (stepIdx !== -1) {
                            setCurrentTimelineIndex(stepIdx);
                          }
                          setViewingDossier(true);
                          setActiveTab('home');
                        }}
                        className="p-4 bg-white rounded-xl border border-slate-200 hover:border-amber-500 hover:shadow-xs transition-all cursor-pointer flex justify-between items-start"
                      >
                        <div>
                          <div className="flex gap-1.5 items-center">
                            <span className="text-[8px] uppercase font-mono tracking-widest bg-slate-100 text-slate-600 px-1.5 py-0.5 rounded border border-slate-200">
                              {card.period}
                            </span>
                            <span className="text-[8px] uppercase font-mono tracking-widest bg-amber-50 text-amber-800 px-1.5 py-0.5 rounded border border-amber-100">
                              {card.evidenceLevel.toUpperCase()}
                            </span>
                          </div>
                          <h4 className="font-serif font-bold text-slate-900 mt-2 text-sm leading-snug">{card.title}</h4>
                          <p className="text-slate-500 text-xs font-serif mt-1 line-clamp-2">{card.summary}</p>
                        </div>
                        <ChevronRight className="w-5 h-5 text-slate-300 shrink-0 self-center" />
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ) : (
              /* THE CHRONOS KNOWLEDGE GRAPH INTERACTIVE ENGINE */
              <div className="space-y-6">
                <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm relative overflow-hidden">
                  <div className="absolute top-0 right-0 w-48 h-48 bg-amber-500/[0.01] rounded-full blur-3xl pointer-events-none" />
                  <div className="flex items-center gap-2 mb-2">
                    <div className="p-1.5 rounded-lg bg-slate-900 text-amber-400">
                      <Network className="w-4 h-4" />
                    </div>
                    <h2 className="text-xl font-serif font-bold text-slate-900">Base de Conhecimento Conectada</h2>
                  </div>
                  <p className="text-slate-500 text-xs font-serif leading-relaxed mb-4">
                    CHRONOS organiza a história em um **Grafo de Conhecimento Semântico** que mapeia as conexões causais e culturais da humanidade. Esta arquitetura de dados relacional protege as investigações contra dados isolados e prepara a plataforma para futuras consultas por IA e busca semântica profunda.
                  </p>

                  {/* Graph Telemetry Stats */}
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-3 border-t border-slate-100">
                    <div className="p-3 bg-slate-50 rounded-xl border border-slate-200/60 text-center sm:text-left">
                      <span className="text-[8px] font-mono uppercase tracking-widest text-slate-400 block">Nós de Entidades</span>
                      <span className="text-lg font-mono font-bold text-slate-900">{kgEngine.getAllNodes().length} Ativos</span>
                    </div>
                    <div className="p-3 bg-slate-50 rounded-xl border border-slate-200/60 text-center sm:text-left">
                      <span className="text-[8px] font-mono uppercase tracking-widest text-slate-400 block">Arestas Direcionadas</span>
                      <span className="text-lg font-mono font-bold text-slate-900">6 Conexões</span>
                    </div>
                    <div className="p-3 bg-slate-50 rounded-xl border border-slate-200/60 text-center sm:text-left col-span-2">
                      <span className="text-[8px] font-mono uppercase tracking-widest text-slate-400 block">Ontologia Cadastrada</span>
                      <span className="text-[10px] font-mono font-bold text-amber-700 block truncate">25 Entidades Históricas e Mitológicas</span>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                  {/* Left Column: Semantic Search and Entity list */}
                  <div className="lg:col-span-1 space-y-4">
                    <div className="bg-white border border-slate-200 rounded-2xl p-4 shadow-3xs space-y-3">
                      <span className="text-[9px] font-mono font-bold text-slate-400 uppercase tracking-widest block">Busca Semântica no Grafo</span>
                      <div className="relative">
                        <div className="absolute inset-y-0 left-0 pl-2.5 flex items-center pointer-events-none">
                          <Search className="h-3.5 w-3.5 text-slate-400" />
                        </div>
                        <input
                          type="text"
                          value={graphQuery}
                          onChange={(e) => setGraphQuery(e.target.value)}
                          placeholder="Buscar personagem, deus, cidade, mito..."
                          className="block w-full pl-8 pr-3 py-2 border border-slate-200 rounded-xl text-xs placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/10 focus:border-amber-500 bg-slate-50/50"
                        />
                      </div>

                      <div className="space-y-1 max-h-[300px] overflow-y-auto pr-1 scrollbar-thin">
                        {kgEngine.search(graphQuery).map((node) => {
                          const isSelected = selectedNodeId === node.id;
                          return (
                            <button
                              key={node.id}
                              onClick={() => {
                                setSelectedNodeId(node.id);
                                // Focus the pathfinder parameters on clicking
                                if (!pathStartId) setPathStartId(node.id);
                              }}
                              className={`w-full text-left p-2.5 rounded-xl border transition-all text-xs flex flex-col ${
                                isSelected
                                  ? 'bg-slate-900 text-white border-slate-900 shadow-3xs'
                                  : 'bg-white hover:bg-slate-50 text-slate-700 border-slate-200/80'
                              }`}
                            >
                              <div className="flex justify-between items-center w-full">
                                <span className="font-bold truncate">{node.name}</span>
                                <span className={`text-[7px] font-mono px-1.5 py-0.2 rounded border uppercase tracking-wider ${
                                  isSelected
                                    ? 'bg-slate-800 border-slate-700 text-amber-300'
                                    : 'bg-slate-100 border-slate-200 text-slate-500'
                                }`}>
                                  {ENTITY_TYPE_TRANSLATIONS[node.type] || node.type}
                                </span>
                              </div>
                              <span className={`text-[9px] font-serif mt-1 line-clamp-1 ${isSelected ? 'text-slate-300' : 'text-slate-400'}`}>
                                {node.summary}
                              </span>
                            </button>
                          );
                        })}
                      </div>
                    </div>
                  </div>

                  {/* Middle & Right Column combined: Node Inspector Panel */}
                  <div className="lg:col-span-2">
                    {(() => {
                      const node = kgEngine.getNode(selectedNodeId);
                      if (!node) {
                        return (
                          <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center flex flex-col items-center justify-center min-h-[300px]">
                            <Network className="w-10 h-10 text-slate-300 mb-2 animate-pulse" />
                            <p className="text-slate-500 text-sm font-serif">Selecione um nó do grafo para inspecionar</p>
                          </div>
                        );
                      }

                      const neighbors = kgEngine.getNeighbors(node.id);
                      const recommendations = kgEngine.getRecommendations(node.id, 2);
                      const isMythological = node.evidenceLevel === 'mythological';

                      return (
                        <div className={`bg-white border rounded-2xl p-6 shadow-xs space-y-6 transition-colors duration-200 ${
                          isMythological ? 'border-amber-600/30 bg-amber-500/[0.005]' : 'border-slate-200'
                        }`}>
                          {/* Inspector Header */}
                          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-slate-100 pb-4">
                            <div>
                              <div className="flex items-center gap-2">
                                <span className={`text-[8px] font-mono font-extrabold uppercase px-2 py-0.5 rounded-full tracking-widest border ${
                                  isMythological 
                                    ? 'bg-amber-100/60 text-amber-800 border-amber-200' 
                                    : 'bg-slate-100 text-slate-700 border-slate-200'
                                }`}>
                                  {ENTITY_TYPE_TRANSLATIONS[node.type] || node.type}
                                </span>
                                <span className="text-[10px] font-mono text-slate-400 uppercase tracking-wide">
                                  {node.era}
                                </span>
                              </div>
                              <h3 className="text-xl font-serif font-bold text-slate-900 mt-1">{node.name}</h3>
                            </div>

                            <div className="flex flex-col items-start sm:items-end">
                              <span className="text-[8px] font-mono uppercase tracking-widest text-slate-400 block mb-0.5">Nível de Evidência</span>
                              <span className={`text-[10px] font-mono font-extrabold uppercase tracking-widest px-2.5 py-0.5 rounded border ${
                                node.evidenceLevel === 'high' 
                                  ? 'bg-emerald-50 text-emerald-800 border-emerald-200' 
                                  : node.evidenceLevel === 'good'
                                  ? 'bg-blue-50 text-blue-800 border-blue-200'
                                  : node.evidenceLevel === 'debate'
                                  ? 'bg-amber-50 text-amber-800 border-amber-200'
                                  : node.evidenceLevel === 'hypothesis'
                                  ? 'bg-rose-50 text-rose-800 border-rose-200'
                                  : 'bg-gradient-to-r from-amber-50 to-orange-50 text-amber-900 border-amber-300 font-semibold'
                              }`}>
                                {node.evidenceLevel === 'mythological' ? 'Estudo de Mitologia' : node.evidenceLevel.toUpperCase()}
                              </span>
                            </div>
                          </div>

                          {/* Summary & Core Description */}
                          <div className="space-y-2">
                            <span className="text-[9px] font-mono font-bold text-slate-400 uppercase tracking-widest block">Resumo Conceitual</span>
                            <p className="text-xs text-slate-800 font-serif leading-relaxed italic bg-slate-50 p-3 rounded-xl border border-slate-100">
                              "{node.summary}"
                            </p>
                            <p className="text-xs text-slate-600 font-serif leading-relaxed mt-2">
                              {node.description}
                            </p>
                          </div>

                          {/* Relationships Viz (Interactive connections list) */}
                          <div className="space-y-3">
                            <span className="text-[9px] font-mono font-bold text-slate-400 uppercase tracking-widest block">Relacionamentos Ativos no Grafo</span>
                            {neighbors.length > 0 ? (
                              <div className="flex flex-wrap gap-2">
                                {neighbors.map((n, idx) => (
                                  <button
                                    key={idx}
                                    onClick={() => setSelectedNodeId(n.node.id)}
                                    className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-slate-200 hover:border-amber-500 hover:bg-slate-50 transition-all text-[11px] text-slate-700 shadow-3xs group"
                                  >
                                    <span className="text-slate-400 font-semibold uppercase text-[8px] font-mono bg-slate-100 px-1.5 py-0.5 rounded border border-slate-200 group-hover:bg-amber-50 group-hover:text-amber-800 group-hover:border-amber-200">
                                      {RELATIONSHIP_TYPE_TRANSLATIONS[n.relationship.type] || n.relationship.type}
                                    </span>
                                    <span className="text-slate-400">{n.direction === 'outgoing' ? '→' : '←'}</span>
                                    <strong className="font-serif group-hover:text-slate-900">{n.node.name}</strong>
                                  </button>
                                ))}
                              </div>
                            ) : (
                              <p className="text-slate-400 text-xs font-serif italic">Nenhuma aresta direcional conectada para este nó.</p>
                            )}
                          </div>

                          {/* Dynamic Recommendations & Sources Row */}
                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
                            {/* Scientific Sources listed inside Node */}
                            <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200/60 space-y-2">
                              <span className="text-[8px] font-mono font-bold text-slate-400 uppercase tracking-widest block">Fontes da Entidade</span>
                              {node.sources && node.sources.length > 0 ? (
                                <div className="space-y-1.5">
                                  {node.sources.map((s, idx) => (
                                    <div key={idx} className="text-[10px] font-serif text-slate-600 border-l-2 border-slate-300 pl-2">
                                      <strong>{s.title}</strong>
                                      <p className="text-slate-400 text-[9px] font-mono">{s.author} ({s.year})</p>
                                    </div>
                                  ))}
                                </div>
                              ) : (
                                <p className="text-slate-400 text-[10px] font-serif italic">Aresta de relevância indireta/autointegrada.</p>
                              )}
                            </div>

                            {/* Recommendations calculated live by the engine */}
                            <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200/60 space-y-2">
                              <span className="text-[8px] font-mono font-bold text-slate-400 uppercase tracking-widest block font-bold text-amber-800">Recomendações de Conexão</span>
                              <div className="space-y-1">
                                {recommendations.map((rec) => (
                                  <button
                                    key={rec.id}
                                    onClick={() => setSelectedNodeId(rec.id)}
                                    className="w-full text-left text-[11px] font-serif text-slate-700 hover:text-amber-800 font-medium hover:underline flex items-center justify-between"
                                  >
                                    <span>{rec.name}</span>
                                    <span className="text-[8px] font-mono text-slate-400 uppercase tracking-wider">{ENTITY_TYPE_TRANSLATIONS[rec.type] || rec.type}</span>
                                  </button>
                                ))}
                              </div>
                            </div>
                          </div>
                        </div>
                      );
                    })()}
                  </div>
                </div>

                {/* DYNAMIC PATHFINDER GRAPH SIMULATOR SECTION */}
                <div className="bg-slate-900 text-white rounded-2xl p-6 border border-slate-800 relative overflow-hidden shadow-md">
                  <div className="absolute right-0 top-0 w-32 h-32 bg-amber-500/[0.04] rounded-full blur-2xl pointer-events-none" />
                  <div className="flex items-center gap-2 mb-2">
                    <div className="p-1.5 rounded-lg bg-amber-500/10 text-amber-400 border border-amber-500/20">
                      <GitBranch className="w-4 h-4" />
                    </div>
                    <h3 className="text-base font-serif font-bold text-amber-100">Descoberta de Conexões (Semantic Pathfinder)</h3>
                  </div>
                  <p className="text-slate-400 text-xs font-serif leading-relaxed mb-4">
                    Selecione duas entidades quaisquer da base de conhecimento CHRONOS para descobrir como elas estão relacionadas na teia histórica e cultural por meio de caminhos de parentesco, causalidade territorial ou herança mitológica.
                  </p>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 items-end mb-6">
                    <div className="space-y-1.5">
                      <label className="text-[9px] font-mono text-slate-400 uppercase tracking-widest block font-semibold">Origem (Nó A)</label>
                      <select
                        value={pathStartId}
                        onChange={(e) => setPathStartId(e.target.value)}
                        className="block w-full bg-slate-950 border border-slate-800 text-slate-200 text-xs rounded-xl p-2.5 focus:outline-none focus:border-amber-500 font-serif"
                      >
                        {kgEngine.getAllNodes().map(n => (
                          <option key={n.id} value={n.id}>{n.name} ({ENTITY_TYPE_TRANSLATIONS[n.type] || n.type})</option>
                        ))}
                      </select>
                    </div>

                    <div className="space-y-1.5">
                      <label className="text-[9px] font-mono text-slate-400 uppercase tracking-widest block font-semibold">Destino (Nó B)</label>
                      <select
                        value={pathEndId}
                        onChange={(e) => setPathEndId(e.target.value)}
                        className="block w-full bg-slate-950 border border-slate-800 text-slate-200 text-xs rounded-xl p-2.5 focus:outline-none focus:border-amber-500 font-serif"
                      >
                        {kgEngine.getAllNodes().map(n => (
                          <option key={n.id} value={n.id}>{n.name} ({ENTITY_TYPE_TRANSLATIONS[n.type] || n.type})</option>
                        ))}
                      </select>
                    </div>

                    <button
                      onClick={() => {
                        if (pathStartId === pathEndId) {
                          setPathError("Por favor, selecione duas entidades diferentes.");
                          setPathResult(null);
                        } else {
                          const path = kgEngine.findConnectionPath(pathStartId, pathEndId);
                          if (path) {
                            setPathResult(path);
                            setPathError(null);
                          } else {
                            setPathResult(null);
                            setPathError("Nenhum caminho lógico pôde ser traçado até a profundidade máxima de 4 níveis de conexões.");
                          }
                        }
                      }}
                      className="bg-amber-500 text-slate-950 hover:bg-amber-400 px-4 py-2.5 rounded-xl text-xs font-mono font-bold uppercase tracking-wider transition-all shadow-xs shrink-0 h-10 flex items-center justify-center gap-2"
                    >
                      <Cpu className="w-4 h-4" />
                      <span>Calcular Caminho</span>
                    </button>
                  </div>

                  {/* Pathfinder Output */}
                  <AnimatePresence mode="wait">
                    {pathError && (
                      <motion.div
                        initial={{ opacity: 0, y: 5 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0 }}
                        className="bg-rose-500/10 border border-rose-500/30 p-3.5 rounded-xl text-xs text-rose-300 font-serif"
                      >
                        {pathError}
                      </motion.div>
                    )}

                    {pathResult && (
                      <motion.div
                        initial={{ opacity: 0, y: 5 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0 }}
                        className="bg-slate-950 border border-slate-850 p-5 rounded-xl space-y-4 shadow-inner"
                      >
                        <span className="text-[9px] font-mono font-bold text-amber-500 uppercase tracking-widest block">Cadeia de Relações Tracada por Algoritmo Semântico</span>
                        
                        <div className="flex flex-col md:flex-row md:items-center gap-4 flex-wrap justify-center py-2">
                          {pathResult.map((step, stepIdx) => {
                            const nodeColor = step.node.evidenceLevel === 'mythological' 
                              ? 'border-amber-500/40 text-amber-300 bg-amber-500/5' 
                              : 'border-slate-700 text-slate-100 bg-slate-900';

                            return (
                              <div key={stepIdx} className="flex flex-col md:flex-row md:items-center gap-4">
                                {/* Entity Node */}
                                <div className={`px-4 py-3 rounded-xl border text-center font-serif flex flex-col justify-center max-w-xs ${nodeColor}`}>
                                  <span className="text-[7px] font-mono uppercase text-slate-400 tracking-wider mb-0.5">{ENTITY_TYPE_TRANSLATIONS[step.node.type] || step.node.type}</span>
                                  <strong className="text-xs">{step.node.name}</strong>
                                  <span className="text-[8px] font-mono text-slate-400 mt-1 uppercase tracking-wider">{step.node.era}</span>
                                </div>

                                {/* Directed Relationship Link Edge */}
                                {stepIdx < pathResult.length - 1 && pathResult[stepIdx + 1]?.relationship && (
                                  <div className="flex flex-row md:flex-col items-center justify-center gap-2">
                                    <div className="h-0.5 w-8 bg-slate-700 hidden md:block" />
                                    <span className="text-[8px] font-mono uppercase text-amber-400/80 tracking-widest bg-slate-900 px-2 py-0.5 rounded border border-slate-800">
                                      {RELATIONSHIP_TYPE_TRANSLATIONS[pathResult[stepIdx + 1].relationship?.type || ''] || pathResult[stepIdx + 1].relationship?.type}
                                    </span>
                                    <div className="h-0.5 w-8 bg-slate-700 hidden md:block" />
                                    {/* Mobile/vertical indicator arrow */}
                                    <span className="text-slate-500 block md:hidden text-lg">↓</span>
                                  </div>
                                )}
                              </div>
                            );
                          })}
                        </div>

                        <div className="bg-slate-900 p-3 rounded-lg border border-slate-800 text-[11px] font-serif text-slate-400 text-center">
                          <strong>Conclusão do Traçado:</strong> O algoritmo de busca em largura confirmou a existência de uma conexão intelectual de relevância histórico-cultural de nível <strong>{pathResult.length - 1}</strong> entre os termos.
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              </div>
            )}
          </div>
        )}

        {/* TAB: MITOLOGIA */}
        {activeTab === 'mitologia' && (
          <div id="tab-mitologia" className="space-y-6">
            {/* Elegant warning disclaimer matching exact quote and style requirements */}
            <div className="bg-amber-500/[0.03] border-2 border-amber-600/20 rounded-2xl p-5 shadow-xs relative">
              <div className="absolute top-0 right-0 w-32 h-32 bg-amber-500/[0.02] rounded-full blur-2xl pointer-events-none" />
              <div className="flex gap-4 items-start">
                <div className="p-2 rounded-xl bg-amber-500/10 text-amber-700 border border-amber-500/20 mt-0.5 shrink-0">
                  <AlertCircle className="w-5 h-5 stroke-[1.5]" />
                </div>
                <div>
                  <h4 className="text-xs font-mono font-bold text-amber-800 uppercase tracking-widest">Estudo das Tradições Culturais</h4>
                  <p className="text-xs text-amber-900/90 font-serif leading-relaxed mt-1">
                    "Os conteúdos desta seção representam tradições culturais, religiosas e literárias de diferentes civilizações. Eles não devem ser interpretados como fatos históricos comprovados, mas como parte importante da história das culturas humanas."
                  </p>
                </div>
              </div>
            </div>

            {selectedMythology === null ? (
              <div className="space-y-6">
                <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm">
                  <h2 className="text-xl font-serif font-bold text-slate-900 mb-2">Tradições Mitológicas Globais</h2>
                  <p className="text-slate-500 text-xs font-serif leading-relaxed">
                    Explore a estrutura sistêmica das narrativas religiosas e literárias das grandes civilizações da antiguidade. CHRONOS cataloga a cosmologia e os caminhos míticos como chaves para decifrar a mentalidade e o imaginário dos povos históricos.
                  </p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                  {mythologies.map((myth) => (
                    <div
                      key={myth.id}
                      onClick={() => {
                        setSelectedMythology(myth.id);
                        setActiveMythologySection('Introdução');
                      }}
                      className={`p-5 rounded-2xl border transition-all cursor-pointer flex flex-col justify-between ${myth.color} shadow-3xs hover:shadow-xs group`}
                    >
                      <div>
                        <div className="flex justify-between items-start">
                          <span className="text-[8px] font-mono tracking-widest text-slate-400 uppercase font-bold block">
                            {myth.region}
                          </span>
                          <Sparkles className="w-3.5 h-3.5 text-amber-600/40 group-hover:text-amber-500 transition-colors" />
                        </div>
                        <h3 className="font-serif font-bold text-base text-slate-950 mt-2 group-hover:text-amber-900 transition-colors">
                          {myth.name}
                        </h3>
                        <p className="text-slate-400 text-[10px] font-mono mt-3 uppercase tracking-wider">
                          {myth.era}
                        </p>
                      </div>
                      <div className="mt-5 flex items-center justify-between text-[10px] font-mono font-bold text-slate-400 group-hover:text-amber-800 transition-colors pt-2.5 border-t border-slate-200/40">
                        <span>ESTRUTURA ANALÍTICA</span>
                        <ChevronRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-1" />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="space-y-6">
                {/* Back Navigation */}
                <button
                  onClick={() => setSelectedMythology(null)}
                  className="inline-flex items-center gap-1.5 text-[10px] font-mono uppercase tracking-wider font-bold text-slate-600 hover:text-amber-800 transition-all bg-white hover:bg-slate-50 px-3.5 py-2 rounded-xl border border-slate-200 shadow-3xs"
                >
                  <ChevronLeft className="w-4 h-4 text-slate-500" />
                  <span>Voltar ao painel de Mitologias</span>
                </button>

                {/* Mythology Header Card with custom dark background and warm highlights */}
                <div className="bg-gradient-to-br from-slate-900 to-slate-950 rounded-2xl p-6 text-white border border-slate-800 relative overflow-hidden shadow-md">
                  <div className="absolute right-0 bottom-0 top-0 w-1/3 bg-gradient-to-l from-amber-500/10 to-transparent pointer-events-none" />
                  <span className="text-amber-400 font-mono text-[9px] uppercase tracking-widest font-bold">Módulo Temático e Cultural</span>
                  <h2 className="text-2xl font-serif font-bold text-amber-50 mt-1">
                    {mythologies.find(m => m.id === selectedMythology)?.name}
                  </h2>
                  <div className="flex flex-wrap gap-x-4 gap-y-1 mt-3 font-mono text-[10px] text-slate-300">
                    <span><strong>Geografia:</strong> {mythologies.find(m => m.id === selectedMythology)?.region}</span>
                    <span className="text-slate-600 hidden sm:inline">•</span>
                    <span><strong>Época de Atividade:</strong> {mythologies.find(m => m.id === selectedMythology)?.era}</span>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  {/* Left Column: List of 15 requested structural categories */}
                  <div className="md:col-span-1 space-y-1.5 max-h-[500px] overflow-y-auto pr-1 scrollbar-thin">
                    <span className="text-[9px] font-mono font-bold text-slate-400 uppercase tracking-widest block mb-2 px-2">Estrutura de Análise</span>
                    {mythologySections.map((sec) => {
                      const isActive = activeMythologySection === sec.title;
                      return (
                        <button
                          key={sec.title}
                          onClick={() => setActiveMythologySection(sec.title)}
                          className={`w-full text-left px-3 py-2.5 rounded-xl text-xs font-medium transition-all border flex items-center justify-between ${
                            isActive
                              ? 'bg-amber-800/10 text-amber-900 border-amber-500/30 font-bold shadow-3xs'
                              : 'bg-white text-slate-600 border-slate-200/80 hover:bg-slate-50 hover:text-slate-900'
                          }`}
                        >
                          <span>{sec.title}</span>
                          {isActive && <div className="w-1.5 h-1.5 rounded-full bg-amber-600" />}
                        </button>
                      );
                    })}
                  </div>

                  {/* Right Column: Active section high-fidelity explanation, structure and placeholder with warm identity */}
                  <div className="md:col-span-2">
                    {selectedMythology === 'brasileiro' && folcloreBrasileiroData[activeMythologySection] ? (
                      (() => {
                        const data = folcloreBrasileiroData[activeMythologySection];
                        return (
                          <div className="bg-emerald-500/[0.01] border-2 border-emerald-500/10 rounded-2xl p-6 shadow-3xs min-h-[400px] flex flex-col justify-between">
                            <div>
                              <div className="flex items-center gap-2 mb-4">
                                <div className="p-1.5 rounded-lg bg-emerald-500/10 text-emerald-700 border border-emerald-500/20">
                                  <Sparkles className="w-4 h-4 stroke-[1.5]" />
                                </div>
                                <h3 className="text-lg font-serif font-bold text-slate-900">{data.title}</h3>
                              </div>

                              <p className="text-slate-700 text-sm font-serif leading-relaxed mb-6">
                                {data.details}
                              </p>

                              <div className="bg-white rounded-xl p-4 border border-slate-200/80 space-y-3 shadow-3xs">
                                <div className="flex items-center gap-2 text-xs font-mono font-semibold text-slate-600 border-b border-slate-100 pb-2">
                                  <Info className="w-3.5 h-3.5 text-emerald-600" />
                                  <span>Aspectos Principais Relevantes</span>
                                </div>

                                <ul className="text-xs text-slate-600 space-y-2 pl-4 list-disc font-serif leading-relaxed">
                                  {data.bullets.map((bullet, idx) => (
                                    <li key={idx}>{bullet}</li>
                                  ))}
                                </ul>
                              </div>
                            </div>

                            <div className="mt-6 bg-emerald-500/[0.03] border border-emerald-500/10 rounded-xl p-4">
                              <span className="text-[9px] font-mono uppercase tracking-widest text-emerald-800 font-bold block mb-1">Nota Científica & Acadêmica</span>
                              <p className="text-[11px] text-emerald-700/90 font-serif leading-relaxed">
                                {data.scientificNote}
                              </p>
                            </div>
                          </div>
                        );
                      })()
                    ) : (
                      <div className="bg-amber-500/[0.01] border-2 border-amber-500/10 rounded-2xl p-6 shadow-3xs min-h-[400px] flex flex-col justify-between">
                        <div>
                          <div className="flex items-center gap-2 mb-4">
                            <div className="p-1.5 rounded-lg bg-amber-500/10 text-amber-700 border border-amber-500/20">
                              <Sparkles className="w-4 h-4 stroke-[1.5]" />
                            </div>
                            <h3 className="text-lg font-serif font-bold text-slate-900">{activeMythologySection}</h3>
                          </div>

                          <p className="text-slate-600 text-sm font-serif leading-relaxed mb-6">
                            {mythologySections.find(s => s.title === activeMythologySection)?.description}
                          </p>

                          <div className="bg-white rounded-xl p-4 border border-slate-200/80 space-y-3 shadow-3xs">
                            <div className="flex items-center gap-2 text-xs font-mono font-semibold text-slate-500 border-b border-slate-100 pb-2">
                              <Info className="w-3.5 h-3.5 text-amber-600" />
                              <span>Mapeamento do Legado Cultural</span>
                            </div>

                            <p className="text-xs text-slate-500 font-serif leading-relaxed">
                              A curadoria científica do CHRONOS planejou e modelou detalhadamente esta subcategoria para a tradição do povo {mythologies.find(m => m.id === selectedMythology)?.name.replace('Mitologia ', '')}. A seção compreenderá:
                            </p>

                            <ul className="text-xs text-slate-600 space-y-2 pl-4 list-disc font-serif leading-relaxed">
                              <li>Análise comparativa das fontes originais e preservação arqueológica do mito.</li>
                              <li>Contextualização do imaginário sobrenatural e sua fusão com o cotidiano político e de subsistência antigo.</li>
                              <li>Termos etimológicos na língua de origem das epopeias literárias.</li>
                              <li>Tradução sistemática dos fragmentos de pergaminhos ou manuscritos de referência.</li>
                            </ul>
                          </div>
                        </div>

                        <div className="mt-6 bg-amber-500/[0.03] border border-amber-500/10 rounded-xl p-4 text-center">
                          <span className="text-[9px] font-mono uppercase tracking-widest text-amber-800 font-bold block mb-1">Mapeamento em Andamento</span>
                          <p className="text-[11px] text-amber-700/90 font-serif leading-relaxed">
                            A estrutura conceitual está definida. Nossos pesquisadores estão consolidando os pergaminhos literários e o material iconográfico desta seção para disponibilizá-los em breve.
                          </p>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* TAB: SAVED / SOURCES */}
        {activeTab === 'saved' && (
          <div id="tab-saved" className="space-y-6">
            <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm">
              <h2 className="text-xl font-serif font-bold text-slate-900 mb-2">Acervo Bibliográfico</h2>
              <p className="text-slate-500 text-xs font-serif leading-relaxed">
                Esta seção armazena as principais fontes que dão embasamento empírico e textual às nossas investigações de campo.
              </p>
            </div>

            <div className="space-y-4">
              <h3 className="text-xs font-mono font-bold text-slate-500 uppercase tracking-widest">Fontes Ativas Reconhecidas</h3>
              <div className="grid grid-cols-1 gap-3">
                {mockCards.flatMap((c) => c.sources).map((src, index) => (
                  <div key={index} className="p-4 bg-white border border-slate-200 rounded-xl flex items-start gap-4">
                    <div className="p-2.5 rounded-lg bg-slate-100 text-slate-700 shrink-0 border border-slate-200">
                      <BookOpen className="w-5 h-5 text-amber-700" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-1.5">
                        <span className="text-[8px] uppercase font-mono tracking-widest bg-slate-100 text-slate-600 px-1.5 py-0.2 rounded border border-slate-200">
                          {src.type === 'book' ? 'Livro' : src.type === 'document' ? 'Manuscrito' : 'Artigo Acadêmico'}
                        </span>
                        <span className="text-[8px] font-mono text-slate-400">{src.details}</span>
                      </div>
                      <h4 className="font-bold text-slate-900 text-sm leading-snug mt-1 truncate">{src.title}</h4>
                      <p className="text-slate-500 text-xs mt-0.5">{src.author} ({src.year})</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* TAB: USER PROFILE */}
        {activeTab === 'profile' && (
          <div id="tab-profile" className="space-y-6">
            {/* Profile Card */}
            <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col sm:flex-row items-center gap-6">
              <div className="w-20 h-20 rounded-full bg-slate-900 text-amber-400 font-serif font-bold text-3xl flex items-center justify-center border-4 border-amber-500/20">
                {userState.name.charAt(0)}
              </div>
              <div className="text-center sm:text-left flex-1">
                <span className="text-[9px] font-mono font-bold uppercase tracking-widest bg-amber-50 text-amber-800 border border-amber-200 px-2.5 py-0.5 rounded-full">
                  Investigador Acadêmico
                </span>
                <h3 className="text-xl font-serif font-bold text-slate-900 mt-1">{userState.name}</h3>
                <p className="text-slate-500 text-xs font-mono">{userState.email}</p>
                <p className="text-slate-400 text-xs mt-1">Membro ativo desde: {userState.joinedDate}</p>
              </div>
            </div>

            {/* Performance Stats */}
            <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm space-y-4">
              <h3 className="text-xs font-mono font-bold text-slate-500 uppercase tracking-widest">Rendimento Investigativo</h3>
              <div className="grid grid-cols-2 gap-4 text-center">
                <div className="p-4 rounded-xl bg-slate-50 border border-slate-100">
                  <span className="block text-2xl font-mono font-bold text-slate-900">{masteredCards.length}</span>
                  <span className="text-[11px] text-slate-500 font-serif">Cartões Analisados</span>
                </div>
                <div className="p-4 rounded-xl bg-slate-50 border border-slate-100">
                  <span className="block text-2xl font-mono font-bold text-amber-600">{userState.xp}</span>
                  <span className="text-[11px] text-slate-500 font-serif">Pontos XP Obtidos</span>
                </div>
              </div>
            </div>

            {/* Rigor Historiográfico (Substitui achievements infantis) */}
            <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm space-y-4">
              <h3 className="text-xs font-mono font-bold text-slate-500 uppercase tracking-widest flex items-center gap-1.5">
                <Shield className="w-4 h-4 text-amber-600" />
                <span>Rigor Científico Adotado</span>
              </h3>
              <p className="text-xs text-slate-500 font-serif leading-relaxed">
                Este perfil adere estritamente às normas do método histórico e historiográfico científico. Todo o progresso registrado atesta a leitura de dados baseados em fatos comprovados, distinção analítica e estudo bibliográfico rigoroso.
              </p>
            </div>
          </div>
        )}

        {/* TAB: SETTINGS */}
        {activeTab === 'settings' && (
          <div id="tab-settings" className="space-y-6">
            <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm">
              <h2 className="text-xl font-serif font-bold text-slate-900 mb-2">Compromisso Editorial</h2>
              <p className="text-slate-500 text-xs font-serif leading-relaxed">
                Gerencie sua conta e examine as diretrizes acadêmicas que fundamentam nosso portal.
              </p>
            </div>

            {/* Guidelines */}
            <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm space-y-4">
              <h3 className="text-xs font-mono font-bold text-slate-500 uppercase tracking-widest flex items-center gap-1.5">
                <Shield className="w-4 h-4 text-amber-600" />
                <span>Diretrizes de Rigor Historiográfico</span>
              </h3>
              <div className="space-y-3">
                <div className="flex gap-3 items-start text-xs text-slate-600">
                  <CheckCircle className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
                  <span><strong>Separação Metódica:</strong> Divisão clara entre fatos consensuais e correntes de interpretação da época.</span>
                </div>
                <div className="flex gap-3 items-start text-xs text-slate-600">
                  <CheckCircle className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
                  <span><strong>Transparência de Fontes:</strong> Fornecimento contínuo das coordenadas exatas dos manuscritos e livros consultados.</span>
                </div>
                <div className="flex gap-3 items-start text-xs text-slate-600">
                  <CheckCircle className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
                  <span><strong>Independência Teórica:</strong> Abordagem neutra despida de anacronismos ou visões lúdicas infantis.</span>
                </div>
              </div>
            </div>

            {/* Settings Options (Restauração de XP removida!) */}
            <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm divide-y divide-slate-100">
              <button
                id="logout-button"
                onClick={onLogout}
                className="w-full text-left px-6 py-4 hover:bg-rose-50 text-rose-600 transition-colors flex items-center justify-between text-xs font-semibold"
              >
                <span>Terminar Sessão Acadêmica (Logout)</span>
                <LogOut className="w-4 h-4 text-rose-400" />
              </button>
            </div>

            <div className="text-center">
              <p className="text-[9px] text-slate-400 font-mono tracking-widest uppercase">CHRONOS • Conhecimento através do tempo</p>
            </div>
          </div>
        )}
      </main>

      {/* Persistent Bottom Nav */}
      <BottomNav
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        savedCount={savedSourcesCount}
      />
    </div>
  );
}
