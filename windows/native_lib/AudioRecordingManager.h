#ifndef FLUTTER_DESKTOP_LEARNING_AUDIORECORDINGMANAGER_H
#define FLUTTER_DESKTOP_LEARNING_AUDIORECORDINGMANAGER_H

#include "SDL.h"

#include <thread>
#include <mutex>
#include <memory>
#include <cstdint>
#include <string>
#include <fstream>

class AudioRecordingManager {
public:
  struct AudioConfig {
      uint8_t channels = 2;
      int frequency = 44100;
      uint16_t samples = 448;
  };

  AudioRecordingManager(AudioConfig audioConfig);

  ~AudioRecordingManager();

  void init(const char* wavFile);
  void start();
  void stop();
  void processReceivedSpec(Uint8* stream, int len );

private:
  void createWavFile(const std::string& fileName);

  void consumeAudio();

  AudioConfig m_audioConfig;

  std::ofstream m_wavFile;

  //Recieved audio spec
  SDL_AudioSpec m_receivedSpec;

  SDL_AudioSpec m_desiredSpec;

  //Recording data buffer
  Uint8* m_buffer = nullptr;

  //Size of data buffer
  Uint32 m_bufferByteSize = 0;

  // Write position in data buffer
  Uint32 m_bufferWritePosition = 0;

  // Read position in data buffer
  Uint32 m_bufferReadPosition = 0;

  int m_deviceCount = 0;

  SDL_AudioDeviceID m_deviceId = 0;

  int m_bufferSeconds = 10;

  std::mutex m_mutex;

  std::atomic_bool m_finished{false};

  std::condition_variable m_cv;

  std::thread t0;
};

#endif //FLUTTER_DESKTOP_LEARNING_AUDIORECORDINGMANAGER_H
