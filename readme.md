# dsda-doom autosplitter

A [dsda-doom 0.24.3](https://github.com/kraflab/dsda-doom) autosplitter for [LiveSplit](http://livesplit.org/).

## Usage
1. Download dsda-doom.asl
2. Add the *Scriptable Auto Splitter* component to your layout
3. Set the script path for the auto splitter component to where dsda-doom.asl is located
4. Set LiveSplit to compare against game time

I recommend not showing milliseconds on your timer or splits. The auto splitter truncates the milliseconds
so it matches movie runs.

## Updating the autosplitter

The autosplitter uses four memory addresses: game tic, game state, current map, and current attempt.
These likely need to be changed everytime dsda-doom is updated.

I use [Cheat Engine](https://cheatengine.org/) to find these addresses.

Here's the general strategy I use to get the memory addresses. For some of these, there seem to be
multiple addresses that work.

Game tic:
1. Pause the game and convert the current time to tics. Doom runs at 35 tics per second.
2. Search for the tics as a four byte value.
3. Let the game run a bit, repeat steps 1 and 2.
4. Repeat until you're confident that you have the tics address.

Game state:
1. Start in a map and search for a 0 as a four byte value.
2. Exit the map and while in the intermission, search for a 1.
3. Go to the next map, search for a 0.
4. Repeat until you find the game state address.

Map:
1. Start in map01 and search for a 1 as a four byte value.
2. Go to some other map, search for that map number
3. Repeat until you find the map address.

Attempt:
1. Start a demo and search for a 1 as a four byte value.
2. Hit the restart demo attempt button, and search for a 2.
3. Repeat until you find the attempt address.

The memory addresses go into the state block at the top of dsda-doom.asl.
If the addresses in Cheat Engine show up as "dsda-doom"+#######, use the value after the plus in the script.
