# flutter_desktop_learning

A Flutter project for recording audio at Windows Desktop. That's the goal.
Actually the goal is learning about Flutter and Dart because I'm newbie at this,
so I'll try to do the best I can.

## Getting Started

The idea is to create a flutter app to record audio in Windows Desktop.

So far I'm using:
 - fluent_ui
 - MobX

My idea initially is to use dart ffi + openal-soft to do the recording part.
I'm still learning and investigating this part.

Any tips are welcome.

### 02/22/2022 - Now (finally) it's working in some way

This first version saves a raw audio with:

 - Encoding: 32-bit float
 - Byte order: Little-endian
 - Channels: 2
 - Sample rate: 44100

I'm testing the resulting audio with Audacity, importing raw data

## What have changed?
 - I'm using ffigen + SDL2 to do the recording part.
 I found that SDL2 is more suitable for what I've been trying to achieve
