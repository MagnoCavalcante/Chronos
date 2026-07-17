/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState, FormEvent } from 'react';
import { motion } from 'motion/react';
import { Mail, Lock, Eye, EyeOff, KeyRound, Compass, CheckCircle2, AlertCircle, BookOpen } from 'lucide-react';
import { Screen, User } from '../types';

interface LoginViewProps {
  onNavigate: (screen: Screen) => void;
  onLoginSuccess: (user: User) => void;
}

export default function LoginView({ onNavigate, onLoginSuccess }: LoginViewProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    setError('');

    if (!email || !password) {
      setError('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    if (password.length < 6) {
      setError('A senha deve conter no mínimo 6 caracteres.');
      return;
    }

    // Simulate authenticating
    setSuccess(true);
    setTimeout(() => {
      onLoginSuccess({
        name: email.split('@')[0].toUpperCase() || 'Explorador',
        email: email,
        xp: 120,
        level: 1,
        streak: 3,
        joinedDate: 'Julho de 2026'
      });
      onNavigate('TIME_TRAVEL');
    }, 1200);
  };

  const handleDemoLogin = () => {
    setSuccess(true);
    setTimeout(() => {
      onLoginSuccess({
        name: 'Dr. Eduardo Silva',
        email: 'eduardo.silva@academia.edu',
        xp: 280,
        level: 2,
        streak: 5,
        joinedDate: 'Julho de 2026'
      });
      onNavigate('TIME_TRAVEL');
    }, 800);
  };

  return (
    <div id="login-container" className="min-h-screen bg-slate-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md px-6">
        <div className="flex justify-center mb-4">
          <div className="bg-slate-900 text-amber-400 p-3.5 rounded-2xl shadow-md border border-slate-800">
            <Compass className="w-8 h-8 stroke-[1.2]" />
          </div>
        </div>
        <h2 className="text-center text-3xl font-serif font-bold text-slate-900 tracking-wider">
          CHRONOS
        </h2>
        <p className="mt-2 text-center text-sm text-slate-600 font-serif">
          Conhecimento através do tempo.
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
              <h3 className="text-lg font-medium text-slate-900">Autenticando...</h3>
              <p className="text-slate-500 text-sm mt-1">Bem-vindo de volta ao portal do tempo!</p>
            </motion.div>
          ) : (
            <form id="login-form" onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 p-3 rounded-xl text-xs font-medium flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                  <span>{error}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-mono uppercase tracking-wider font-semibold text-slate-600 mb-1">
                  E-mail
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Mail className="h-4 w-4 text-slate-400" />
                  </div>
                  <input
                    id="login-email-input"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="exemplo@gmail.com"
                    className="block w-full pl-10 pr-3 py-2.5 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-all bg-slate-50/50"
                  />
                </div>
              </div>

              <div>
                <div className="flex justify-between items-center mb-1">
                  <label className="block text-xs font-mono uppercase tracking-wider font-semibold text-slate-600">
                    Senha
                  </label>
                  <button
                    type="button"
                    onClick={() => onNavigate('FORGOT_PASSWORD')}
                    className="text-xs font-medium text-amber-600 hover:text-amber-700 transition-colors"
                  >
                    Esqueceu?
                  </button>
                </div>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Lock className="h-4 w-4 text-slate-400" />
                  </div>
                  <input
                    id="login-password-input"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Mínimo 6 caracteres"
                    className="block w-full pl-10 pr-10 py-2.5 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-all bg-slate-50/50"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600"
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div>
                <button
                  id="login-submit-button"
                  type="submit"
                  className="w-full bg-slate-900 hover:bg-slate-800 active:bg-slate-950 text-white font-medium text-sm py-2.5 px-4 rounded-xl transition-all duration-150 shadow-md shadow-slate-900/10 flex items-center justify-center gap-2"
                >
                  Entrar
                </button>
              </div>

              <div className="relative my-6">
                <div className="absolute inset-0 flex items-center" aria-hidden="true">
                  <div className="w-full border-t border-slate-200"></div>
                </div>
                <div className="relative flex justify-center text-xs uppercase">
                  <span className="px-2 bg-white text-slate-400 font-mono tracking-widest text-[10px]">Ou explore</span>
                </div>
              </div>

              <div>
                <button
                  id="login-demo-button"
                  type="button"
                  onClick={handleDemoLogin}
                  className="w-full bg-slate-100 hover:bg-slate-200 border border-slate-200 text-slate-800 font-medium text-sm py-2.5 px-4 rounded-xl transition-all duration-150 flex items-center justify-center gap-2"
                >
                  <BookOpen className="w-4 h-4 text-slate-600" />
                  <span>Acesso de Convidado (Rápido)</span>
                </button>
              </div>
            </form>
          )}
        </div>

        <div className="mt-6 text-center">
          <p className="text-sm text-slate-600">
            Ainda não tem uma conta?{' '}
            <button
              id="go-to-register"
              onClick={() => onNavigate('REGISTER')}
              className="font-medium text-amber-600 hover:text-amber-700 transition-colors focus:outline-none"
            >
              Criar conta gratuita
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
