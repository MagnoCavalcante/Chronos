/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { KGNode, KGRelationship, EntityType, RelationshipType, EvidenceLevel, KGQuery } from '../types';

export class CHRONOSKnowledgeEngine {
  private nodes: Map<string, KGNode> = new Map();
  private relationships: KGRelationship[] = [];

  constructor() {
    this.initializeBootstrapArchitecture();
  }

  /**
   * Registers a new entity node into the Knowledge Graph
   */
  public registerNode(node: KGNode): void {
    this.nodes.set(node.id, node);
  }

  /**
   * Registers a semantic relationship (directed edge) between two nodes
   */
  public registerRelationship(rel: KGRelationship): void {
    // Prevent duplicate relationships
    const exists = this.relationships.some(
      r => r.sourceId === rel.sourceId && r.targetId === rel.targetId && r.type === rel.type
    );
    if (!exists) {
      this.relationships.push(rel);
    }
  }

  /**
   * Retrieves an entity by its unique ID
   */
  public getNode(id: string): KGNode | undefined {
    return this.nodes.get(id);
  }

  /**
   * Retrieves all nodes in the graph
   */
  public getAllNodes(): KGNode[] {
    return Array.from(this.nodes.values());
  }

  /**
   * Gets all relationships associated with a specific node (either as source or target)
   */
  public getRelationships(nodeId: string): KGRelationship[] {
    return this.relationships.filter(r => r.sourceId === nodeId || r.targetId === nodeId);
  }

  /**
   * Gets immediate neighbors of a node along with their qualifying relationships
   */
  public getNeighbors(nodeId: string): { node: KGNode; relationship: KGRelationship; direction: 'outgoing' | 'incoming' }[] {
    const neighbors: { node: KGNode; relationship: KGRelationship; direction: 'outgoing' | 'incoming' }[] = [];

    for (const rel of this.relationships) {
      if (rel.sourceId === nodeId) {
        const targetNode = this.nodes.get(rel.targetId);
        if (targetNode) {
          neighbors.push({ node: targetNode, relationship: rel, direction: 'outgoing' });
        }
      } else if (rel.targetId === nodeId) {
        const sourceNode = this.nodes.get(rel.sourceId);
        if (sourceNode) {
          neighbors.push({ node: sourceNode, relationship: rel, direction: 'incoming' });
        }
      }
    }

    return neighbors;
  }

  /**
   * Pathfinding Algorithm (BFS) to discover semantic connections between two arbitrary entities.
   * Helps power the "Descoberta de Conexões" feature.
   */
  public findConnectionPath(startId: string, endId: string, maxDepth: number = 4): { node: KGNode; relationship?: KGRelationship }[] | null {
    if (!this.nodes.has(startId) || !this.nodes.has(endId)) return null;
    if (startId === endId) {
      return [{ node: this.nodes.get(startId)! }];
    }

    // Queue stores paths: array of { nodeId, relationshipId }
    const queue: { nodeId: string; path: { nodeId: string; rel?: KGRelationship }[] }[] = [];
    const visited = new Set<string>();

    queue.push({ nodeId: startId, path: [{ nodeId: startId }] });
    visited.add(startId);

    while (queue.length > 0) {
      const { nodeId, path } = queue.shift()!;

      if (nodeId === endId) {
        // Map back to full nodes and relationships
        return path.map(p => ({
          node: this.nodes.get(p.nodeId)!,
          relationship: p.rel
        }));
      }

      if (path.length > maxDepth) continue;

      const neighbors = this.getNeighbors(nodeId);
      for (const n of neighbors) {
        if (!visited.has(n.node.id)) {
          visited.add(n.node.id);
          queue.push({
            nodeId: n.node.id,
            path: [...path, { nodeId: n.node.id, rel: n.relationship }]
          });
        }
      }
    }

    return null; // No connection found within maxDepth
  }

  /**
   * Filters the knowledge base according to a flexible query parameters object
   */
  public query(q: KGQuery): KGNode[] {
    let results = this.getAllNodes();

    if (q.types && q.types.length > 0) {
      results = results.filter(n => q.types!.includes(n.type));
    }

    if (q.evidenceLevel) {
      results = results.filter(n => n.evidenceLevel === q.evidenceLevel);
    }

    if (q.tags && q.tags.length > 0) {
      results = results.filter(n => n.tags.some(t => q.tags!.includes(t)));
    }

    if (q.keywords && q.keywords.length > 0) {
      results = results.filter(n => n.keywords.some(k => q.keywords!.includes(k)));
    }

    return results;
  }

  /**
   * Search nodes by textual query matching name, summary, description, tags, or keywords
   */
  public search(text: string): KGNode[] {
    if (!text || text.trim() === '') return this.getAllNodes();
    const cleanText = text.toLowerCase().trim();

    return this.getAllNodes().filter(n => 
      n.name.toLowerCase().includes(cleanText) ||
      n.summary.toLowerCase().includes(cleanText) ||
      n.description.toLowerCase().includes(cleanText) ||
      n.tags.some(t => t.toLowerCase().includes(cleanText)) ||
      n.keywords.some(k => k.toLowerCase().includes(cleanText))
    );
  }

  /**
   * Chronological sequence sorter for the "Linha do tempo dinâmica" feature.
   * Parses various temporal indicators in nodes and outputs a sequential list.
   */
  public getChronologicalTimeline(): KGNode[] {
    return this.getAllNodes()
      .filter(n => n.era) // Only include elements with an active era/date
      .sort((a, b) => {
        const yearA = this.parseEraToComparableYear(a.era);
        const yearB = this.parseEraToComparableYear(b.era);
        return yearA - yearB;
      });
  }

  /**
   * Generates automatic smart content recommendations based on shared tags, 
   * categories, and immediate graph neighbors.
   */
  public getRecommendations(nodeId: string, limit: number = 3): KGNode[] {
    const target = this.nodes.get(nodeId);
    if (!target) return [];

    const neighbors = this.getNeighbors(nodeId).map(n => n.node);
    if (neighbors.length >= limit) {
      return neighbors.slice(0, limit);
    }

    // Complement with nodes sharing the same tags or type
    const remainingCount = limit - neighbors.length;
    const candidates = this.getAllNodes().filter(n => 
      n.id !== nodeId && 
      !neighbors.some(neigh => neigh.id === n.id) &&
      (n.type === target.type || n.tags.some(t => target.tags.includes(t)))
    );

    return [...neighbors, ...candidates.slice(0, remainingCount)];
  }

  /**
   * Outputs high-level research proof statistics without telemetry or unrequested logs
   */
  public getEvidenceStatistics(): Record<EvidenceLevel, number> {
    const stats: Record<EvidenceLevel, number> = {
      high: 0,
      good: 0,
      debate: 0,
      hypothesis: 0,
      mythological: 0
    };

    for (const node of this.getAllNodes()) {
      stats[node.evidenceLevel] = (stats[node.evidenceLevel] || 0) + 1;
    }

    return stats;
  }

  /**
   * Helper to turn freeform historical era strings into comparable numeric years
   * e.g., "3000 a.C." -> -3000, "1500 d.C." -> 1500, "Século XII a.C." -> -1150
   */
  private parseEraToComparableYear(era: string): number {
    const clean = era.toLowerCase().trim();
    
    // Parse BCE/a.C.
    const isBCE = clean.includes('a.c.') || clean.includes('bce') || clean.includes('antes de cristo');
    
    // Check if it's a century notation (e.g. "século xii")
    const romanCenturies: Record<string, number> = {
      'i': 1, 'ii': 2, 'iii': 3, 'iv': 4, 'v': 5, 'vi': 6, 'vii': 7, 'viii': 8, 'ix': 9, 'x': 10,
      'xi': 11, 'xii': 12, 'xiii': 13, 'xiv': 14, 'xv': 15, 'xvi': 16, 'xvii': 17, 'xviii': 18, 'xix': 19, 'xx': 20, 'xxi': 21
    };

    let centuryNumber = 0;
    for (const [roman, num] of Object.entries(romanCenturies)) {
      if (clean.includes(`século ${roman}`) || clean.includes(`sec. ${roman}`) || clean.includes(`séc. ${roman}`)) {
        centuryNumber = num;
        break;
      }
    }

    if (centuryNumber > 0) {
      // Century mid-point (e.g., Century 12 is year 1150)
      const year = (centuryNumber - 1) * 100 + 50;
      return isBCE ? -year : year;
    }

    // Try extracting numbers
    const numberMatches = clean.match(/\d+/g);
    if (numberMatches && numberMatches.length > 0) {
      const parsedYear = parseInt(numberMatches[0], 10);
      return isBCE ? -parsedYear : parsedYear;
    }

    return 0; // Default fallback for unparseable era text
  }

  /**
   * Initializes bootstrap architectural templates across major categories 
   * to demonstrate and seed the dynamic connectivity behavior requested.
   */
  private initializeBootstrapArchitecture(): void {
    // 1. Civilização: Império Romano
    this.registerNode({
      id: 'civ-roma',
      type: 'CIVILIZACAO',
      name: 'Roma Antiga',
      summary: 'Uma das maiores civilizações da antiguidade, originada na península Itálica.',
      description: 'A Civilização Romana evoluiu de uma monarquia para uma república oligárquica e, finalmente, para um vasto império autocrático. Seu legado estende-se pelo direito civil, línguas românicas, arquitetura monumental e engenharia militar.',
      era: '753 a.C. - 476 d.C.',
      evidenceLevel: 'high',
      tags: ['Clássico', 'Mediterrâneo', 'Jurídico', 'Imperial'],
      keywords: ['Roma', 'Senado', 'César', 'Legiões'],
      sources: [
        { id: 'src-tito-livio', title: 'Ab Urbe Condita', author: 'Tito Lívio', year: 27, type: 'document', details: 'Livros I-V' }
      ]
    });

    // 2. Personagem: Júlio César
    this.registerNode({
      id: 'char-cesar',
      type: 'PERSONAGEM',
      name: 'Júlio César',
      summary: 'Patrício, general, cônsul e ditador vitalício da República Romana.',
      description: 'Líder militar crucial na expansão territorial romana através das Guerras Gálicas. Sua travessia do rio Rubicão desencadeou a guerra civil que culminou no fim da República Romana e no advento do Império.',
      era: '100 a.C. - 44 a.C.',
      evidenceLevel: 'high',
      tags: ['Político', 'General', 'Militar', 'Ditador'],
      keywords: ['Rubicão', 'Gália', 'Idos de Março', 'César'],
      sources: [
        { id: 'src-suetonio', title: 'Vida dos Doze Césares', author: 'Suetônio', year: 121, type: 'book', details: 'Divus Iulius' }
      ]
    });

    // 3. Evento: Travessia do Rubicão
    this.registerNode({
      id: 'evt-rubicao',
      type: 'EVENTO',
      name: 'Travessia do Rubicão',
      summary: 'Ação de Júlio César que marcou o início da Guerra Civil Romana.',
      description: 'Sob a lei romana, qualquer general que liderasse uma legião armada através do rio Rubicão (fronteira norte da Itália) seria considerado traidor do Estado. César pronunciou a frase "Alea iacta est" (o dado está lançado).',
      era: '49 a.C.',
      evidenceLevel: 'high',
      tags: ['Guerra Civil', 'Travessia', 'Ruptura'],
      keywords: ['Alea iacta est', 'Rubicão', 'Traição', 'Roma'],
      sources: [
        { id: 'src-plutarco', title: 'Vidas Paralelas', author: 'Plutarco', year: 100, type: 'book', details: 'Vida de Júlio César, Seção 32' }
      ]
    });

    // 4. Cidade: Roma
    this.registerNode({
      id: 'city-roma',
      type: 'CIDADE',
      name: 'Roma',
      summary: 'Capital do Império Romano e centro administrativo do mundo clássico.',
      description: 'Erguida sobre sete colinas às margens do rio Tibre, tornou-se o epicentro de decisões políticas, culturais e religiosas de todo o Mediterrâneo mediterrâneo romano.',
      era: '753 a.C. - Presente',
      evidenceLevel: 'high',
      tags: ['Capital', 'Itália', 'Urbanismo'],
      keywords: ['Tibre', 'Sete Colinas', 'Fórum', 'Capitólio'],
      sources: []
    });

    // 5. Livro: De Bello Gallico
    this.registerNode({
      id: 'book-bello-gallico',
      type: 'LIVRO',
      name: 'De Bello Gallico',
      summary: 'Relatos militares da campanha na Gália escritos pelo próprio Júlio César.',
      description: 'O texto serve tanto como documentação histórica das táticas de combate romanas quanto como um refinado panfleto de propaganda política pessoal para consolidar a influência de César em Roma.',
      era: '50 a.C.',
      evidenceLevel: 'high',
      tags: ['Manuscrito', 'Propaganda', 'Militar'],
      keywords: ['Campanhas', 'Gália', 'Crônica', 'César'],
      sources: [
        { id: 'src-bello-gallico-original', title: 'Commentarii de Bello Gallico', author: 'Júlio César', year: -50, type: 'document' }
      ]
    });

    // 6. Mitologia: Mitologia Romana (Subcategoria já conectada ao grafo)
    this.registerNode({
      id: 'myth-romana',
      type: 'MITOLOGIA',
      name: 'Mitologia Romana',
      summary: 'Estudo do sistema de crenças, rituais e literatura religiosa de Roma.',
      description: 'Conjunto de narrativas tradicionais referentes às origens lendárias da fundação de Roma e às divindades de seu panteão sincrético, mesclando raízes itálicas nativas com a influência religiosa helenística.',
      era: 'Século VIII a.C. - Século V d.C.',
      evidenceLevel: 'mythological',
      tags: ['Tradição', 'Panteão', 'Sincretismo'],
      keywords: ['Júpiter', 'Mitologia', 'Crenças', 'Rituais'],
      sources: [
        { id: 'src-ovidio', title: 'Metamorfoses', author: 'Ovídio', year: 8, type: 'myth', details: 'Livros I-XV' }
      ]
    });

    // 7. Deus Mitológico: Júpiter
    this.registerNode({
      id: 'god-jupiter',
      type: 'DEUS',
      name: 'Júpiter',
      summary: 'Rei dos deuses romanos, senhor dos céus, do trovão e da justiça estatal.',
      description: 'Equivalente sincrético ao Zeus grego, Júpiter Optimus Maximus presidia sobre o direito público romano, rituais de triunfo militar e tratados de alianças políticas.',
      era: 'Século VIII a.C. - Século IV d.C.',
      evidenceLevel: 'mythological',
      tags: ['Divindade', 'Soberano', 'Trovão'],
      keywords: ['Águia', 'Raio', 'Capitólio', 'Olimpo'],
      sources: [
        { id: 'src-virgilio', title: 'Eneida', author: 'Virgílio', year: 19, type: 'myth', details: 'Canto I' }
      ]
    });

    // ESTABELECE OS RELACIONAMENTOS INICIAIS DO GRAFO
    // Personagem participou de Evento
    this.registerRelationship({
      id: 'rel-1',
      sourceId: 'char-cesar',
      targetId: 'evt-rubicao',
      type: 'PARTICIPATED_IN',
      description: 'Júlio César liderou ativamente a passagem militar armada.'
    });

    // Evento ocorreu em Cidade
    this.registerRelationship({
      id: 'rel-2',
      sourceId: 'evt-rubicao',
      targetId: 'city-roma',
      type: 'OCCURRED_IN',
      description: 'A travessia teve como destino político e militar direto a capital de Roma.'
    });

    // Personagem governou Império/Civilização
    this.registerRelationship({
      id: 'rel-3',
      sourceId: 'char-cesar',
      targetId: 'civ-roma',
      type: 'RULED_EMPIRE',
      description: 'Exerceu a função de Ditador Vitalício e General do Estado Romano.'
    });

    // Autor escreveu Livro
    this.registerRelationship({
      id: 'rel-4',
      sourceId: 'char-cesar',
      targetId: 'book-bello-gallico',
      type: 'WROTE_BOOK',
      description: 'Escreveu o compêndio de memórias militares das campanhas gálicas.'
    });

    // Deus pertence à Mitologia
    this.registerRelationship({
      id: 'rel-5',
      sourceId: 'god-jupiter',
      targetId: 'myth-romana',
      type: 'BELONGS_TO_MYTHOLOGY',
      description: 'Deus supremo do culto ritualístico do Estado Romano.'
    });

    // Associação conceitual entre a Mitologia Romana e a Civilização Romana
    this.registerRelationship({
      id: 'rel-6',
      sourceId: 'myth-romana',
      targetId: 'civ-roma',
      type: 'ASSOCIATED_WITH',
      description: 'Elemento de coesão moral, social e política do povo e seus ritos cívicos.'
    });

    // Pompeu o Grande
    this.registerNode({
      id: 'char-pompeu',
      type: 'PERSONAGEM',
      name: 'Pompeu o Grande',
      summary: 'General romano, rival político de Júlio César e líder das forças do Senado.',
      description: 'Aliado inicial de César no Primeiro Triunvirato, tornou-se seu principal adversário na Guerra Civil Romana, representando a facção conservadora do Senado (os Optimates). Foi derrotado em Farsalos e assassinado no Egito.',
      era: '106 a.C. - 48 a.C.',
      evidenceLevel: 'high',
      tags: ['Militar', 'Político', 'Guerra Civil', 'Senado'],
      keywords: ['Pompeu', 'Triunvirato', 'Senado', 'Farsalos'],
      sources: [
        { id: 'src-plutarco-pompeu', title: 'Vidas Paralelas: Vida de Pompeu', author: 'Plutarco', year: 100, type: 'book' }
      ]
    });

    // Guerra Civil Romana
    this.registerNode({
      id: 'war-guerra-civil-roma',
      type: 'GUERRA',
      name: 'Grande Guerra Civil Romana',
      summary: 'Conflito militar que marcou o colapso da República Romana e a ascensão do Império.',
      description: 'Iniciada com a travessia de César pelo Rubicão, a guerra envolveu combates em toda a bacia mediterrânea (Itália, Hispânia, Grécia, África e Egito) e dividiu o Senado e as legiões.',
      era: '49 a.C. - 45 a.C.',
      evidenceLevel: 'high',
      tags: ['Conflito', 'Guerra', 'Império', 'República'],
      keywords: ['Guerra Civil', 'Farsalos', 'Pompeu', 'César'],
      sources: []
    });

    // Alexandria
    this.registerNode({
      id: 'city-alexandria',
      type: 'CIDADE',
      name: 'Alexandria',
      summary: 'Cidade portuária egípcia, centro de erudição e cultura do mundo helenístico.',
      description: 'Fundada por Alexandre, o Grande, foi a capital do Egito Ptolemaico e abrigou a lendária Biblioteca de Alexandria, o Farol e foi o cenário de encontros históricos cruciais de César, Cleópatra e Marco Antônio.',
      era: '331 a.C. - Presente',
      evidenceLevel: 'high',
      tags: ['Egito', 'Helenístico', 'Biblioteca', 'Porto'],
      keywords: ['Alexandria', 'Cleópatra', 'Egito', 'Biblioteca'],
      sources: []
    });

    // Biblioteca de Alexandria
    this.registerNode({
      id: 'const-biblioteca-alexandria',
      type: 'CONSTRUCAO',
      name: 'Grande Biblioteca de Alexandria',
      summary: 'A maior e mais célebre biblioteca da Antiguidade clássica.',
      description: 'Dedicada às Musas, floresceu sob o patrocínio da dinastia ptolemaica. Estima-se que abrigava centenas de milhares de rolos de papiro contendo todo o conhecimento do mundo antigo.',
      era: 'Século III a.C. - Século IV d.C.',
      evidenceLevel: 'high',
      tags: ['Biblioteca', 'Cultura', 'Papiro', 'Erudição'],
      keywords: ['Alexandria', 'Papiro', 'Conhecimento', 'Cinzas'],
      sources: []
    });

    // Cleópatra VII
    this.registerNode({
      id: 'char-cleopatra',
      type: 'PERSONAGEM',
      name: 'Cleópatra VII',
      summary: 'Última governante ativa do Reino Ptolemaico do Egito.',
      description: 'Famosa por sua inteligência, cultura e carisma, aliou-se politicamente e romanticamente a Júlio César e Marco Antônio para manter a independência do Egito frente ao expansionismo de Roma.',
      era: '69 a.C. - 30 a.C.',
      evidenceLevel: 'high',
      tags: ['Rainha', 'Egito', 'Ptolemaico', 'Diplomacia'],
      keywords: ['Egito', 'Marco Antônio', 'César', 'Nilo'],
      sources: [
        { id: 'src-plutarco-antonio', title: 'Vidas Paralelas: Vida de Marco Antônio', author: 'Plutarco', year: 100, type: 'book' }
      ]
    });

    // Suméria
    this.registerNode({
      id: 'civ-sumeria',
      type: 'CIVILIZACAO',
      name: 'Civilização Suméria',
      summary: 'A civilização mais antiga conhecida, situada na Mesopotâmia meridional.',
      description: 'Responsáveis pelo desenvolvimento de inovações primordiais na agricultura, arquitetura e astronomia, além de estabelecerem as primeiras cidades-estado independentes como Ur, Uruk e Lagash.',
      era: '3500 a.C. - 1900 a.C.',
      evidenceLevel: 'high',
      tags: ['Mesopotâmia', 'Bronze', 'Crescente Fértil'],
      keywords: ['Ur', 'Uruk', 'Cuneiforme', 'Mesopotâmia'],
      sources: [
        { id: 'src-samuel-kramer', title: 'The Sumerians', author: 'Samuel Noah Kramer', year: 1963, type: 'book' }
      ]
    });

    // Escrita Cuneiforme
    this.registerNode({
      id: 'tech-cuneiforme',
      type: 'TECNOLOGIA',
      name: 'Escrita Cuneiforme',
      summary: 'O primeiro sistema formal de escrita registrado na história humana.',
      description: 'Criado pelos sumérios, consistia em inscrições em forma de cunha feitas em placas de argila úmida com o auxílio de um estilete de junco. Serviu para registros contábeis, administrativos, leis e literatura mitológica.',
      era: '3200 a.C.',
      evidenceLevel: 'high',
      tags: ['Escrita', 'Inovação', 'Argila', 'Mesopotâmia'],
      keywords: ['Cuneiforme', 'Argila', 'Suméria', 'Escrita'],
      sources: []
    });

    // Código de Hamurabi
    this.registerNode({
      id: 'doc-hamurabi',
      type: 'DOCUMENTO',
      name: 'Código de Hamurabi',
      summary: 'Monólito de basalto contendo uma das leis escritas mais antigas do mundo.',
      description: 'Criado pelo rei Hamurabi da Babilônia, estabeleceu a célebre "Lei do Talião" (olho por olho, dente por dente) e regulou a vida civil, comercial e criminal com base no status social dos indivíduos.',
      era: '1750 a.C.',
      evidenceLevel: 'high',
      tags: ['Lei', 'Mesopotâmia', 'Babilônia', 'Basalto'],
      keywords: ['Hamurabi', 'Leis', 'Talião', 'Babilônia'],
      sources: []
    });

    // Queda de Roma
    this.registerNode({
      id: 'evt-queda-roma',
      type: 'EVENTO',
      name: 'Queda do Império Romano do Ocidente',
      summary: 'A deposição de Rômulo Augusto pelo rei bárbaro Odoacro.',
      description: 'Marco divisor definitivo que encerra a Idade Antiga e inicia a Idade Média. O poder romano ocidental fragmentou-se em diversos reinos germânicos (bárbaros), alterando a estrutura de poder, leis e cultura da Europa continental.',
      era: '476 d.C.',
      evidenceLevel: 'high',
      tags: ['Ruptura', 'Roma', 'Idade Média', 'Europa'],
      keywords: ['Roma', 'Odoacro', 'Rômulo Augusto', 'Barbárie'],
      sources: [
        { id: 'src-gibbon', title: 'A História do Declínio e Queda do Império Romano', author: 'Edward Gibbon', year: 1776, type: 'book' }
      ]
    });

    // Rômulo Augusto
    this.registerNode({
      id: 'char-romulo-augusto',
      type: 'PERSONAGEM',
      name: 'Rômulo Augusto',
      summary: 'Último imperador romano do Ocidente, deposto aos 16 anos.',
      description: 'Conhecido ironicamente como "Augustulo" (pequeno Augusto), governou por menos de um ano antes de ser deposto pelo chefe militar germânico Odoacro, que o poupou devido à sua juventude e beleza, enviando-o ao exílio na Campânia.',
      era: '461 d.C. - 511 d.C.',
      evidenceLevel: 'high',
      tags: ['Imperador', 'Queda de Roma', 'Juvenil'],
      keywords: ['Augustulo', 'Odoacro', 'Roma', 'Exílio'],
      sources: []
    });

    // Império Bizantino
    this.registerNode({
      id: 'imp-bizantino',
      type: 'IMPERIO',
      name: 'Império Romano do Oriente (Bizantino)',
      summary: 'A sobrevivência do Império Romano em Constantinopla após a queda do Ocidente.',
      description: 'Enquanto o Ocidente colapsava em reinos fragmentados, o Oriente floresceu por mais de mil anos, preservando a lei e a cultura romana sob forte influência helenística e cristã ortodoxa.',
      era: '330 d.C. - 1453 d.C.',
      evidenceLevel: 'high',
      tags: ['Império', 'Bizâncio', 'Constantinopla', 'Cristianismo'],
      keywords: ['Constantinopla', 'Bizantino', 'Justiniano', 'Roma'],
      sources: []
    });

    // Chegada de Colombo à América
    this.registerNode({
      id: 'evt-descobrimento-america',
      type: 'EVENTO',
      name: 'Chegada de Cristóvão Colombo à América',
      summary: 'A expedição espanhola que avistou terra no continente americano.',
      description: 'Financiada pelos Reis Católicos da Espanha, a viagem de Colombo alterou de forma irreversível os destinos da humanidade, interconectando ecossistemas, economias e populações globais pela primeira vez.',
      era: '1492 d.C.',
      evidenceLevel: 'high',
      tags: ['Navegação', 'América', 'Espanha', 'Globalização'],
      keywords: ['Colombo', 'América', 'Caravelas', 'Novo Mundo'],
      sources: []
    });

    // Tratado de Tordesilhas
    this.registerNode({
      id: 'doc-tordesilhas',
      type: 'TRATADO',
      name: 'Tratado de Tordesilhas',
      summary: 'Acordo diplomático de partilha do novo mundo entre Portugal e Espanha.',
      description: 'Assinado na vila espanhola de Tordesilhas, definiu uma linha de demarcação de 370 léguas a oeste das ilhas de Cabo Verde, garantindo a Portugal o controle de terras no Atlântico Sul (onde posteriormente o Brasil foi descoberto).',
      era: '1494 d.C.',
      evidenceLevel: 'high',
      tags: ['Diplomacia', 'Tratado', 'Portugal', 'Espanha'],
      keywords: ['Tordesilhas', 'Partilha', 'Cabo Verde', 'Bula Papal'],
      sources: []
    });

    // Queda da Bastilha
    this.registerNode({
      id: 'evt-bastilha',
      type: 'EVENTO',
      name: 'Queda da Bastilha',
      summary: 'O assalto popular à prisão-fortaleza real em Paris.',
      description: 'Início simbólico da Revolução Francesa. A tomada da Bastilha, que guardava pólvora e simbolizava a tirania do Absolutismo dos Bourbons, galvanizou o sentimento revolucionário e levou à queda de Luís XVI.',
      era: '1789 d.C.',
      evidenceLevel: 'high',
      tags: ['Revolução', 'França', 'Liberdade', 'Bastilha'],
      keywords: ['Bastilha', 'Revolução Francesa', 'Luís XVI', 'Paris'],
      sources: []
    });

    // Montesquieu
    this.registerNode({
      id: 'char-montesquieu',
      type: 'PERSONAGEM',
      name: 'Montesquieu',
      summary: 'Filósofo e jurista iluminista francês do século XVIII.',
      description: 'Famoso por formular a doutrina constitucional da separação tripartida dos poderes do Estado (Executivo, Legislativo e Judiciário), visando frear o absolutismo real.',
      era: '1689 d.C. - 1755 d.C.',
      evidenceLevel: 'high',
      tags: ['Filosofia', 'Direito', 'Iluminismo'],
      keywords: ['Espírito das Leis', 'Três Poderes', 'Liberdade'],
      sources: [
        { id: 'src-leis', title: 'O Espírito das Leis', author: 'Montesquieu', year: 1748, type: 'book' }
      ]
    });

    // Inconfidência Mineira
    this.registerNode({
      id: 'evt-inconfidencia',
      type: 'EVENTO',
      name: 'Inconfidência Mineira',
      summary: 'Movimento emancipacionista e conspiratório na capitania de Minas Gerais.',
      description: 'Inspirado pelas ideias republicanas francesas e pela independência americana, o grupo liderado por Tiradentes e intelectuais visava libertar o Brasil do domínio colonial português diante da pesada cobrança de impostos (Derrama).',
      era: '1789 d.C.',
      evidenceLevel: 'good',
      tags: ['Insurreição', 'Brasil', 'República', 'Liberdade'],
      keywords: ['Tiradentes', 'Minas Gerais', 'Derrama', 'Ouro'],
      sources: []
    });

    // Corrida Espacial e Pouso na Lua
    this.registerNode({
      id: 'evt-pouso-lua',
      type: 'EVENTO',
      name: 'Pouso da Apollo 11 na Lua',
      summary: 'A conquista do satélite natural terrestre pela tripulação americana.',
      description: 'Em 20 de Julho de 1969, Neil Armstrong e Buzz Aldrin tornaram-se os primeiros seres humanos a caminhar na Lua. O feito representou o ápice tecnológico da Guerra Fria entre os EUA e a União Soviética.',
      era: '1969 d.C.',
      evidenceLevel: 'high',
      tags: ['Espaço', 'Tecnologia', 'Guerra Fria', 'Exploração'],
      keywords: ['Lua', 'Armstrong', 'Apollo 11', 'NASA'],
      sources: []
    });

    // ESTABELECE OS NOVOS RELACIONAMENTOS DO GRAFO
    // César e Pompeu (Inimigos na Guerra Civil)
    this.registerRelationship({
      id: 'rel-cesar-pompeu',
      sourceId: 'char-cesar',
      targetId: 'char-pompeu',
      type: 'ASSOCIATED_WITH',
      description: 'Rivais mortais na Guerra Civil Romana pelo controle supremo de Roma.'
    });

    // César e Cleópatra (Aliança política)
    this.registerRelationship({
      id: 'rel-cesar-cleopatra',
      sourceId: 'char-cesar',
      targetId: 'char-cleopatra',
      type: 'ASSOCIATED_WITH',
      description: 'Aliados políticos e amantes; César ajudou Cleópatra a consolidar o trono do Egito.'
    });

    // Cleópatra e Alexandria
    this.registerRelationship({
      id: 'rel-cleopatra-alexandria',
      sourceId: 'char-cleopatra',
      targetId: 'city-alexandria',
      type: 'LOCATED_AT',
      description: 'Governava o reino a partir do palácio real em Alexandria.'
    });

    // Alexandria e Biblioteca de Alexandria
    this.registerRelationship({
      id: 'rel-alexandria-biblioteca',
      sourceId: 'const-biblioteca-alexandria',
      targetId: 'city-alexandria',
      type: 'LOCATED_AT',
      description: 'Construída na zona real da cidade.'
    });

    // Odoacro e Rômulo Augusto
    this.registerRelationship({
      id: 'rel-romulo-queda',
      sourceId: 'char-romulo-augusto',
      targetId: 'evt-queda-roma',
      type: 'PARTICIPATED_IN',
      description: 'Último imperador romano do Ocidente deposto durante o colapso imperial.'
    });

    // Queda de Roma e Império Bizantino
    this.registerRelationship({
      id: 'rel-queda-bizantino',
      sourceId: 'evt-queda-roma',
      targetId: 'imp-bizantino',
      type: 'ASSOCIATED_WITH',
      description: 'A queda do Ocidente consagrou a independência de Constantinopla como herdeira de Roma.'
    });

    // Colombo e Tratado de Tordesilhas
    this.registerRelationship({
      id: 'rel-colombo-tratado',
      sourceId: 'evt-descobrimento-america',
      targetId: 'doc-tordesilhas',
      type: 'INFLUENCED',
      description: 'A descoberta do Novo Mundo precipitou a redação diplomática do Tratado de Tordesilhas.'
    });

    // Montesquieu e Revolução Francesa (Queda da Bastilha)
    this.registerRelationship({
      id: 'rel-montesquieu-iluminismo',
      sourceId: 'char-montesquieu',
      targetId: 'evt-bastilha',
      type: 'INFLUENCED',
      description: 'Suas ideias de equilíbrio de poderes inspiraram os revolucionários franceses de 1789.'
    });

    // Queda da Bastilha (Revolução Francesa) e Inconfidência Mineira
    this.registerRelationship({
      id: 'rel-iluminismo-inconfidencia',
      sourceId: 'evt-bastilha',
      targetId: 'evt-inconfidencia',
      type: 'INFLUENCED',
      description: 'O fermento intelectual francês cruzou o Atlântico e inspirou os poetas inconfidentes no Brasil colonial.'
    });

    // Suméria e Escrita Cuneiforme
    this.registerRelationship({
      id: 'rel-sumeria-escrita',
      sourceId: 'civ-sumeria',
      targetId: 'tech-cuneiforme',
      type: 'CREATED_TECH',
      description: 'A civilização suméria criou o sistema de escrita para sua contabilidade estatal.'
    });

    // Escrita Cuneiforme e Código de Hamurabi
    this.registerRelationship({
      id: 'rel-escrita-leis',
      sourceId: 'tech-cuneiforme',
      targetId: 'doc-hamurabi',
      type: 'ASSOCIATED_WITH',
      description: 'As leis do Código de Hamurabi foram registradas usando a escrita cuneiforme babilônica.'
    });
  }
}
