import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useHistoryStore = create(
    persist(
        (set, get) => ({
            // State
            history: [],
            favorites: [],

            // Actions
            addHistoryItem: (item) => {
                const newItem = {
                    id: Date.now().toString(),
                    timestamp: new Date().toISOString(),
                    ...item,
                };

                set((state) => ({
                    history: [newItem, ...state.history].slice(0, 100) // Keep only last 100 items
                }));

                return newItem;
            },

            removeHistoryItem: (id) => {
                set((state) => ({
                    history: state.history.filter(item => item.id !== id)
                }));
            },

            clearHistory: () => {
                set({ history: [] });
            },

            getHistoryItem: (id) => {
                return get().history.find(item => item.id === id);
            },

            // Favorites management
            addToFavorites: (historyItem) => {
                const favoriteItem = {
                    id: Date.now().toString(),
                    timestamp: new Date().toISOString(),
                    ...historyItem,
                };

                set((state) => ({
                    favorites: [favoriteItem, ...state.favorites]
                }));

                return favoriteItem;
            },

            removeFromFavorites: (id) => {
                set((state) => ({
                    favorites: state.favorites.filter(item => item.id !== id)
                }));
            },

            isFavorite: (birdName) => {
                return get().favorites.some(item =>
                    item.results?.[0]?.birdName === birdName
                );
            },

            clearFavorites: () => {
                set({ favorites: [] });
            },

            // Statistics
            getStats: () => {
                const history = get().history;
                const totalIdentifications = history.length;
                const uniqueBirds = new Set(
                    history.flatMap(item =>
                        item.results?.map(result => result.birdName) || []
                    )
                ).size;

                const averageConfidence = history.length > 0
                    ? history.reduce((sum, item) => sum + (item.confidence || 0), 0) / history.length
                    : 0;

                const mostIdentifiedBird = history.length > 0
                    ? Object.entries(
                        history.reduce((acc, item) => {
                            const birdName = item.results?.[0]?.birdName;
                            if (birdName) {
                                acc[birdName] = (acc[birdName] || 0) + 1;
                            }
                            return acc;
                        }, {})
                    ).sort(([,a], [,b]) => b - a)[0]?.[0] || null
                    : null;

                return {
                    totalIdentifications,
                    uniqueBirds,
                    averageConfidence,
                    mostIdentifiedBird,
                    totalFavorites: get().favorites.length,
                };
            },

            // Search functionality
            searchHistory: (query) => {
                const history = get().history;
                const lowercaseQuery = query.toLowerCase();

                return history.filter(item =>
                    item.results?.some(result =>
                        result.birdName?.toLowerCase().includes(lowercaseQuery) ||
                            result.scientificName?.toLowerCase().includes(lowercaseQuery) ||
                            result.family?.toLowerCase().includes(lowercaseQuery)
                    ) ||
                        item.audioFileName?.toLowerCase().includes(lowercaseQuery)
                );
            },

            // Export/Import functionality
            exportHistory: () => {
                const data = {
                    history: get().history,
                    favorites: get().favorites,
                    exportDate: new Date().toISOString(),
                };

                const blob = new Blob([JSON.stringify(data, null, 2)], {
                    type: 'application/json'
                });

                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `bird-identification-history-${new Date().toISOString().split('T')[0]}.json`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            },

            importHistory: (data) => {
                try {
                    const parsed = typeof data === 'string' ? JSON.parse(data) : data;

                    if (parsed.history && Array.isArray(parsed.history)) {
                        set((state) => ({
                            history: [...parsed.history, ...state.history]
                            .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
                            .slice(0, 100) // Keep only last 100 items
                        }));
                    }

                    if (parsed.favorites && Array.isArray(parsed.favorites)) {
                        set((state) => ({
                            favorites: [...parsed.favorites, ...state.favorites]
                        }));
                    }

                    return true;
                } catch (error) {
                    console.error('Failed to import history:', error);
                    return false;
                }
            },
        }),
        {
            name: 'bird-identification-history', // localStorage key
            version: 1,
            partialize: (state) => ({
                history: state.history,
                favorites: state.favorites,
            }),
        }
    )
);

export default useHistoryStore;
