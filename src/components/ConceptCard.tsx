/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import {
  BookOpen,
  Calendar,
  HelpCircle,
  GraduationCap,
  Quote,
  Compass,
  ExternalLink,
  Bookmark,
  Sparkles,
  Check,
  Clock,
  Users,
  FileText,
  Info,
  X
} from 'lucide-react';
import { HistoryCard, EvidenceLevel } from '../types';

interface ConceptCardProps {
  card: HistoryCard;
  onMasterCard: (id: string, xpEarned: number) => void;
  isMastered: boolean;
  key?: string;
}

type CardTab = 'resumo' | 'fatos' | 'interpretacoes' | 'linha' | 'personagens' | 'fontes';

export default function ConceptCard({ card, onMasterCard, isMastered }: ConceptCardProps) {
  const [activeTab, setActiveTab] = useState<CardTab>('resumo');
  const [isSaved, setIsSaved] = useState(false);
  const [showHowWeKnowModal, setShowHowWeKnowModal] = useState(false);

  const getEvidenceDetails = (level: EvidenceLevel) => {
    switch (level) {
      case 'high':
        return {
          label: 'Alto consenso histórico',
          description: 'Sustentado por ampla documentação consensual e evidências empíricas.',
          badge: 'bg-emerald-50 text-emerald-900 border-emerald-200/60',
          dot: 'bg-emerald-500'
        };
      case 'good':
        return {
          label: 'Bom nível de evidência',
          description: 'Informação amplamente aceita, embora com nuances ou pequenas divergências acadêmicas.',
          badge: 'bg-yellow-50 text-yellow-900 border-yellow-200/60',
          dot: 'bg-yellow-500'
        };
      case 'debate':
        return {
          label: 'Tema em debate',
          description: 'Interpretações concorrentes válidas baseadas em diferentes leituras das fontes.',
          badge: 'bg-amber-50 text-amber-900 border-amber-200/60',
          dot: 'bg-amber-500'
        };
      case 'hypothesis':
        return {
          label: 'Hipótese histórica',
          description: 'Teoria plausível pendente de confirmação material ou documental conclusiva.',
          badge: 'bg-rose-50 text-rose-900 border-rose-200/60',
          dot: 'bg-rose-500'
        };
    }
  };

  const evidence = getEvidenceDetails(card.evidenceLevel);

  return (
    <div
      id={`concept-card-${card.id}`}
      className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden flex flex-col hover:shadow-md transition-all duration-300 bg-linear-to-b from-white to-slate-50/20"
    >
      {/* Card Header */}
      <div className="p-6 border-b border-slate-100">
        <div className="flex justify-between items-start gap-4 mb-3">
          <div className="flex flex-wrap gap-2 items-center">
            {/* Reliability Badge */}
            <div
              className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-mono font-semibold border ${evidence.badge}`}
              title={evidence.description}
            >
              <span className={`w-1.5 h-1.5 rounded-full ${evidence.dot}`} />
              <span>{evidence.label}</span>
            </div>

            <span className="text-slate-400 font-mono text-[10px] flex items-center gap-1">
              <Calendar className="w-3 h-3" />
              {card.era}
            </span>
          </div>

          <button
            id={`save-btn-${card.id}`}
            onClick={() => setIsSaved(!isSaved)}
            className={`p-1.5 rounded-lg border transition-all ${
              isSaved
                ? 'bg-amber-50 text-amber-600 border-amber-200'
                : 'text-slate-400 border-slate-200 hover:text-slate-600 hover:bg-slate-50'
            }`}
            title={isSaved ? 'Remover dos favoritos' : 'Salvar nas referências de estudo'}
          >
            <Bookmark className={`w-3.5 h-3.5 ${isSaved ? 'fill-current' : ''}`} />
          </button>
        </div>

        <h3 className="text-xl font-serif font-bold text-slate-900 leading-snug">
          {card.title}
        </h3>
      </div>

      {/* Internal Tabs Navigator - 6 premium tabs */}
      <div className="flex border-b border-slate-100 font-mono text-[10px] tracking-wider uppercase font-semibold text-slate-500 overflow-x-auto bg-slate-50/40 divide-x divide-slate-100 scrollbar-none">
        <button
          onClick={() => setActiveTab('resumo')}
          className={`flex-1 min-w-[80px] py-3 text-center border-b-2 transition-all ${
            activeTab === 'resumo' ? 'border-amber-500 text-amber-900 bg-white font-bold' : 'border-transparent hover:text-slate-800'
          }`}
        >
          Resumo
        </button>
        <button
          onClick={() => setActiveTab('fatos')}
          className={`flex-1 min-w-[80px] py-3 text-center border-b-2 transition-all ${
            activeTab === 'fatos' ? 'border-amber-500 text-amber-900 bg-white font-bold' : 'border-transparent hover:text-slate-800'
          }`}
        >
          Fatos
        </button>
        <button
          onClick={() => setActiveTab('interpretacoes')}
          className={`flex-1 min-w-[100px] py-3 text-center border-b-2 transition-all ${
            activeTab === 'interpretacoes' ? 'border-amber-500 text-amber-900 bg-white font-bold' : 'border-transparent hover:text-slate-800'
          }`}
        >
          Interpretações
        </button>
        <button
          onClick={() => setActiveTab('linha')}
          className={`flex-1 min-w-[80px] py-3 text-center border-b-2 transition-all ${
            activeTab === 'linha' ? 'border-amber-500 text-amber-900 bg-white font-bold' : 'border-transparent hover:text-slate-800'
          }`}
        >
          Linha do Tempo
        </button>
        <button
          onClick={() => setActiveTab('personagens')}
          className={`flex-1 min-w-[90px] py-3 text-center border-b-2 transition-all ${
            activeTab === 'personagens' ? 'border-amber-500 text-amber-900 bg-white font-bold' : 'border-transparent hover:text-slate-800'
          }`}
        >
          Personagens
        </button>
        <button
          onClick={() => setActiveTab('fontes')}
          className={`flex-1 min-w-[80px] py-3 text-center border-b-2 transition-all ${
            activeTab === 'fontes' ? 'border-amber-500 text-amber-900 bg-white font-bold' : 'border-transparent hover:text-slate-800'
          }`}
        >
          Fontes
        </button>
      </div>

      {/* Tab Contents */}
      <div className="p-6 flex-1 min-h-[180px] bg-white flex flex-col justify-between">
        <AnimatePresence mode="wait">
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, y: 4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -4 }}
            transition={{ duration: 0.12 }}
            className="text-sm text-slate-700 leading-relaxed"
          >
            {activeTab === 'resumo' && (
              <div className="space-y-3">
                <p className="font-serif text-slate-800 text-base leading-relaxed">
                  {card.summary}
                </p>
                <div className="text-[11px] font-mono text-slate-500 bg-slate-50 p-2.5 rounded-lg border border-slate-100/60">
                  <span className="font-semibold text-slate-700">Abordagem:</span> Esta investigação foca no cruzamento de dados arqueológicos e fontes textuais contemporâneas.
                </div>
              </div>
            )}

            {activeTab === 'fatos' && (
              <div className="space-y-3">
                <div className="flex items-center gap-1.5 text-xs font-mono font-bold text-amber-800 uppercase tracking-wider">
                  <GraduationCap className="w-4 h-4" />
                  <span>Consenso Histórico e Arqueológico</span>
                </div>
                <p className="font-serif text-slate-800 text-sm leading-relaxed">
                  {card.fact.description}
                </p>
              </div>
            )}

            {activeTab === 'interpretacoes' && (
              <div className="space-y-3">
                <div className="flex items-center gap-1.5 text-xs font-mono font-bold text-slate-700 uppercase tracking-wider">
                  <Quote className="w-4 h-4 text-amber-600" />
                  <span>Leituras Historiográficas e Análise</span>
                </div>
                <p className="font-serif text-slate-800 text-sm leading-relaxed">
                  {card.interpretation.description}
                </p>
                {card.hypothesis.description && (
                  <div className="mt-4 pt-3 border-t border-slate-100">
                    <span className="text-[10px] font-mono font-bold text-slate-400 uppercase tracking-widest block mb-1">Hipóteses Acadêmicas Atuais</span>
                    <p className="font-serif text-xs text-slate-600 italic leading-relaxed">{card.hypothesis.description}</p>
                  </div>
                )}
              </div>
            )}

            {activeTab === 'linha' && (
              <div className="space-y-4">
                <div className="flex items-center gap-1.5 text-xs font-mono font-bold text-slate-700 uppercase tracking-wider">
                  <Clock className="w-4 h-4 text-amber-600" />
                  <span>Linha do Tempo de Evidências</span>
                </div>
                <div className="space-y-3 border-l border-slate-100 pl-3.5 ml-1.5 pt-1">
                  {card.timeline && card.timeline.length > 0 ? (
                    card.timeline.map((evt, idx) => (
                      <div key={idx} className="relative text-xs">
                        <div className="absolute -left-[20px] top-1.5 w-2.5 h-2.5 rounded-full bg-amber-500 border-2 border-white shadow-xs" />
                        <span className="font-mono font-bold text-amber-700">{evt.year}</span>
                        <p className="font-serif text-slate-700 mt-0.5">{evt.event}</p>
                      </div>
                    ))
                  ) : (
                    <p className="text-xs text-slate-400 italic">Cronograma de eventos em catalogação.</p>
                  )}
                </div>
              </div>
            )}

            {activeTab === 'personagens' && (
              <div className="space-y-4">
                <div className="flex items-center gap-1.5 text-xs font-mono font-bold text-slate-700 uppercase tracking-wider">
                  <Users className="w-4 h-4 text-amber-600" />
                  <span>Agentes Históricos Clave</span>
                </div>
                <div className="grid grid-cols-1 gap-2.5">
                  {card.characters && card.characters.length > 0 ? (
                    card.characters.map((char, idx) => (
                      <div key={idx} className="p-3 bg-slate-50 border border-slate-100 rounded-xl">
                        <span className="font-serif font-bold text-slate-900 text-xs block">{char.name}</span>
                        <span className="font-mono text-[9px] uppercase text-slate-400 font-semibold tracking-wide">{char.role}</span>
                        <p className="font-serif text-xs text-slate-600 mt-1 leading-normal">{char.bio}</p>
                      </div>
                    ))
                  ) : (
                    <p className="text-xs text-slate-400 italic">Personagens proeminentes em catalogação documental.</p>
                  )}
                </div>
              </div>
            )}

            {activeTab === 'fontes' && (
              <div className="space-y-3">
                <div className="flex items-center gap-1.5 text-xs font-mono font-bold text-slate-700 uppercase tracking-wider">
                  <BookOpen className="w-4 h-4 text-amber-600" />
                  <span>Principais Fontes Catalogadas</span>
                </div>
                <div className="space-y-2 max-h-[160px] overflow-y-auto pr-1">
                  {card.sources.map((src) => (
                    <div key={src.id} className="p-2.5 rounded-xl bg-slate-50 border border-slate-100 flex items-start justify-between gap-3 text-xs">
                      <div className="min-w-0 flex-1">
                        <div className="font-semibold text-slate-900 flex items-center gap-1.5">
                          <span className="text-[9px] font-mono font-bold uppercase tracking-wider bg-slate-200 text-slate-700 px-1 py-0.2 rounded shrink-0">
                            {src.type === 'book' ? 'Livro' : src.type === 'document' ? 'Manuscrito' : src.type === 'archaeological' ? 'Arqueologia' : 'Artigo'}
                          </span>
                          <span className="truncate">{src.title}</span>
                        </div>
                        <div className="text-slate-500 font-medium text-[10px] mt-0.5">
                          {src.author} ({src.year}) {src.details && `• ${src.details}`}
                        </div>
                      </div>
                      {src.url && (
                        <a
                          href={src.url}
                          target="_blank"
                          referrerPolicy="no-referrer"
                          rel="noreferrer"
                          className="p-1 rounded-lg hover:bg-slate-200 text-slate-400 hover:text-slate-600 transition-colors shrink-0"
                          title="Consultar arquivo"
                        >
                          <ExternalLink className="w-3 h-3" />
                        </a>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </motion.div>
        </AnimatePresence>

        {/* Footer Actions */}
        <div className="mt-6 pt-4 border-t border-slate-100 flex flex-wrap gap-3 items-center justify-between">
          {/* Main differentiator button "Como sabemos disso?" */}
          <button
            id={`how-we-know-btn-${card.id}`}
            onClick={() => setShowHowWeKnowModal(true)}
            className="inline-flex items-center gap-1.5 text-xs font-sans font-semibold text-amber-700 hover:text-amber-800 bg-amber-50 hover:bg-amber-100 border border-amber-200/50 px-3 py-1.5 rounded-lg transition-all"
          >
            <FileText className="w-3.5 h-3.5 shrink-0" />
            <span>Como sabemos disso?</span>
          </button>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-0.5 font-mono text-[10px] text-slate-400 font-bold bg-slate-100 px-2.5 py-1 rounded-full">
              <Sparkles className="w-3 h-3 text-amber-500" />
              <span>+30 XP</span>
            </div>

            <button
              id={`master-btn-${card.id}`}
              onClick={() => onMasterCard(card.id, 30)}
              disabled={isMastered}
              className={`text-xs font-medium py-1.5 px-3 rounded-lg transition-all flex items-center gap-1.5 ${
                isMastered
                  ? 'bg-emerald-50 text-emerald-700 border border-emerald-100 font-semibold cursor-default'
                  : 'bg-slate-900 text-white hover:bg-amber-600 hover:text-white hover:shadow-xs'
              }`}
            >
              {isMastered ? (
                <>
                  <Check className="w-3.5 h-3.5" />
                  <span>Estudado</span>
                </>
              ) : (
                <>
                  <Compass className="w-3.5 h-3.5" />
                  <span>Concluir</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>

      {/* "Como sabemos disso?" Archival Modal Overlay */}
      <AnimatePresence>
        {showHowWeKnowModal && (
          <div className="fixed inset-0 bg-slate-950/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 10 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 10 }}
              transition={{ duration: 0.18 }}
              className="bg-white rounded-2xl max-w-lg w-full overflow-hidden shadow-2xl border border-slate-200 flex flex-col max-h-[85vh]"
            >
              {/* Modal Header */}
              <div className="p-6 border-b border-slate-100 bg-slate-50 flex justify-between items-center">
                <div className="flex items-center gap-2">
                  <div className="p-2 bg-amber-500 text-white rounded-lg">
                    <Compass className="w-5 h-5 stroke-[1.5]" />
                  </div>
                  <div>
                    <h4 className="font-serif font-bold text-slate-900 text-lg leading-tight">Como sabemos disso?</h4>
                    <p className="text-[10px] font-mono text-slate-400 uppercase tracking-widest mt-0.5">Transparência de evidência científica</p>
                  </div>
                </div>
                <button
                  onClick={() => setShowHowWeKnowModal(false)}
                  className="p-1.5 rounded-lg border border-slate-200 text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              {/* Modal Body */}
              <div className="p-6 overflow-y-auto space-y-5 text-sm text-slate-700 leading-relaxed font-serif">
                <div className="bg-amber-50/50 border border-amber-100 rounded-xl p-4 flex gap-3">
                  <Info className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                  <div className="text-xs text-amber-900 leading-relaxed font-sans font-medium">
                    As informações neste tópico foram compostas rigorosamente a partir da leitura e síntese de registros primários e secundários reconhecidos pela comunidade científica, sem cópia literal.
                  </div>
                </div>

                <div className="space-y-3 font-sans">
                  <h5 className="text-xs font-mono font-bold text-slate-400 uppercase tracking-widest">Base de Evidências Usada</h5>
                  <p className="text-xs text-slate-500 font-serif mb-4">
                    Estes são os documentos originais, livros recomendados de acadêmicos e achados arqueológicos em que nos baseamos para sintetizar este tema:
                  </p>

                  <div className="space-y-3">
                    {card.sources.map((src) => (
                      <div key={src.id} className="p-4 rounded-xl border border-slate-200/80 bg-slate-50 flex items-start gap-3">
                        <div className="p-2 bg-white rounded-lg border border-slate-100 shadow-2xs text-amber-600 shrink-0">
                          <BookOpen className="w-4 h-4" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-1.5 flex-wrap">
                            <span className="text-[8px] font-mono font-bold uppercase tracking-widest bg-slate-200 text-slate-700 px-1.5 py-0.5 rounded">
                              {src.type === 'book' ? 'Livro' : src.type === 'document' ? 'Manuscrito' : src.type === 'archaeological' ? 'Arqueologia' : 'Artigo'}
                            </span>
                            <span className="font-sans font-bold text-slate-900 text-xs truncate">{src.title}</span>
                          </div>
                          <p className="text-[11px] text-slate-500 font-sans mt-1">
                            Autor: <strong className="text-slate-700 font-semibold">{src.author}</strong> ({src.year})
                          </p>
                          {src.details && (
                            <p className="text-[10px] text-amber-800 font-sans font-medium mt-1 bg-amber-50/60 inline-block px-2 py-0.5 rounded">
                              Especificação: {src.details}
                            </p>
                          )}
                        </div>
                        {src.url && (
                          <a
                            href={src.url}
                            target="_blank"
                            referrerPolicy="no-referrer"
                            rel="noreferrer"
                            className="p-1.5 rounded-lg hover:bg-slate-200 text-slate-400 hover:text-slate-600 transition-colors shrink-0"
                          >
                            <ExternalLink className="w-3.5 h-3.5" />
                          </a>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                <div className="pt-4 border-t border-slate-100 font-sans text-xs text-slate-400 text-center">
                  Consulte os links externos para acessar artigos originais ou traduções de manuscritos na íntegra.
                </div>
              </div>

              {/* Modal Footer */}
              <div className="p-4 border-t border-slate-100 bg-slate-50 flex justify-end">
                <button
                  onClick={() => setShowHowWeKnowModal(false)}
                  className="bg-slate-900 hover:bg-slate-800 text-white font-medium text-xs py-2 px-5 rounded-xl transition-all"
                >
                  Entendi, fechar
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
