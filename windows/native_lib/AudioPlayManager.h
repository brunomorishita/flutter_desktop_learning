#ifndef FLUTTER_DESKTOP_LEARNING_AUDIOPLAYMANAGER_H
#define FLUTTER_DESKTOP_LEARNING_AUDIOPLAYMANAGER_H

#include "SDL.h"

class AudioPlayManager {
public:
  AudioPlayManager() = default;
  void init(const char* wavFile);
  void start();
  void stop();
  void processReceivedSpec(Uint8* stream, int len );

private:
  SDL_AudioDeviceID m_deviceId = 0;
  Uint8 *m_audioPos = 0;
  Uint32 m_audioLen = 0;

  SDL_AudioSpec m_receivedSpec;

  SDL_AudioSpec m_desiredSpec;

  int m_deviceCount = 0;
};

#endif //FLUTTER_DESKTOP_LEARNING_AUDIOPLAYMANAGER_H