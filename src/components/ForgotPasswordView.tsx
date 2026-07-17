/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState, FormEvent } from 'react';
import { motion } from 'motion/react';
import { Mail, Compass, CheckCircle2, ArrowLeft, ArrowRight } from 'lucide-react';
import { Screen } from '../types';

interface ForgotPasswordViewProps {
  onNavigate: (screen: Screen) => void;
}

export default function ForgotPasswordView({ onNavigate }: ForgotPasswordViewProps) {
  const [email, setEmail] = useState('');
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    setError('');

    if (!email) {
      setError('Por favor, informe seu endereço de e-mail.');
      return;
    }

    // Simulate sending email
    setSuccess(true);
  };

  return (
    <div id="forgot-password-container" className="min-h-screen bg-slate-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md px-6 relative">
        <button
          id="back-to-login"
          onClick={() => onNavigate('LOGIN')}
          className="absolute left-6 top-1 text-slate-400 hover:text-slate-600 flex items-center gap-1 text-xs font-mono uppercase tracking-wider font-semibold"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Voltar</span>
        </button>

        <div className="flex justify-center mb-4 mt-8 sm:mt-0">
          <div className="bg-slate-900 text-amber-400 p-3.5 rounded-2xl shadow-md border border-slate-800">
            <Compass className="w-8 h-8 stroke-[1.2]" />
          </div>
        </div>
        <h2 className="text-center text-3xl font-serif font-bold text-slate-900 tracking-wider">
          CHRONOS
        </h2>
        <p className="mt-2 text-center text-sm text-slate-600 font-serif">
          Recuperar acesso ao acervo temporal.
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md px-4">
        <div className="bg-white py-8 px-6 shadow-md rounded-2xl border border-slate-100 sm:px-10">
          {success ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="text-center py-6 space-y-4"
            >
              <CheckCircle2 className="w-16 h-16 text-emerald-500 mx-auto" />
              <h3 className="text-lg font-serif font-bold text-slate-900">Instruções enviadas!</h3>
              <p className="text-slate-500 text-sm leading-relaxed">
                Se o e-mail <strong className="text-slate-800">{email}</strong> estiver cadastrado em nossa base, você receberá um link em alguns instantes.
              </p>
              <div className="pt-4">
                <button
                  id="return-login-button"
                  onClick={() => onNavigate('LOGIN')}
                  className="inline-flex items-center gap-2 bg-slate-900 hover:bg-slate-800 text-white text-sm font-medium py-2 px-5 rounded-xl transition-all"
                >
                  Ir para o Login
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </motion.div>
          ) : (
            <form id="forgot-password-form" onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 p-3 rounded-xl text-xs font-medium">
                  {error}
                </div>
              )}

              <div>
                <label className="block text-xs font-mono uppercase tracking-wider font-semibold text-slate-600 mb-1">
                  Endereço de E-mail
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Mail className="h-4 w-4 text-slate-400" />
                  </div>
                  <input
                    id="recovery-email-input"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="exemplo@gmail.com"
                    className="block w-full pl-10 pr-3 py-2.5 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-all bg-slate-50/50"
                  />
                </div>
              </div>

              <div>
                <button
                  id="forgot-password-submit"
                  type="submit"
                  className="w-full bg-slate-900 hover:bg-slate-800 active:bg-slate-950 text-white font-medium text-sm py-2.5 px-4 rounded-xl transition-all duration-150 shadow-md shadow-slate-900/10"
                >
                  Enviar Link de Recuperação
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
