/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useRef, useMemo } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Compass, Clock, Cpu, Shield, Flame, Globe, BookOpen, Hourglass, Sparkles, ChevronRight, Volume2, VolumeX } from 'lucide-react';

interface TimeTravelViewProps {
  onComplete: () => void;
  targetYear?: number;
}

interface HistoricalEra {
  id: string;
  name: string;
  subtitle: string;
  description: string;
  startYear: number;
  endYear: number;
  icon: React.ReactNode;
  colorClass: string;
}

const eraFacts: Record<string, string[]> = {
  contemporanea: [
    "O primeiro satélite artificial, Sputnik 1 (1957), pesava apenas 83 kg e transmitia um bipe de rádio simples ouvido no mundo todo.",
    "O computador de navegação da Apollo 11 tinha menos poder de processamento do que um relógio digital ou chaveiro moderno.",
    "A primeira mensagem enviada pela internet foi 'LO'. O remetente tentava escrever 'LOGIN', mas o sistema caiu antes do 'G'."
  ],
  iluminismo: [
    "Denis Diderot dedicou 26 anos de sua vida para organizar os 28 volumes da pioneira 'Encyclopédie' iluminista.",
    "As cafeterias do século XVIII eram apelidadas de 'Universidades de um Centavo' por conta dos fervorosos debates políticos.",
    "A Declaração dos Direitos do Homem de 1789 inspirou-se na abolição do absolutismo e no ideal de igualdade civil."
  ],
  moderna: [
    "A famosa nau 'Santa Maria' de Colombo tinha cerca de 19 metros, sendo mais curta que muitos barcos de turismo atuais.",
    "Leonardo da Vinci escrevia em espelho (escrita especular), possivelmente para evitar borrões ou proteger suas ideias secretas.",
    "Em 1518, a misteriosa 'Epidemia de Dança' em Estrasburgo fez centenas de pessoas dançarem sem parar por semanas na rua."
  ],
  media: [
    "Na Idade Média, os livros eram tão raros e valiosos que eram acorrentados às mesas de leitura das bibliotecas.",
    "A Universidade de Bolonha, fundada em 1088 d.C., é reconhecida como a mais antiga do mundo ocidental em atividade contínua.",
    "Sábios e filósofos instruídos da época medieval sabiam perfeitamente que a Terra era uma esfera, herdando a ciência grega."
  ],
  classica: [
    "A lendária Biblioteca de Alexandria confiscava os manuscritos originais de todos os navios estrangeiros que atracavam no porto.",
    "Júlio César foi sequestrado por piratas na juventude, zombou do baixo valor de resgate e avisou que iria crucificá-los depois (e cumpriu).",
    "A palavra 'idiota' na Grécia Antiga referia-se originalmente ao cidadão comum que ignorava ou se recusava a participar da vida política pública."
  ],
  oriental: [
    "A escrita cuneiforme suméria desenvolveu-se inicialmente para fins contábeis, registrando cevada, gado e transações rituais.",
    "A Epopeia de Gilgamesh, gravada em tabuletas de argila mesopotâmicas, é a obra de literatura narrativa mais antiga da humanidade.",
    "Os médicos do Antigo Egito utilizavam mel como um cicatrizante e bactericida natural em curativos cirúrgicos."
  ],
  prehistoria: [
    "Os pintores rupestres de Lascaux misturavam minerais triturados com saliva e gordura animal para fixar as cores na rocha.",
    "O complexo monumental de Göbekli Tepe (c. 9500 a.C.) na Turquia é milhares de anos anterior ao surgimento da cerâmica ou da escrita.",
    "A Revolução Agrícola no Crescente Fértil começou há cerca de 10.000 anos, reconfigurando permanentemente o cérebro e a sociedade humana."
  ]
};

export default function TimeTravelView({ onComplete, targetYear = -10000 }: TimeTravelViewProps) {
  const [isPlaying, setIsPlaying] = useState(true);
  const [isMuted, setIsMuted] = useState(false);
  const [currentYear, setCurrentYear] = useState(2026);
  const [currentEraText, setCurrentEraText] = useState('Era Contemporânea');
  const [progress, setProgress] = useState(0); // 0 to 1
  const [isLanding, setIsLanding] = useState(false);
  const [currentFact, setCurrentFact] = useState('');
  const factIndexRef = useRef(0);

  const requestRef = useRef<number | null>(null);
  const startTimeRef = useRef<number | null>(null);
  const timeoutRef = useRef<any>(null);
  const hasEndedRef = useRef<boolean>(false);
  const duration = 10000; // 10 seconds of pure temporal travel bliss

  const eras: HistoricalEra[] = useMemo(() => [
    {
      id: 'contemporanea',
      name: 'Idade Contemporânea',
      subtitle: 'A Era Digital e da Globalização',
      description: 'Onde bits de informação e viagens espaciais definem as fronteiras da consciência humana.',
      startYear: 2026,
      endYear: 1789,
      icon: <Cpu className="w-8 h-8 text-cyan-400" />,
      colorClass: 'text-cyan-400 shadow-cyan-500/20'
    },
    {
      id: 'iluminismo',
      name: 'O Século das Luzes',
      subtitle: 'Razão e Revoluções Liberais',
      description: 'Filósofos iluministas desafiam dinastias absolutistas e acendem as chamas dos direitos humanos.',
      startYear: 1789,
      endYear: 1492,
      icon: <Sparkles className="w-8 h-8 text-yellow-400" />,
      colorClass: 'text-yellow-400 shadow-yellow-500/20'
    },
    {
      id: 'moderna',
      name: 'Idade Moderna',
      subtitle: 'Grandes Navegações e Encontro de Mundos',
      description: 'Caravelas cruxam oceanos desconhecidos conectando continentes e mapeando novas esferas terrestres.',
      startYear: 1492,
      endYear: 476,
      icon: <Globe className="w-8 h-8 text-emerald-400" />,
      colorClass: 'text-emerald-400 shadow-emerald-500/20'
    },
    {
      id: 'media',
      name: 'Idade Média',
      subtitle: 'Feudalismo e Catedrais Monumentais',
      description: 'Um milênio de cavalaria mística, castelos de pedra e a preservação de manuscritos sagrados nos mosteiros.',
      startYear: 476,
      endYear: -500,
      icon: <Shield className="w-8 h-8 text-amber-500" />,
      colorClass: 'text-amber-500 shadow-amber-500/20'
    },
    {
      id: 'classica',
      name: 'Antiguidade Clássica',
      subtitle: 'Filosofia, Senado e Democracia',
      description: 'Sócrates, Platão e Júlio César esculpem os alicerces jurídicos, intelectuais e estéticos do Ocidente.',
      startYear: -500,
      endYear: -3200,
      icon: <BookOpen className="w-8 h-8 text-indigo-400" />,
      colorClass: 'text-indigo-400 shadow-indigo-500/20'
    },
    {
      id: 'oriental',
      name: 'Antiguidade Oriental',
      subtitle: 'A Aurora da Escrita e Cidades-Estado',
      description: 'Scribas gravam hieróglifos e símbolos cuneiformes em tabuletas de argila, marcando o nascimento da história registrada.',
      startYear: -3200,
      endYear: -10000,
      icon: <Compass className="w-8 h-8 text-rose-400" />,
      colorClass: 'text-rose-400 shadow-rose-500/20'
    },
    {
      id: 'prehistoria',
      name: 'Pré-História',
      subtitle: 'Revolução Agrícola e Pinturas Rupestres',
      description: 'Nas profundezas das cavernas, os primeiros caçadores e coletores dominam o fogo e criam as primeiras sementes de civilização.',
      startYear: -10000,
      endYear: -12000,
      icon: <Flame className="w-8 h-8 text-orange-500 animate-pulse" />,
      colorClass: 'text-orange-500 shadow-orange-500/20'
    }
  ], []);

  // Particle list generator for the time tunnel effect
  const particles = useMemo(() => Array.from({ length: 45 }).map((_, i) => ({
    id: i,
    angle: (i * (360 / 45) * Math.PI) / 180,
    radius: Math.random() * 200 + 50,
    delay: Math.random() * 2,
    speed: Math.random() * 1.5 + 0.5,
    size: Math.random() * 3 + 1,
    color: i % 3 === 0 ? 'bg-amber-400' : i % 3 === 1 ? 'bg-amber-100' : 'bg-slate-500'
  })), []);

  const activeEra = eras.find(era => {
    if (currentYear >= 0) {
      return currentYear <= era.startYear && currentYear >= era.endYear;
    } else {
      // For negative years (BC)
      return currentYear <= era.startYear && currentYear >= era.endYear;
    }
  }) || eras[eras.length - 1];

  // Easing function: Cubic deceleration for smooth final approach
  const easeOutCubic = (t: number) => {
    return 1 - Math.pow(1 - t, 3);
  };

  const animateTimeTravel = (timestamp: number) => {
    if (hasEndedRef.current) return;
    if (!startTimeRef.current) startTimeRef.current = timestamp;
    const elapsed = timestamp - startTimeRef.current;
    const progressVal = Math.min(elapsed / duration, 1);
    setProgress(progressVal);

    // Apply easing to calculate the current year
    const easedProgress = easeOutCubic(progressVal);
    
    // Total temporal delta: from 2026 d.C. to target year
    const startYearVal = 2026;
    const targetYearVal = targetYear;
    const computedYear = Math.round(startYearVal - (startYearVal - targetYearVal) * easedProgress);
    
    setCurrentYear(computedYear);

    if (progressVal < 1) {
      requestRef.current = requestAnimationFrame(animateTimeTravel);
    } else {
      // Landing phase
      hasEndedRef.current = true;
      setIsLanding(true);
    }
  };

  const handleStartTravel = () => {
    setIsPlaying(true);
    // Simulate tick sounds or initiate haptic cues if on device
    if (!isMuted) {
      try {
        const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
        // Play an initial bass synth sweep representing chronoscope activation
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(60, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(30, audioCtx.currentTime + 1.5);
        gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 1.5);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 1.5);
      } catch (e) {
        console.log("Audio not allowed by policy yet");
      }
    }
  };

  const onCompleteRef = useRef(onComplete);
  useEffect(() => {
    onCompleteRef.current = onComplete;
  }, [onComplete]);

  useEffect(() => {
    // Automatically trigger startup sound if possible on mount
    handleStartTravel();
  }, []);

  useEffect(() => {
    if (isPlaying && !isLanding) {
      requestRef.current = requestAnimationFrame(animateTimeTravel);
    }
    return () => {
      if (requestRef.current) cancelAnimationFrame(requestRef.current);
    };
  }, [isPlaying, isLanding]);

  useEffect(() => {
    if (isLanding) {
      const t = setTimeout(() => {
        onCompleteRef.current();
      }, 2000);
      return () => clearTimeout(t);
    }
  }, [isLanding]);

  useEffect(() => {
    // Pick one random historical curiosity on mount and keep it for the entire session
    const allFacts = Object.values(eraFacts).flat();
    if (allFacts.length > 0) {
      const randomIdx = Math.floor(Math.random() * allFacts.length);
      setCurrentFact(allFacts[randomIdx]);
    }
  }, []);

  // Year formatting utility (e.g. 44 a.C. or 2026 d.C.)
  const formatYear = (yr: number) => {
    if (yr > 0) {
      return `${yr.toLocaleString('pt-BR')} d.C.`;
    } else if (yr === 0) {
      return '1 a.C.';
    } else {
      return `${Math.abs(yr).toLocaleString('pt-BR')} a.C.`;
    }
  };

  return (
    <div id="time-travel-screen" className="min-h-screen bg-slate-950 flex flex-col items-center justify-center text-white relative overflow-hidden select-none font-sans">
      
      {/* Absolute space/star background overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,rgba(15,23,42,0.4)_0%,rgba(2,6,23,1)_100%)] z-0" />
      
      {/* Sound Controller */}
      <button 
        id="sound-toggle-btn"
        onClick={() => setIsMuted(!isMuted)}
        className="absolute top-6 right-6 z-30 p-2.5 rounded-full border border-slate-800/80 bg-slate-900/60 hover:bg-slate-800/80 hover:text-amber-400 transition-all text-slate-400"
      >
        {isMuted ? <VolumeX className="w-5 h-5" /> : <Volume2 className="w-5 h-5" />}
      </button>

      {!isPlaying ? (
        /* PORTAL DE INÍCIO DA VIAGEM */
        <motion.div 
          key="portal-gate"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
          className="z-10 max-w-lg w-full px-6 flex flex-col items-center text-center space-y-8"
        >
          {/* Elegant Golden Astrolabe Ring */}
          <div className="relative w-40 h-40 flex items-center justify-center">
            <div className="absolute inset-0 bg-amber-500/10 blur-2xl rounded-full" />
            <motion.div 
              animate={{ rotate: 360 }}
              transition={{ duration: 45, repeat: Infinity, ease: 'linear' }}
              className="absolute inset-0 border-2 border-dashed border-amber-500/30 rounded-full flex items-center justify-center"
            >
              <div className="w-32 h-32 border border-amber-500/15 rounded-full" />
            </motion.div>
            <motion.div 
              animate={{ rotate: -360 }}
              transition={{ duration: 25, repeat: Infinity, ease: 'linear' }}
              className="absolute w-32 h-32 border border-dotted border-amber-400/20 rounded-full"
            />
            <div className="relative bg-slate-900 border border-amber-500/40 p-6 rounded-full shadow-2xl flex items-center justify-center">
              <Compass className="w-12 h-12 text-amber-500 stroke-[1.2] animate-pulse" />
              <Hourglass className="w-6 h-6 text-amber-400/80 absolute" />
            </div>
          </div>

          <div className="space-y-3">
            <span className="text-amber-500 font-mono text-xs uppercase tracking-[0.25em] font-bold block">Conselho Historiográfico</span>
            <h1 className="text-4xl sm:text-5xl font-serif font-bold tracking-tight text-amber-50 leading-tight">
              Atravessar os Séculos
            </h1>
            <p className="text-slate-400 text-sm font-serif leading-relaxed max-w-sm mx-auto">
              Inicie o acoplamento do <span className="text-amber-100 font-semibold">CHRONOS World Engine</span> e mergulhe em um sistema integrado que modela 12.000 anos de história material.
            </p>
          </div>

          {/* Luxurious activation button */}
          <button
            id="start-time-dive-btn"
            onClick={handleStartTravel}
            className="group relative px-8 py-4 bg-slate-900 border border-amber-500/50 hover:border-amber-400 hover:bg-slate-800 text-white rounded-xl transition-all duration-300 shadow-xl overflow-hidden cursor-pointer"
          >
            <div className="absolute inset-0 bg-gradient-to-r from-amber-500/10 to-transparent translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000" />
            <span className="relative font-mono text-xs uppercase tracking-widest font-bold flex items-center gap-2 text-amber-400 group-hover:text-amber-300">
              <span>Ativar Linha do Tempo</span>
              <ChevronRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </span>
          </button>

          <p className="text-[10px] font-mono tracking-widest uppercase text-slate-600">
            Sincronização Padrão V1.0
          </p>
        </motion.div>
      ) : (
        /* JORNADA TEMPORAL ATIVA (TÚNEL E CONTADOR) */
        <motion.div 
          key="time-tunnel-active"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="z-10 flex flex-col items-center justify-between h-full min-h-screen py-16 px-6 w-full max-w-4xl"
        >
          {/* Top Indicator */}
          <div className="text-center space-y-1.5">
            <span className="text-[10px] font-mono tracking-widest text-slate-500 uppercase font-semibold">Descompressão Temporal</span>
            <div className="flex items-center justify-center gap-2">
              <Clock className="w-4 h-4 text-amber-500 animate-spin [animation-duration:5s]" />
              <span className="text-xs font-mono font-bold text-amber-500/80 uppercase">World Engine Conectado</span>
            </div>
          </div>

          {/* Time Tunnel Particle Container */}
          <div className="absolute inset-0 pointer-events-none z-0 overflow-hidden flex items-center justify-center">
            {particles.map((p) => {
              // Determine speed multiplier based on current travel progress
              const speedMultiplier = progress < 0.8 ? p.speed * 4 : p.speed * (1 + (1 - progress) * 3);
              return (
                <motion.div
                  key={p.id}
                  initial={{ x: 0, y: 0, scale: 0.1, opacity: 0 }}
                  animate={{
                    x: Math.cos(p.angle) * p.radius * 3.5,
                    y: Math.sin(p.angle) * p.radius * 3.5,
                    scale: [0.1, 1.5, 3],
                    opacity: [0, 0.8, 0]
                  }}
                  transition={{
                    duration: 4 / speedMultiplier,
                    repeat: Infinity,
                    ease: 'easeInOut',
                    delay: p.delay
                  }}
                  className={`absolute rounded-full ${p.color}`}
                  style={{
                    width: `${p.size}px`,
                    height: `${p.size}px`
                  }}
                />
              );
            })}
            
            {/* Giant vortex rings passing through */}
            <AnimatePresence>
              {progress < 0.9 && (
                <>
                  <motion.div 
                    initial={{ scale: 0.1, opacity: 0 }}
                    animate={{ scale: 2.2, opacity: [0, 0.15, 0] }}
                    transition={{ duration: 2.5, repeat: Infinity, ease: 'easeOut' }}
                    className="absolute w-80 h-80 border border-amber-500/10 rounded-full"
                  />
                  <motion.div 
                    initial={{ scale: 0.1, opacity: 0 }}
                    animate={{ scale: 2.2, opacity: [0, 0.15, 0] }}
                    transition={{ duration: 2.5, repeat: Infinity, ease: 'easeOut', delay: 1.25 }}
                    className="absolute w-80 h-80 border border-slate-400/5 rounded-full"
                  />
                </>
              )}
            </AnimatePresence>
          </div>

          {/* Centralized Gigantic Counter with shake/vibration effect */}
          <motion.div 
            id="year-counter-container"
            animate={progress < 0.85 ? { 
              x: [0, Math.random() * 2 - 1, 0], 
              y: [0, Math.random() * 2 - 1, 0] 
            } : {}}
            transition={{ repeat: Infinity, duration: 0.05 }}
            className="relative flex flex-col items-center justify-center my-auto space-y-3 z-10"
          >
            {/* Outer soft glow ring */}
            <div className="absolute w-96 h-96 bg-amber-500/[0.03] blur-3xl rounded-full" />
            
            <span className="text-[11px] font-mono tracking-[0.3em] text-amber-500/60 uppercase font-bold">Ano de Destino</span>
            
            <AnimatePresence mode="popLayout">
              <motion.h2 
                key={currentYear}
                initial={{ opacity: 0.8, scale: 0.98 }}
                animate={{ opacity: 1, scale: 1 }}
                className="text-6xl sm:text-8xl font-mono font-extrabold text-white tracking-tighter drop-shadow-[0_0_20px_rgba(245,158,11,0.2)]"
              >
                {formatYear(currentYear)}
              </motion.h2>
            </AnimatePresence>

            {/* Progress bar line */}
            <div className="w-64 h-1 bg-slate-900 rounded-full overflow-hidden border border-slate-800/40 relative">
              <div 
                className="absolute left-0 top-0 bottom-0 bg-gradient-to-r from-amber-600 to-amber-400 transition-all duration-75"
                style={{ width: `${progress * 100}%` }}
              />
            </div>
          </motion.div>

          {/* Animated Historical Curiosity Ticker */}
          <div className="z-10 max-w-md w-full px-4 text-center my-4">
            <div className="inline-flex items-center gap-1.5 px-3 py-1 bg-amber-500/10 border border-amber-500/20 rounded-full mb-3 shadow-[0_0_12px_rgba(245,158,11,0.05)]">
              <Sparkles className="w-3.5 h-3.5 text-amber-400 animate-pulse" />
              <span className="text-[9px] font-mono tracking-widest text-amber-300 uppercase font-bold">Curiosidade Histórica</span>
            </div>
            
            <div className="min-h-[72px] sm:min-h-[56px] flex items-center justify-center bg-slate-900/40 rounded-xl px-4 py-3 border border-slate-800/50 backdrop-blur-xs">
              <AnimatePresence mode="wait">
                <motion.p
                  key={currentFact}
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -6 }}
                  transition={{ duration: 0.3, ease: 'easeInOut' }}
                  className="text-amber-100/90 text-xs sm:text-sm font-serif leading-relaxed italic"
                >
                  "{currentFact}"
                </motion.p>
              </AnimatePresence>
            </div>
          </div>

          {/* Bottom active Era Details Display */}
          <AnimatePresence mode="wait">
            <motion.div
              key={activeEra.id}
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -15 }}
              transition={{ duration: 0.4 }}
              className="bg-slate-900/80 border border-slate-800/80 p-6 rounded-2xl max-w-md w-full text-center relative backdrop-blur-md shadow-2xl z-10"
            >
              {/* Floating active Era Icon */}
              <div className="absolute -top-6 left-1/2 -translate-x-1/2 p-3 bg-slate-950 border border-slate-800 rounded-xl shadow-xl flex items-center justify-center">
                {activeEra.icon}
              </div>

              <div className="mt-3 space-y-2">
                <h3 className={`text-lg font-serif font-bold ${activeEra.colorClass}`}>
                  {activeEra.name}
                </h3>
                <span className="text-[10px] font-mono tracking-wider text-amber-300/80 uppercase font-bold block">
                  {activeEra.subtitle}
                </span>
                <p className="text-slate-400 text-xs font-serif leading-relaxed">
                  {activeEra.description}
                </p>
              </div>
            </motion.div>
          </AnimatePresence>

          {/* Skip Button (for rapid developers or users) */}
          <button
            id="skip-time-travel-btn"
            onClick={onComplete}
            className="absolute bottom-6 right-6 z-20 text-[10px] font-mono tracking-widest text-slate-500 hover:text-amber-400 transition-colors uppercase font-bold cursor-pointer bg-slate-900/30 px-3.5 py-2 rounded-lg border border-slate-800/50 hover:bg-slate-900/60"
          >
            Pular Travessia
          </button>
        </motion.div>
      )}

      {/* Extreme Landing screen flash */}
      <AnimatePresence>
        {isLanding && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 1.5, ease: 'easeInOut' }}
            className="absolute inset-0 bg-white z-50 flex flex-col items-center justify-center text-slate-950"
          >
            <motion.div
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.3, duration: 1 }}
              className="text-center space-y-4"
            >
              <Compass className="w-16 h-16 text-amber-600 animate-spin mx-auto stroke-[1.2]" />
              <h2 className="text-3xl font-serif font-bold tracking-wider">CHRONOS CONECTADO</h2>
              <p className="text-slate-500 font-mono text-xs uppercase tracking-widest">Aterrisando na Corrente do Tempo...</p>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
