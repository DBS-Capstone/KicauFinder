import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { FaSearch, FaFilter } from "react-icons/fa";
import { toast } from "react-hot-toast";
import { realBirdData, getUniqueHabitats } from "../data/realBirdData";
import EnhancedBirdCard from "./birdpedia/EnhancedBirdCard";
import BirdService from "../services/BirdService";

const BirdpediaSection = () => {
  const { birdName } = useParams();
  const navigate = useNavigate();

  const [searchTerm, setSearchTerm] = useState("");
  const [habitatFilter, setHabitatFilter] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [birds, setBirds] = useState([]);
  const [useApiData, setUseApiData] = useState(true);
  const [hasApiError, setHasApiError] = useState(false);

  // Get unique habitats for filter dropdown
  const habitats = getUniqueHabitats();

  // Fetch birds from API
  const fetchBirds = async () => {
    setIsLoading(true);
    try {
      let response;

      // Use search if there's a search term, otherwise get all birds
      if (searchTerm.trim()) {
        const filters = {};
        if (habitatFilter) {
          filters.habitat = habitatFilter;
        }
        response = await BirdService.searchBirds(searchTerm, filters);
      } else if (habitatFilter) {
        response = await BirdService.getBirdsByHabitat(habitatFilter);
      } else {
        const params = { limit: 50 }; // Add reasonable limit
        response = await BirdService.getAllBirds(params);
      }

      // Handle different response structures
      let birdsData;
      if (response.birds) {
        birdsData = response.birds;
      } else if (Array.isArray(response.data)) {
        birdsData = response.data;
      } else if (Array.isArray(response)) {
        birdsData = response;
      } else {
        birdsData = [];
      }

      // Ensure each bird has a valid ID
      const processedBirds = birdsData.map((bird, index) => ({
        ...bird,
        id: bird.id || bird._id || `bird-${index}` // Fallback ID generation
      }));

      setBirds(processedBirds);
      setHasApiError(false); // Reset error state on successful fetch

    } catch (error) {
      console.error('Error fetching birds:', error);
      toast.error(error.message || 'Failed to load birds from API, using local data');

      // Fallback to local data on API error
      setHasApiError(true);
      setUseApiData(false);
      setBirds(realBirdData);
    } finally {
      setIsLoading(false);
    }
  };

  // Initial data load - always try API first
  useEffect(() => {
    fetchBirds();
  }, []); // Only run once on mount

  // Handle search and filter changes
  useEffect(() => {
    // Only make API calls if we're using API data and not in error state
    if (!useApiData || hasApiError) return;

    const debounceTimer = setTimeout(() => {
      fetchBirds();
    }, 500);

    return () => clearTimeout(debounceTimer);
  }, [searchTerm, habitatFilter, useApiData, hasApiError]);

  // Handle manual toggle of API data
  useEffect(() => {
    if (useApiData && !hasApiError) {
      // User manually enabled API - try to fetch
      fetchBirds();
    } else if (!useApiData) {
      // User manually disabled API - use local data
      setBirds(realBirdData);
      setHasApiError(false); // Reset error state
    }
  }, [useApiData]);

  // Filter birds (for local data or additional client-side filtering)
  const filteredBirds = (useApiData && !hasApiError) ? birds : birds.filter(
    (bird) => {
      const matchesSearch = !searchTerm ||
        bird.common_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        bird.scientific_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        bird.family?.toLowerCase().includes(searchTerm.toLowerCase());

      const matchesHabitat = !habitatFilter ||
        bird.habitat?.toLowerCase().includes(habitatFilter.toLowerCase());

      return matchesSearch && matchesHabitat;
    }
  );

  // Animation variants
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1 }
    }
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: { y: 0, opacity: 1 }
  };

  // Handle legacy bird name route
  useEffect(() => {
    if (birdName) {
      const handleLegacyRoute = async () => {
        try {
          // Try to find bird by common name first
          let selectedBird;

          if (useApiData && !hasApiError) {
            try {
              // Try API search by name
              const decodedName = decodeURIComponent(birdName).replace(/-/g, ' ');
              selectedBird = await BirdService.getBirdByCommonName(decodedName);
            } catch (apiError) {
              console.log('API search failed, trying local data');
            }
          }

          // Fallback to local data
          if (!selectedBird) {
            selectedBird = realBirdData.find(
              (bird) => bird.common_name?.toLowerCase().replace(/\s+/g, "-") === birdName
            );
          }

          if (selectedBird && selectedBird.id) {
            // Redirect to new detail page route with proper ID
            navigate(`/birdpedia/${selectedBird.id}`, { replace: true });
          } else {
            // Bird not found, redirect to main birdpedia with error
            toast.error('Burung tidak ditemukan');
            navigate('/birdpedia', { replace: true });
          }
        } catch (error) {
          console.error('Error handling legacy route:', error);
          navigate('/birdpedia', { replace: true });
        }
      };

      handleLegacyRoute();
    }
  }, [birdName, navigate, useApiData, hasApiError]);

  // Don't render main content if handling legacy route
  if (birdName) {
    return (
      <div className="min-h-screen bg-ui-bg flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-brand-sage"></div>
          <p className="text-text-secondary mt-4">Mengalihkan...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-ui-bg">
      {/* Header Section */}
      <div className="bg-gradient-to-r from-brand-sage to-brand-forest text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <h1 className="text-4xl md:text-5xl font-montserrat font-bold mb-4">
              Birdpedia
            </h1>
            <p className="text-xl text-green-100 max-w-2xl mx-auto">
              Jelajahi koleksi lengkap informasi burung dari berbagai spesies di seluruh dunia
            </p>

            {/* Data Source Toggle */}
            <div className="mt-6 flex justify-center items-center gap-4">
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={useApiData}
                  onChange={(e) => setUseApiData(e.target.checked)}
                  className="rounded"
                />
                <span>Use API Data</span>
              </label>
              <span className="text-xs opacity-75">
                {useApiData && !hasApiError
                  ? 'Loading from server'
                  : hasApiError
                    ? 'API failed - using local data'
                    : 'Using local data'
                }
              </span>
            </div>
          </motion.div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* Search and Filter Section */}
        <motion.div
          className="bg-ui-surface rounded-2xl shadow-lg p-6 mb-8 border border-ui-border"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
        >
          <div className="flex flex-col md:flex-row gap-4">
            {/* Search Input */}
            <div className="flex-1 relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <FaSearch className="h-5 w-5 text-text-secondary" />
              </div>
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Cari burung berdasarkan nama, nama ilmiah, atau famili..."
                className="block w-full pl-10 pr-3 py-3 border border-ui-border rounded-lg focus:ring-2 focus:ring-brand-sage focus:border-transparent bg-ui-bg text-text-primary placeholder-text-secondary"
              />
            </div>

            {/* Habitat Filter */}
            <div className="relative min-w-[200px]">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <FaFilter className="h-5 w-5 text-text-secondary" />
              </div>
              <select
                value={habitatFilter}
                onChange={(e) => setHabitatFilter(e.target.value)}
                className="block w-full pl-10 pr-8 py-3 border border-ui-border rounded-lg focus:ring-2 focus:ring-brand-sage focus:border-transparent appearance-none bg-ui-bg text-text-primary"
              >
                <option value="">Semua Habitat</option>
                {habitats.map((habitat) => (
                  <option key={habitat} value={habitat}>
                    {habitat}
                  </option>
                ))}
              </select>
            </div>

            {/* Clear Filters Button */}
            {(searchTerm || habitatFilter) && (
              <motion.button
                onClick={() => {
                  setSearchTerm("");
                  setHabitatFilter("");
                }}
                className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                Clear
              </motion.button>
            )}

            {/* Refresh Button */}
            {useApiData && (
              <motion.button
                onClick={() => fetchBirds()}
                disabled={isLoading}
                className="px-4 py-2 bg-brand-sage text-white rounded-lg hover:bg-brand-forest disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                {isLoading ? "Loading..." : "Refresh"}
              </motion.button>
            )}
          </div>

          {/* Results Count */}
          <div className="mt-4 text-sm text-text-secondary">
            Menampilkan {filteredBirds.length} dari {birds.length} burung
            {useApiData && !isLoading && !hasApiError && (
              <span className="ml-2 text-brand-sage">• Live data</span>
            )}
            {hasApiError && (
              <span className="ml-2 text-orange-600">• Fallback to local data</span>
            )}
          </div>
        </motion.div>

        {/* Debug Info (remove in production) */}
        {process.env.NODE_ENV === 'development' && (
          <div className="mb-4 p-2 bg-yellow-100 text-yellow-800 text-xs rounded">
            Debug: {filteredBirds.length} birds loaded,
            API: {useApiData ? 'ON' : 'OFF'},
            Error: {hasApiError ? 'YES' : 'NO'},
            Search: "{searchTerm}",
            Filter: "{habitatFilter}"
          </div>
        )}

        {/* Birds Grid */}
        {isLoading ? (
          <div className="text-center py-20">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-brand-sage"></div>
            <p className="text-text-secondary mt-4 text-lg">Memuat burung...</p>
          </div>
        ) : (
          <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
          >
            {filteredBirds.length > 0 ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {filteredBirds.map((bird, index) => (
                  <motion.div
                    key={`${bird.id}-${index}`} // More robust key
                    variants={itemVariants}
                    className="mb-6"
                  >
                    <EnhancedBirdCard
                      bird={bird}
                      index={index}
                      // Pass explicit ID to ensure correct routing
                      onClick={() => {
                        if (bird.id) {
                          navigate(`/birdpedia/${bird.id}`);
                        } else {
                          toast.error('ID burung tidak valid');
                        }
                      }}
                    />
                  </motion.div>
                ))}
              </div>
            ) : (
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="text-center py-20"
              >
                <div className="text-6xl mb-6">🔍</div>
                <h3 className="text-2xl font-semibold text-text-primary mb-2">
                  Tidak ada burung ditemukan
                </h3>
                <p className="text-text-secondary">
                  {useApiData && !hasApiError
                    ? "Coba ubah kata kunci pencarian atau filter habitat"
                    : "Coba ubah kata kunci pencarian atau aktifkan API data"
                  }
                </p>
              </motion.div>
            )}
          </motion.div>
        )}
      </div>
    </div>
  );
};

export default BirdpediaSection;
