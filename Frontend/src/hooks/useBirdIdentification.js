import { useState, useCallback } from 'react';
import { toast } from 'react-hot-toast';
import birdService from '../services/birdService';
import useHistoryStore from '../store/historyStore';

export const useBirdIdentification = () => {
    const [audioFile, setAudioFile] = useState(null);
    const [isRecording, setIsRecording] = useState(false);
    const [uploadProgress, setUploadProgress] = useState(0);
    const { addHistoryItem } = useHistoryStore();

    const identifyBird = useCallback(async (file) => {
        if (!file) {
            toast.error('Silakan berikan file audio');
            return;
        }

        try {
            setUploadProgress(0);
            const result = await birdService.identifyBird(file, (progress) => {
                setUploadProgress(progress);
            });

            try {
                const historyItem = {
                    audioFileName: file.name,
                    audioFileSize: file.size,
                    results: [
                        {
                            birdName: result.bird.common_name,
                            scientificName: result.bird.scientific_name,
                            confidence: result.inference_output.confidence,
                            species_code: result.bird.species_code,
                            family: result.bird.family,
                        }
                    ],
                    confidence: result.inference_output.confidence,
                    processingTime: result.inference_output.processing_time,
                    primaryBirdId: result.bird.id,
                };

                addHistoryItem(historyItem);

            } catch (saveError) {
                console.warn('Failed to save identification result:', saveError);
            }

            toast.success('Burung berhasil diidentifikasi!');
            return result;
        } catch (error) {
            console.error('Identification failed:', error);
            toast.error(error.message || 'Gagal mengidentifikasi burung');
            throw error;
        } finally {
            setUploadProgress(0);
        }
    }, [addHistoryItem]);

    const handleFileUpload = useCallback((file) => {
        setAudioFile(file);
    }, []);

    const clearAudio = useCallback(() => {
        setAudioFile(null);
        setUploadProgress(0);
    }, []);

    const startRecording = useCallback(() => {
        setIsRecording(true);
    }, []);

    const stopRecording = useCallback(() => {
        setIsRecording(false);
    }, []);

    const handleRecordingComplete = useCallback((recordedBlob) => {
        const audioFile = new File([recordedBlob.blob], 'recorded-audio.wav', {
            type: 'audio/wav',
        });
        setAudioFile(audioFile);
    }, []);

    return {
        audioFile,
        isRecording,
        uploadProgress,
        identifyBird,
        startRecording,
        stopRecording,
        handleRecordingComplete,
        handleFileUpload,
        clearAudio,
    };
};
