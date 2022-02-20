#ifndef FLUTTER_DESKTOP_LEARNING_AUDIORECORDINGMANAGER_H
#define FLUTTER_DESKTOP_LEARNING_AUDIORECORDINGMANAGER_H

#include "SDL.h"

#include <memory>

class AudioRecordingManager {
public:
  void init();
  void start();
  void stop();

  void processReceivedSpec(Uint8* stream, int len );
private:

  //Recieved audio spec
  SDL_AudioSpec m_receivedSpec;

  SDL_AudioSpec m_desiredSpec;

  //Recording data buffer
  std::unique_ptr<Uint8[]> m_buffer = nullptr;

  //Size of data buffer
  Uint32 m_bufferByteSize = 0;

  // Write position in data buffer
  Uint32 m_bufferWritePosition = 0;

  // Read position in data buffer
  Uint32 m_bufferReadPosition = 0;

  int m_deviceCount = 0;

  SDL_AudioDeviceID m_deviceId = 0;

  int m_bufferSeconds = 10;
};

#endif //FLUTTER_DESKTOP_LEARNING_AUDIORECORDINGMANAGER_H
