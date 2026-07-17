/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { Home, Search, Bookmark, User, Settings, Sparkles } from 'lucide-react';
import { Tab } from '../types';

interface BottomNavProps {
  activeTab: Tab;
  setActiveTab: (tab: Tab) => void;
  savedCount: number;
}

export default function BottomNav({ activeTab, setActiveTab, savedCount }: BottomNavProps) {
  const navItems = [
    { id: 'home' as Tab, label: 'Início', icon: <Home className="w-4 h-4" /> },
    { id: 'search' as Tab, label: 'Evidências', icon: <Search className="w-4 h-4" /> },
    { id: 'mitologia' as Tab, label: 'Mitologia', icon: <Sparkles className="w-4 h-4" /> },
    { id: 'saved' as Tab, label: 'Fontes', icon: <Bookmark className="w-4 h-4" />, badge: savedCount },
    { id: 'profile' as Tab, label: 'Perfil', icon: <User className="w-4 h-4" /> },
    { id: 'settings' as Tab, label: 'Ajustes', icon: <Settings className="w-4 h-4" /> },
  ];

  return (
    <nav
      id="bottom-navigation-bar"
      className="fixed bottom-0 left-0 right-0 bg-white border-t border-slate-200/80 px-4 py-2 flex justify-between items-center z-40 max-w-md mx-auto sm:max-w-none sm:rounded-none shadow-lg sm:shadow-md"
    >
      <div className="flex w-full justify-around items-center max-w-lg mx-auto">
        {navItems.map((item) => {
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              id={`nav-tab-${item.id}`}
              onClick={() => setActiveTab(item.id)}
              className={`relative flex flex-col items-center justify-center gap-0.5 py-1 px-2.5 rounded-xl transition-all duration-150 ${
                isActive
                  ? 'text-amber-600 bg-amber-50/60 font-semibold'
                  : 'text-slate-400 hover:text-slate-600 hover:bg-slate-50'
              }`}
            >
              <div className="relative">
                {item.icon}
                {!!item.badge && item.badge > 0 && (
                  <span className="absolute -top-1.5 -right-1.5 bg-amber-500 text-white font-mono text-[8px] font-bold w-3.5 h-3.5 rounded-full flex items-center justify-center border border-white">
                    {item.badge}
                  </span>
                )}
              </div>
              <span className="text-[9px] font-medium font-sans tracking-tight">
                {item.label}
              </span>
              {isActive && (
                <span className="absolute bottom-0 left-1/2 -translate-x-1/2 w-4 h-0.5 bg-amber-500 rounded-full" />
              )}
            </button>
          );
        })}
      </div>
    </nav>
  );
}
