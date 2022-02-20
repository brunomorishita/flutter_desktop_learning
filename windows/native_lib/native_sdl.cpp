#include "native_sdl.h"
#include "SDL.h"

#include <iostream>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32)
#define IS_WIN32
#endif

#ifdef IS_WIN32
#include <windows.h>
#endif

// Avoiding name mangling
extern "C" {
void init() {
    if (SDL_Init(SDL_INIT_AUDIO) != 0){
        std::cout << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return;
    }
    SDL_Quit();

    std::cout << "Calling init yay!" << std::endl;
}
}