/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState } from 'react';
import { Screen, User } from './types';
import SplashView from './components/SplashView';
import WelcomeView from './components/WelcomeView';
import LoginView from './components/LoginView';
import RegisterView from './components/RegisterView';
import ForgotPasswordView from './components/ForgotPasswordView';
import MainView from './components/MainView';
import TimeTravelView from './components/TimeTravelView';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('SPLASH');
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [timeTravelTarget, setTimeTravelTarget] = useState<number>(-10000);

  const handleLogout = () => {
    setCurrentUser(null);
    setCurrentScreen('LOGIN');
  };

  const handleLoginRegisterSuccess = (user: User) => {
    setCurrentUser(user);
    setTimeTravelTarget(-10000);
  };

  return (
    <div className="min-h-screen bg-slate-50 font-sans antialiased">
      {currentScreen === 'SPLASH' && (
        <SplashView onComplete={() => setCurrentScreen('WELCOME')} />
      )}

      {currentScreen === 'WELCOME' && (
        <WelcomeView onNavigate={setCurrentScreen} />
      )}

      {currentScreen === 'LOGIN' && (
        <LoginView
          onNavigate={setCurrentScreen}
          onLoginSuccess={handleLoginRegisterSuccess}
        />
      )}

      {currentScreen === 'REGISTER' && (
        <RegisterView
          onNavigate={setCurrentScreen}
          onRegisterSuccess={handleLoginRegisterSuccess}
        />
      )}

      {currentScreen === 'FORGOT_PASSWORD' && (
        <ForgotPasswordView onNavigate={setCurrentScreen} />
      )}

      {currentScreen === 'TIME_TRAVEL' && (
        <TimeTravelView 
          targetYear={timeTravelTarget}
          onComplete={() => setCurrentScreen('HOME')} 
        />
      )}

      {(currentScreen === 'HOME' || currentScreen === 'PROFILE' || currentScreen === 'SETTINGS') && currentUser && (
        <MainView
          user={currentUser}
          onLogout={handleLogout}
          onNavigate={setCurrentScreen}
          initialYear={timeTravelTarget}
          onEnterEpoch={(year: number) => {
            setTimeTravelTarget(year);
            setCurrentScreen('TIME_TRAVEL');
          }}
        />
      )}
    </div>
  );
}

