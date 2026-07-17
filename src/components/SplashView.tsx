/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useEffect } from 'react';
import { motion } from 'motion/react';
import { Compass, Clock } from 'lucide-react';

interface SplashViewProps {
  onComplete: () => void;
}

export default function SplashView({ onComplete }: SplashViewProps) {
  useEffect(() => {
    const timer = setTimeout(() => {
      onComplete();
    }, 3000);
    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <div id="splash-container" className="min-h-screen bg-slate-950 flex flex-col items-center justify-between p-8 text-white select-none">
      <div className="flex-1 flex flex-col items-center justify-center">
        <motion.div
          id="splash-logo-wrapper"
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 1, ease: 'easeOut' }}
          className="relative mb-6"
        >
          {/* Astrolabe/Sundial effect using concentric styled borders */}
          <div className="absolute inset-0 bg-amber-500/10 blur-xl rounded-full" />
          <div className="relative bg-slate-900 border-2 border-amber-500/40 p-6 rounded-full shadow-2xl flex items-center justify-center">
            {/* Outer ring of the astrolabe */}
            <div className="absolute inset-2 border border-dashed border-amber-500/20 rounded-full animate-spin [animation-duration:40s]" />
            <div className="absolute inset-3 border border-amber-500/10 rounded-full" />
            <Clock className="w-12 h-12 text-amber-500 stroke-[1.2] animate-pulse" />
            <Compass className="w-6 h-6 text-amber-400 stroke-[1.5] absolute" />
          </div>
        </motion.div>

        <motion.h1
          id="splash-title"
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.8 }}
          className="text-5xl font-serif tracking-widest text-amber-100 font-bold mb-2 text-center"
        >
          CHRONOS
        </motion.h1>

        <motion.p
          id="splash-subtitle"
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.8 }}
          transition={{ delay: 0.6, duration: 0.8 }}
          className="text-amber-400/80 font-mono text-xs tracking-widest uppercase text-center max-w-xs leading-relaxed"
        >
          Conhecimento através do tempo
        </motion.p>
      </div>

      <motion.div
        id="splash-footer"
        initial={{ opacity: 0 }}
        animate={{ opacity: 0.6 }}
        transition={{ delay: 1, duration: 1 }}
        className="max-w-md text-center"
      >
        <p className="text-[10px] font-mono tracking-widest uppercase text-amber-200/40 mb-1">
          Navegação de Evidências Históricas
        </p>
        <p className="text-xs font-serif italic text-amber-100/50">
          "Para compreender o presente e navegar pelas eras, iluminamos os pergaminhos da verdade científica."
        </p>
      </motion.div>
    </div>
  );
}
