import { create } from 'zustand';

export const useBirdStore = create((set, get) => ({
  // State untuk audio dan hasil
  audioFile: null,
  results: [],
  isLoading: false,
  error: null,
  uploadProgress: 0,

  // Actions
  setAudioFile: (file) => set({ audioFile: file, error: null }),
  setResults: (results) => set({ results }),
  setLoading: (loading) => set({ isLoading: loading }),
  setError: (error) => set({ error }),
  setUploadProgress: (progress) => set({ uploadProgress: progress }),

  // Reset state
  resetState: () => set({
    audioFile: null,
    results: [],
    isLoading: false,
    error: null,
    uploadProgress: 0
  })
}));
