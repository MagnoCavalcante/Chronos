/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

export type Screen = 'SPLASH' | 'WELCOME' | 'LOGIN' | 'REGISTER' | 'FORGOT_PASSWORD' | 'TIME_TRAVEL' | 'HOME' | 'PROFILE' | 'SETTINGS';

export type Tab = 'home' | 'search' | 'mitologia' | 'saved' | 'profile' | 'settings';

export interface User {
  name: string;
  email: string;
  xp: number;
  level: number;
  streak: number;
  joinedDate: string;
}

export type EvidenceLevel = 'high' | 'good' | 'debate' | 'hypothesis' | 'mythological';

export interface Source {
  id: string;
  title: string;
  author: string;
  year: number;
  type: 'book' | 'article' | 'document' | 'archaeological' | 'myth';
  url?: string;
  details?: string; // e.g., "Páginas 45-60, Cap. III"
}

// CHRONOS KNOWLEDGE GRAPH ONTOLOGY
export type EntityType =
  | 'PERSONAGEM'
  | 'EVENTO'
  | 'CIVILIZACAO'
  | 'IMPERIO'
  | 'GUERRA'
  | 'TRATADO'
  | 'PAIS'
  | 'CIDADE'
  | 'RELIGIAO'
  | 'FILOSOFIA'
  | 'MOVIMENTO'
  | 'TECNOLOGIA'
  | 'OBJETO_HISTORICO'
  | 'CONSTRUCAO'
  | 'LIVRO'
  | 'DOCUMENTO'
  | 'FONTE'
  | 'AUTOR'
  | 'DESCOBERTA'
  | 'DATA'
  | 'PERIODO_HISTORICO'
  | 'MITOLOGIA'
  | 'DEUS'
  | 'CRIATURA_MITOLOGICA'
  | 'ARTEFATO_MITOLOGICO';

export type RelationshipType =
  | 'PARTICIPATED_IN'       // Personagem participou de Evento
  | 'OCCURRED_IN'           // Evento ocorreu em Cidade / Local
  | 'BELONGS_TO'            // Cidade pertence a País
  | 'PART_OF_CIVILIZATION'  // País pertence a Civilização
  | 'HAS_BATTLE'            // Guerra possui Batalhas
  | 'CITES_DOCUMENT'        // Livro cita Documento
  | 'PROVES_EVENT'          // Documento comprova Evento
  | 'WROTE_BOOK'            // Autor escreveu Livro
  | 'REFERENCES_THEME'      // Tema / Tópico referencia Personagem
  | 'INFLUENCED'            // Personagem influenciou outro / Movimento influenciou outro Movimento
  | 'RULED_EMPIRE'          // Personagem governou Império / Civilização
  | 'CREATED_TECH'          // Personagem / Civilização criou Tecnologia / Descoberta
  | 'CONSTRUCTED_BY'        // Construção erguida por Civilização
  | 'LOCATED_AT'            // Construção localizada em Cidade
  | 'TEMPORAL_ANCHOR'       // Evento / Personagem ancorado a uma Data ou Período Histórico
  | 'BELONGS_TO_MYTHOLOGY'  // Deus, Criatura ou Artefato pertence a Mitologia
  | 'ASSOCIATED_WITH';      // Associação genérica ou conceitual

export interface KGNode {
  id: string;
  type: EntityType;
  name: string;
  summary: string;
  description: string;
  justification?: string;         // Historiographical consensus justification
  imageUrl?: string;
  era: string;                    // Era of relevance / temporal localization
  evidenceLevel: EvidenceLevel;   // Level of scientific proof or mythological tag
  tags: string[];
  keywords: string[];
  sources: Source[];              // Primary or secondary sources proving this entity
  metadata?: Record<string, any>; // Specific attributes (e.g. coordinates, dates, duration)
}

export interface KGRelationship {
  id: string;
  sourceId: string;
  targetId: string;
  type: RelationshipType;
  description: string;            // Descriptive label of the relation (e.g. "comprovado por", "líder de")
  evidenceLevel?: EvidenceLevel;  // Reliability level of the connection itself
}

// Semantic Query Interface for AI Historiador and Interactive Timelines
export interface KGQuery {
  types?: EntityType[];
  tags?: string[];
  keywords?: string[];
  evidenceLevel?: EvidenceLevel;
  temporalStart?: string;
  temporalEnd?: string;
}

// Unified Knowledge Graph Representation
export interface CHRONOSKnowledgeGraph {
  nodes: Map<string, KGNode>;
  relationships: KGRelationship[];
}

export interface HistoryCard {
  id: string;
  category: 'História';
  period: 'Antiguidade' | 'Idade Média' | 'Idade Moderna';
  title: string;
  era: string;
  summary: string;
  evidenceLevel: EvidenceLevel;
  timeline: { year: string; event: string }[];
  characters: { name: string; role: string; bio: string }[];
  fact: {
    title: string;
    description: string;
  };
  interpretation: {
    title: string;
    description: string;
  };
  hypothesis: {
    title: string;
    description: string;
  };
  sources: Source[];
}

