/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { BookOpen, Compass, ShieldCheck, RefreshCw, ChevronRight, AlertCircle, Sparkles } from 'lucide-react';
import { Screen } from '../types';

interface WelcomeViewProps {
  onNavigate: (screen: Screen) => void;
}

export default function WelcomeView({ onNavigate }: WelcomeViewProps) {
  const [currentSlide, setCurrentSlide] = useState(0);

  const slides = [
    {
      icon: <Compass className="w-12 h-12 text-amber-500" />,
      title: "Navegação Temporal e Científica",
      subtitle: "Nossa Filosofia",
      description: "CHRONOS permite que você viaje pelas eras da humanidade por meio de investigações rigorosas, distinguindo fatos históricos comprovados de interpretações e hipóteses académicas.",
      highlight: "Passagem do Tempo e Evidências"
    },
    {
      icon: <ShieldCheck className="w-12 h-12 text-teal-500" />,
      title: "Ceticismo e Rigor Bibliográfico",
      subtitle: "Instrumento de Descoberta",
      description: "Toda passagem histórica e documento catalogado no CHRONOS possui correspondência com fontes primárias, manuscritos antigos e relatórios arqueológicos consolidados.",
      highlight: "Transparência de Fontes"
    },
    {
      icon: <BookOpen className="w-12 h-12 text-indigo-500" />,
      title: "Estudo Separado das Mitologias",
      subtitle: "Rigor Intelectual",
      description: "Diferenciamos as narrativas míticas e religiosas do fato histórico documental. Estudamos as mitologias como tesouros da cultura humana e de suas tradições literárias.",
      highlight: "História Viva vs. Tradições Culturais"
    },
    {
      icon: <RefreshCw className="w-12 h-12 text-emerald-500" />,
      title: "Conhecimento Através do Tempo",
      subtitle: "Slogan Oficial",
      description: "Navegue pelo astrolábio do conhecimento. Nosso banco de dados se ajusta conforme novas escavações e traduções de manuscritos revelam novas verdades científicas.",
      highlight: "Conhecimento através do tempo"
    }
  ];

  const handleNext = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(prev => prev + 1);
    } else {
      onNavigate('LOGIN');
    }
  };

  const handleBack = () => {
    if (currentSlide > 0) {
      setCurrentSlide(prev => prev - 1);
    }
  };

  return (
    <div id="welcome-container" className="min-h-screen bg-slate-50 flex flex-col justify-between p-6 text-slate-800">
      {/* Header with mini-logo */}
      <header id="welcome-header" className="flex items-center justify-between py-4">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-slate-900 flex items-center justify-center text-amber-400 font-serif font-bold text-lg border border-slate-800">
            C
          </div>
          <span className="font-serif font-bold text-lg text-slate-900 tracking-wider">CHRONOS</span>
        </div>
        <button
          id="skip-button"
          onClick={() => onNavigate('LOGIN')}
          className="text-xs font-mono tracking-wider text-slate-500 hover:text-amber-600 transition-colors uppercase font-semibold"
        >
          Pular
        </button>
      </header>

      {/* Slide Content */}
      <main id="welcome-slide-wrapper" className="flex-1 flex flex-col justify-center max-w-md mx-auto w-full my-8">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentSlide}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3 }}
            className="flex flex-col text-center items-center"
          >
            <div className="p-4 bg-white rounded-2xl shadow-sm border border-slate-100 mb-6 relative">
              {slides[currentSlide].icon}
              <div className="absolute -top-1 -right-1 bg-amber-100 text-amber-800 text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center gap-1 border border-amber-200">
                <Sparkles className="w-2.5 h-2.5" />
                <span>Pilar {currentSlide + 1}</span>
              </div>
            </div>

            <span className="text-amber-600 font-mono text-xs uppercase tracking-widest font-semibold mb-2">
              {slides[currentSlide].subtitle}
            </span>

            <h2 className="text-2xl font-serif font-bold text-slate-900 leading-tight mb-4">
              {slides[currentSlide].title}
            </h2>

            <p className="text-slate-600 text-sm leading-relaxed mb-6">
              {slides[currentSlide].description}
            </p>

            <div className="bg-amber-50 border border-amber-100 rounded-xl p-3 text-amber-900 text-xs font-medium inline-flex items-center gap-2 max-w-xs text-left">
              <AlertCircle className="w-4 h-4 text-amber-600 shrink-0" />
              <span>{slides[currentSlide].highlight}</span>
            </div>
          </motion.div>
        </AnimatePresence>
      </main>

      {/* Footer controls */}
      <footer id="welcome-footer" className="max-w-md mx-auto w-full flex flex-col gap-6 pb-6">
        {/* Progress indicators */}
        <div className="flex justify-center gap-2">
          {slides.map((_, idx) => (
            <button
              key={idx}
              onClick={() => setCurrentSlide(idx)}
              className={`h-2 rounded-full transition-all duration-300 ${
                idx === currentSlide ? 'w-6 bg-amber-500' : 'w-2 bg-slate-200'
              }`}
              aria-label={`Slide ${idx + 1}`}
            />
          ))}
        </div>

        {/* Action Buttons */}
        <div className="flex gap-3">
          {currentSlide > 0 && (
            <button
              id="back-button"
              onClick={handleBack}
              className="px-5 py-3 rounded-xl border border-slate-200 font-medium text-sm text-slate-600 hover:bg-slate-100 transition-colors"
            >
              Voltar
            </button>
          )}
          <button
            id="next-button"
            onClick={handleNext}
            className="flex-1 bg-slate-900 hover:bg-slate-800 active:bg-slate-950 text-white font-medium text-sm py-3 px-5 rounded-xl transition-all duration-200 flex items-center justify-center gap-2 shadow-md shadow-slate-900/10"
          >
            <span>{currentSlide === slides.length - 1 ? "Entrar na Plataforma" : "Avançar"}</span>
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </footer>
    </div>
  );
}
