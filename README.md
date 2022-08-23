# Minecraft Manager (mcmanager)

## About

A bash framework for managing local Minecraft server and client software

Link: [mcmanager project on Github](https://github.com/ancillarysoft/mcmanager)
## Installation

With an example system username "exampleuser", the framework root directory should reside at the following location:

```/home/exampleuser/data/gaming/minecraft/mcmanager```

_... more information coming soon_

## General Reference

The project consists of three primary bases of operation:

  - `client`: Assets related to the Minecraft client software (the thing you play Minecraft with)
  - `main`: Overarching system-wide libraries, logs, etc
  - `server`: Assets related to the Minecraft server software

_... more information coming soon_

## External Reference

[Setting up a server (by fandom.com)](https://minecraft.fandom.com/wiki/Tutorials/Setting_up_a_server)

[How To Create a Minecraft Server on Ubuntu 22.04 (by DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-create-a-minecraft-server-on-ubuntu-22-04)

[Tuning the JVM – G1GC Garbage Collector Flags for Minecraft (by Aikar)](https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/)

[Minecraft Server Control Script (project on Github)](https://minecraftservercontrol.github.io/docs/mscs)

## To-Do List

 - Capture `git` verbosity via `gitctl.sh` script verbosity handler function
   - This will allow us to have all of that verbosity stored into local log files by default
 - Add message-type-related text coloring to all verbose messaging
 - Generate an official schema reference for `sourcelinks.json` files
 - Integration with systemd for automated server startup etc.
 - World backup and restore processes

## Attribution & License

    Created by h8rt3rmin8r (161803398@email.tg) on 20220822

    Copyright 2022 Ancillary Soft

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

