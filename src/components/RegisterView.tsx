/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState, FormEvent } from 'react';
import { motion } from 'motion/react';
import { User, Mail, Lock, ShieldAlert, Compass, CheckCircle2, ArrowLeft } from 'lucide-react';
import { Screen, User as UserType } from '../types';

interface RegisterViewProps {
  onNavigate: (screen: Screen) => void;
  onRegisterSuccess: (user: UserType) => void;
}

export default function RegisterView({ onNavigate, onRegisterSuccess }: RegisterViewProps) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [acceptPrinciples, setAcceptPrinciples] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    setError('');

    if (!name || !email || !password) {
      setError('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    if (password.length < 6) {
      setError('A senha deve conter no mínimo 6 caracteres.');
      return;
    }

    if (!acceptPrinciples) {
      setError('Você precisa concordar em honrar os princípios da busca pela evidência histórica.');
      return;
    }

    // Simulate creation
    setSuccess(true);
    setTimeout(() => {
      onRegisterSuccess({
        name: name,
        email: email,
        xp: 20,
        level: 1,
        streak: 1,
        joinedDate: 'Julho de 2026'
      });
      onNavigate('TIME_TRAVEL');
    }, 1500);
  };

  return (
    <div id="register-container" className="min-h-screen bg-slate-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
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
          Crie seu perfil e explore o acervo ao longo do tempo.
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md px-4">
        <div className="bg-white py-8 px-6 shadow-md rounded-2xl border border-slate-100 sm:px-10">
          {success ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              className="text-center py-6"
            >
              <CheckCircle2 className="w-16 h-16 text-emerald-500 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-slate-900">Conta Criada!</h3>
              <p className="text-slate-500 text-sm mt-1">Preparando seu painel historiográfico...</p>
            </motion.div>
          ) : (
            <form id="register-form" onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 p-3 rounded-xl text-xs font-medium flex items-center gap-2">
                  <ShieldAlert className="w-4 h-4 text-red-500 shrink-0" />
                  <span>{error}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-mono uppercase tracking-wider font-semibold text-slate-600 mb-1">
                  Nome Completo
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <User className="h-4 w-4 text-slate-400" />
                  </div>
                  <input
                    id="register-name-input"
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Seu nome"
                    className="block w-full pl-10 pr-3 py-2.5 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-all bg-slate-50/50"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-mono uppercase tracking-wider font-semibold text-slate-600 mb-1">
                  E-mail
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Mail className="h-4 w-4 text-slate-400" />
                  </div>
                  <input
                    id="register-email-input"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="exemplo@gmail.com"
                    className="block w-full pl-10 pr-3 py-2.5 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-all bg-slate-50/50"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-mono uppercase tracking-wider font-semibold text-slate-600 mb-1">
                  Senha
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Lock className="h-4 w-4 text-slate-400" />
                  </div>
                  <input
                    id="register-password-input"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Mínimo 6 caracteres"
                    className="block w-full pl-10 pr-3 py-2.5 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-all bg-slate-50/50"
                  />
                </div>
              </div>

              <div className="flex items-start">
                <div className="flex items-center h-5">
                  <input
                    id="accept-principles-checkbox"
                    type="checkbox"
                    checked={acceptPrinciples}
                    onChange={(e) => setAcceptPrinciples(e.target.checked)}
                    className="h-4 w-4 text-amber-600 border-slate-300 rounded focus:ring-amber-500"
                  />
                </div>
                <div className="ml-3 text-xs leading-relaxed text-slate-500 font-serif">
                  Concordo em buscar conhecimento fundamentado, pautado em fontes verificáveis, sem misturar fatos objetivos com visões particulares.
                </div>
              </div>

              <div>
                <button
                  id="register-submit-button"
                  type="submit"
                  className="w-full bg-slate-900 hover:bg-slate-800 active:bg-slate-950 text-white font-medium text-sm py-2.5 px-4 rounded-xl transition-all duration-150 shadow-md shadow-slate-900/10"
                >
                  Criar Conta
                </button>
              </div>
            </form>
          )}
        </div>

        <div className="mt-6 text-center">
          <p className="text-sm text-slate-600">
            Já possui uma conta?{' '}
            <button
              id="go-to-login"
              onClick={() => onNavigate('LOGIN')}
              className="font-medium text-amber-600 hover:text-amber-700 transition-colors focus:outline-none"
            >
              Fazer login
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
