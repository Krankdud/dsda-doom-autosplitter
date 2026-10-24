# Doom SourcePort Autosplitter for LiveSplit

This repository provides an autosplitter for [LiveSplit](http://livesplit.org/) that works with modern Doom SourcePorts.
Note: the autosplitter will autodetect the SourcePort in use and the specific version of that SourcePort. However, the autosplitter will only work with the specific versions of SourcePorts that it has configuration information for. Currently, the autosplitter supports the follows SourcePorts and versions only:

| [dsda-doom](https://github.com/dsda-org/dsda-doom) | [woof](https://github.com/fabiangreffrath/woof) | [nyan-doom](https://github.com/andrikpowell/nyan-doom/) |
| :---: | :---: | :---: |
| 0.30.1 | 16.0.0 Win64 | 1.6.2 |
| 0.30.0 | 16.0.0 Win32 |  |
| 0.29.4 |  |  |
| 0.29.3 |  |  |
| 0.29.0 |  |  |
| 0.28.3 |  |  |

## Usage
1. Download [Doom-SourcePort-Autosplitter.asl](https://github.com/danieltanner44/dsda-doom-autosplitter/blob/main/Doom-SourcePort-Autosplitter.asl)
2. Add the *Scriptable Auto Splitter* component to your layout
3. Set the script path for the auto splitter component to where Doom-SourcePort-Autosplitter.asl is located
4. Set LiveSplit to compare against game time

I recommend not showing milliseconds on your timer or splits. The auto splitter truncates the milliseconds
so it matches movie runs.

<details>
<summary>Updating the Autosplitter</summary>

## Updating the autosplitter
For the autosplitter to be compatible with a specific release of a SourcePort the autosplitter script must contain the configuration information associated with that release. This section provides information about how to update the autosplitter to work with additional SourcePort versions. This is achieved by updating two key sections of the Doom-SourcePort-Autosplitter.asl file, namely:
1. State Block Definition - Adding the associated state block for the new SourcePort verion (providing the memory addresses for that version)
2. Version Detection - Adding the SourcePort memory size and updating the associated logic to enable auto-detection of the added SourcePort version

### Adding a State Block Definition
Each version of dsda-doom will require an associated state block to be defined at the top of the dsda-doom.asl file. To update this follow these two steps:
1. Find the required memory addresses
2. Add these to a new state block at the top of the Doom-SourcePort-Autosplitter.asl file
Note: If you are uncertain about the update process it can be helpful to apply it to a currently compatible release and check that the correct memory addresses and memory sizes are identified.

The autosplitter state block defines six memory addresses: game tic, game state (intermission), current map, current attempt, menu state, and demo playback state.   

I use [Cheat Engine](https://cheatengine.org/) to find these addresses.

Here's the general strategy I use to get the memory addresses. For some of these, there seem to be
multiple addresses that work.

Game tic:
1. Pause the game and convert the current time to tics. Doom runs at 35 tics per second.
2. Search for the tics as a four byte value.
3. Let the game run a bit, repeat steps 1 and 2.
4. Repeat until you're confident that you have the tics address.
Note: there are two similar game timers and one resets once inputs have been used (move Doomguy or fire a weapon) - use the memory address of the timer that does not reset.

Game state:
1. Start in a map and search for a 0 as a four byte value.
2. Exit the map and while in the intermission, search for a 1.
3. Go to the next map, search for a 0.
4. Repeat until you find the game state address.
Note: some memory addresses do not change to 2 when on the episode completion intermission screen - choose one of them

Map:
1. Start in Map01 and search for a 1 as a four byte value.
2. Go to some other map, search for that map number
3. Repeat until you find the map address.
Note: use IDCLEV cheat or "Previous Level" / "Next Level" keybinds to jump to different maps when searching for valid memory addresses 

Attempt:
1. Start a demo and search for a 1 as a four byte value.
2. Hit the restart demo attempt button, and search for a 2.
3. Repeat until you find the attempt address.
Note: the attempt number to find is the one for that session, e.g., in the Demos menu set "Show Demo Attempts" to "True". The memory address to find is for the number X shown in game as “Attempt X / Y”. Restart the session and confirm the memory addresses resets to the expected value

Menu state:
1. Start in a map, press Esc, and search for a 1 as a four byte value.
2. Press Esc again, and search for a 0 as a four byte value.
3. Repeat until you find the menu state address.

Demo playback state:
1. Launch into main menu, wait for demo lump playback, and search for a 1 as a four byte value.
2. Start a demo recording and search for a 0 as a four byte value.
3. Repeat until you find the demo playback address.
Note: when the demo lump is playing back choose a memory address that goes to 0 on the text screens between demos

The memory addresses go into the state block at the top of dsda-doom.asl.
If the addresses in Cheat Engine show up as "dsda-doom"+#######, use the value after the plus in the script.
Note: all memory addresses for compatible ports have been saved from Cheat Engine to cheat table files and stored in the following folder:
\dsda-doom-autosplitter\Cheat_Engine-Memory_Addresses
This contains the following cheat table files:
+ dsda-doom_0.30.1.CT
+ dsda-doom_0.30.0.CT
+ dsda-doom_0.29.4.CT
+ dsda-doom_0.29.3.CT
+ dsda-doom_0.29.0.CT
+ dsda-doom_0.28.3.CT
+ nyan-doom_1.6.2.CT
+ woof_32_16.0.0.CT
+ woof_64_16.0.0.CT

Note: the memory addresses used in the latest state definitons are appended with an * in their respective descriptions.

### Adding Version Detection
The autosplitter script needs to identify the version of SourcePort that is in use, so the correct state block (memory locations) are used. The script allows automatic identifion of the SourcePort and its version by determining the memory size of the main SourcePort process. To add compatibility for an additional SourcePort versions the memory size of its process must be determined. To update this follow these two steps:
1. Find the required SourcePort main process (e.g., dsda-doom.exe) memory size
2. Add this to the version detection logic in the Doom-SourcePort-Autosplitter.asl file, e.g., 
    else if (memory_size == "XXXXXX")
        version = "X.YY.Z";

Find SourcePort main process memory size:
1. Use a debug viewer to display output from the LiveSplit process (e.g., [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview))
2. Whilst the debug viewer is active, open LiveSplit. Note the layout used must contain the latest Doom-SourcePort-Autosplitter.asl *Scriptable Auto Splitter* component
3. Launch the new version of SourcePort
4. In the debug viewer look for the line "PROCESS_NAME memory size is: XXXXXX", here the XXXXXX is the string that encodes the required memory size and PROCESS_NAME will be the name of the SourcePort executable (e.g., dsda-doom.exe)

Each version of a SourcePort requires the associated version logic to be present in the Doom-SourcePort-Autosplitter.asl file.
</details>

<details>
<summary>Testing the Autosplitter</summary>

## Testing
Any changes to the autosplitter script should be tested to ensure basic functionality is maintained.

### Demo Playback Testing
In order to test any updates to the .asl file one way to check basic functionality is to playback fullgame demos and check the timings match what is expected. In order to support such testing some files have been provided in the repository, in a folder called testing, namely:

#### Doom 1 Testing
Testing Files are located in the folder: /Testing/D1ALL
The related files are in the folder: \dsda-doom-autosplitter\Testing\D1ALL
The included files are:
1. ud1allm7653.lmp - A demo file for test purposes, which contains a complete D1ALL UV-Max demo run of The Ultimate Doom (4 Episodes - uses the -chain_episodes command)
2. D1-D1ALL_Layout.lsl - A LiveSplit layout file for an D1ALL of The Ultimate Doom
3. D1-D1ALL_Splits.lss - A LiveSplit splits definition file for The Ultimate Doom
4. D1-D1ALL_Test_Data.txt - A Test Results file of the expected timing splits and total time that should be captured, with some additional details about the origins of the run itself

#### Doom 2 Testing
Testing Files are located in the folder: /Testing/D2ALL
The related files are in the folder: \dsda-doom-autosplitter\Testing\D2ALL
The included files are:
1. 30uv7128.lmp - A demo file for test purposes, which contains a complete D2ALL UV-Max demo run of Doom II
2. D2-D2ALL_Layout.lsl - A LiveSplit layout file for an D2ALL of Doom II
3. D2-D2ALL_Splits.lss - A LiveSplit splits definition file for Doom II
4. D2-D2ALL_Test_Data.txt - A Test Results file of the expected timing splits and total time that should be captured, with some additional details about the origins of the run itself

#### Teleporter Bug Testing
In testing the implementations for certain SourcePorts a phantom split trigger in LiveSplit was encountered. Following an investigation it was found that one of the gamestate memory addresses in dsda-doom flips on teleporting and can lead to a phantom split (if LiveSplit polls memory at that time). To provide a rigorous testcase for this a map was created with a single teleport and a 50+min demo created of continuous teleporting. This demo can be played back in order to provoke any associated gamestate values issues.
The related files are in the folder: \dsda-doom-autosplitter\Testing\Teleport_Bug
The included files are: 
1. Phantom_Split.WAD - the map to create continuous teleporting
2. phantom_split_demo50min.lmp - the 50min demo with over 5,000 instances of teleporting

#### Playback Testing
To undertake demo playback testing do the following:
1. Launch LiveSplit
2. Load the LiveSplit Layout file: In LiveSplit use "Open Layout" -> "From File" and select the test layout file
3. Load the LiveSplit Splits file: In LiveSplit use "Open Splits" -> "From File" and select the test splits file
4. Update LiveSplit to point to the new .asl file that is under test. For this do the following in LiveSplit: "Edit Layout" -> "Add" -> "Control" -> "Scriptable Auto Splitter" -> Point it at the new .asl file.
5. Now launch the SourcePort you are testing with, where it is set to playback the test demo file. The commands are similar for different SourcePorts, open a command window in the SourcePort root folder and excute the relevant command, something like:
+ dsda-doom: "dsda-doom -iwad doom.wad -playdemo ud1allm7653.lmp"
+ dsda-doom: "dsda-doom -iwad doom2.wad -playdemo 30uv7128.lmp"
+ woof: "woof -iwad doom.wad -playdemo ud1allm7653.lmp"
+ woof: "woof -iwad doom2.wad -playdemo 30uv7128.lmp"
+ nyan-doom: "nyan-doom -iwad doom.wad -playdemo ud1allm7653.lmp"
+ nyan-doom: "nyan-doom -iwad doom2.wad -playdemo 30uv7128.lmp"
Note: the doom.wad / doom2.wad and the ud1allm7653.lmp / 30uv7128.lmp demo files need to be either in the SourcePort root directory or full paths must be used.
6. As the demo plays check that the splits for each map match those recorded in the Test Results file (D1-D1ALL_Test_Data.txt / D2-D2ALL_Test_Data.txt). In particular, check that the total demo time at the end matches, i.e., 01:16:53 or 01:11:28 (HH:MM:SS).
Note: to speed up this process the game speed can be increased (up to 10,000 in dsda-doom and nyan-doom or 1,000 in woof). It would also be worth toggling the menu / pause screens to check that once active the timer stops as expected and the map splits are unaffected.
7. Finally, the following two checks must be undertaken as they are not covered by D1ALL or D2ALL playback tests:
+ The attempt variable - testing the reset function. Resetting Doom should also reset the timer and LiveSplit should restart on initial segment (when recording a demo)
+ The isMenuOpen variable - the LiveSplit counter should stop incrementing when Doom pauses or menu is open. Although this is inherent to Doom but might be worth checking anyway as menu actions are not recorded in demos

#### General Testing
Apart from Demo Playback Testing it may be helpful to undertake general sandpit testing steps to explore that new changes are performing as expected. The following are good general areas to cover:
+ Map ID - Check that LiveSplit displays the correct map and that maps advance as expected as each is complete
+ Menu - Press Esc to call the in-game menu - ensure the timer stops when on the menu screen and continues once the menu is closed again
+ Pause - Press Pause to pause the game - ensure the timer stops when on the pause screen and continues once the game is unpaused again
+ Intermission - ensure the timer stops on the end of map intermission screen and continues on the subsequent map
+ Attempt - Restart a run on the first map and check that LiveSplit resets the timer to zero
Note: testing is aimed at testing the autosplitter functionality and not LiveSplit itself.

### Testing in LiveSplit
A helpful asl script was created that prints out various variables from memory addresses of interest. This was very valuable in tracking down recent issues by printing the gamestate variables for 20 subsequent loops, once triggered. This can be easily adapted to help investigate issues with other variables.
It is located in the folder: \dsda-doom-autosplitter\Testing
The test script file is called:
+ Testing_Script.asl
</details>

<details>
<summary>Bugs / Issues / Feature Requests</summary>
    
## Bugs / Issues / Feature Requests
Please raise feature requests or notify of any issues or bugs as issues in the project Github Repository.

These are essential to ensure that Autosplitter remains relevant, up to date and that any issues can be investigated and remedied.
In reporting any issues please include:

| # | Info Type | Description |
| :---: | :---                       | :--- |
| 1.     | Autosplitter Version       | The Version number of the autosplitter script used (this is contained in the header of the Doom-SourcePort-Autosplitter.asl). If none is present please provide the file size |
| 2.    | SourcePort Used            | The SourcePort used (e.g., dsda-doom, woof, nyan-doom, crispy-doom). Note: please ensure it is a compatible version from the list in the associated readme file |
| 3.     | SourcePort Version         | The version of the SourcePort used (e.g., 0.30.1, 1.6.2) |
| 4.     | LiveSplit Version          | The version of LiveSplit used (e.g., 1.8.37) |
| 5.     | Background                 | A brief description of what happened - the setup you were using, SourcePort launch commands, how it was progressing, what when wrong, anything additional you noticed, etc.  |
| 6.     | Additional Info            | Any additional supporting information, e.g., a demo file of the run that glitched (this would be particularly helpful), what WAD was in use, any unusual settings or tools in use, etc.? |

### ASL and Troubleshooting
This section provide a brief overview of the functional blocks in the ASL code as well as a guide on what variables may be linked to issues that are present. 

#### Intro to ASL Blocks
| asl block | Description |
| :---: | :--- |
| startup | This block is executed a single time when the asl script is first loaded, i.e., when the game process is detected |
| start | This is executed on every loop until it evaluates to True and the LiveSplit timer is started. This contains the start logic |
| init | This runs once when the game process is picked up by LiveSplit. The game dependent logic can be set here |
| split | This is constantly executed and if it returns True a new split is created. This contains the split logic |
| reset | This is constantly executed and if it returns True the current run ends and a new one is started. This contains the reset logic |
| gameTime | This is constantly executed and returns an elapsed time that LiveSplit updates with. See section on Timing Data below  |
| isLoading | This is evaluated to determine if the game should pause a timer as it is on a loading or similar screen. This is not required here as Doom's gametic timer pauses when the game pauses (e.g., menu or pause activation). This is often always set to return True as that pauses the LiveSplit internal clock, i.e., indicates it is on a loading screen |
| onReset | This block is executed once, immediately after the run is reset |

#### Timing Data
The script uses the following LiveSlit timing variables and approach to tracking elapsed time.

The script starts reading the gametic value (current.gametic) from memory - this can be converted to seconds by dividing by the games tic rate, e.g., current map time is current.gametic / 35. When a split is activated this time is added to a global timer vars.totalGameTime as gametic resets for the new map.
1. vars.totalGameTime - This is the currently stored gametime up to the end of the previous map.
2. current.gametic - This encodes the elapsed time in the current map (as tics). The number of seconds in the current map is current.gametic / 35 as Doom logic operates at 35 tics/second.
3. vars.totalGameTime + current.gametic / 35 represents the total elapsed game time (the time from starting the run to the where the player is in the present map).

#### Troubleshooting
This section may help point in the right direction if issues are encountered, particularly if new memory addresses are causing unexpected issues.

| Symptom          | Related Variables | Rationale |
| :---              |     :---:      |     :---      |
| LiveSplit timer not starting | isMenuOpen / gamestate | Start requires that the game is active and in progress (i.e., not on menu or intermission screens) |
| LiveSplit does not split on map exit | gamestate | The gamestate transistion from map to intermission screen (0 -> 1) indicates map exit and action to split |
| LiveSplit splits at an unexpected time | gamestate | The gamestate transistion from map to intermission screen (0 -> 1) incorrectly detected |
| LiveSplit unexpectedly resets | attempts | LiveSplit resets when the attempts number increments, i.e., when current.attempt > old.attempt |
</details>
