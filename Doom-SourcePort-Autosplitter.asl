// ==================================================
// Doom SourcePort Autosplitter Script - Version: 1.0
// ==================================================
// Define states to provide memory addresses for different sourceport versions
// To allow compatibility for a new or additional versions of a sourceport an associated state block must be added 

// ===========================
// dsda-doom State Definitions
//   [Doom and Doom II Only]
// ===========================

// ===========================
// dsda-doom State Definitions
// ===========================
state("dsda-doom", "dsda-doom_0.30.1") {
    int gametic: 0x9AE3B0;
    int gamestate: 0x763C48;
    int map: 0x9D2280;
    int attempt: 0x848BE8;
    int isMenuOpen: 0x9CFF8C;
    int isDemoPlaying: 0x9D2390;
}

state("dsda-doom", "dsda-doom_0.30.0") {
    int gametic: 0x99A810;
    int gamestate: 0x753B58;
    int map: 0x750DF4;
    int attempt: 0x730728;
    int isMenuOpen: 0x9BC3EC;
    int isDemoPlaying: 0x9BE904;
}

state("dsda-doom", "dsda-doom_0.29.4") {
    int gametic: 0xAEDB90;
    int gamestate: 0x8A3FA8;
    int map: 0x8A1244;
    int attempt: 0x881728;
    int isMenuOpen: 0xB0F74C;
    int isDemoPlaying: 0xB11C78;
}

state("dsda-doom", "dsda-doom_0.29.3") {
    int gametic: 0xB11090;
    int gamestate: 0x88BE90;
    int map: 0xB34F40;
    int attempt: 0x970B88;
    int isMenuOpen: 0xB32C4C;
    int isDemoPlaying: 0xB35164;
}

state("dsda-doom", "dsda-doom_0.29.0") {
    int gametic: 0x97EF70;
    int gamestate: 0x732590;
    int map: 0x72F7B4;
    int attempt: 0x8182EC;
    int isMenuOpen: 0x9A0B4C;
    int isDemoPlaying: 0x9A3064;
}

state("dsda-doom", "dsda-doom_0.28.3") {
    int gametic: 0x96CA90;
    int gamestate: 0x71FEF0;    
    int map: 0x71D114;
    int attempt: 0x810AD0;
    int isMenuOpen: 0x98E7DC;
    int isDemoPlaying: 0x990BE8;
}

// ======================
// woof State Definitions
// ======================
state("woof", "woof_64_16.0.0") {
    int gametic: 0xB44074;
    int gamestate: 0x8AE408;
    int map: 0x8E42E8;
    int attempt: 0xA76168;
    int isMenuOpen: 0xA75668;
    int isDemoPlaying: 0xB47AA0;
}

state("woof", "woof_32_16.0.0") {
    int gametic: 0x9E5D34;
    int gamestate: 0x76A0DC;
    int map: 0x9E8C64;
    int attempt: 0x91EE0C;
    int isMenuOpen: 0x91E3C0;
    int isDemoPlaying: 0x9E9350;
}

// ===========================
// nyan-doom State Definitions
// ===========================
state("nyan-doom", "nyan-doom_1.6.2") {
    int gametic: 0xA3C990;
    int gamestate: 0x7AB2A0;
    int map: 0x7A6F84;
    int attempt: 0x76F294;
    int isMenuOpen: 0xA5E5AC;
    int isDemoPlaying: 0xA60CE4;
}

init
{ 
	// Autodetect source-port and its version based on process name and its memory size
    // This is used to determine the state (memory addresses) to use
    // To allow compatibility for an additional source-port or version of a source-port an associated if / else if block must be added
    // If a compatible version is not detected the default state will be used (the first state with the correct process name)
	
    string process_name = modules.First().ModuleName;
    string memory_size = Convert.ToString(modules.First().ModuleMemorySize, 16);
	
    // dsda-doom logic block
    if (process_name == "dsda-doom.exe") {
        if (memory_size == "a1e000")
            version = "dsda-doom_0.28.3";
        else if (memory_size == "a30000")
            version = "dsda-doom_0.29.0";
        else if (memory_size == "bcd000")
            version = "dsda-doom_0.29.3";
        else if (memory_size == "bc0000")
            version = "dsda-doom_0.29.4";
        else if (memory_size == "a6c000")
            version = "dsda-doom_0.30.0";
        else if (memory_size == "a7f000")
            version = "dsda-doom_0.30.1";
        }
    
    // woof logic block
    else if (process_name == "woof.exe") {
        if (memory_size == "bcd000")
            version = "woof_64_16.0.0";
        if (memory_size == "a5d000")
            version = "woof_32_16.0.0";
        }
    
    // nyan-doom logic block
    else if (process_name == "nyan-doom.exe") {
        if (memory_size == "b46000")
            version = "nyan-doom_1.6.2";
        }

    print(process_name + " version: " + version + " with memory size: " + memory_size + " detected.");

}

startup {
    vars.totalGameTime = 0;

    settings.Add("rta_mode", false, "Set splitter for non-demo runs using RTA without load times.");
}

start {
    // Start only when all pause/menu indicators are gone.
    if (current.isMenuOpen == 0 && current.gamestate == 0) {
        vars.totalGameTime = 0f;
        // In RTA mode, we need to add one tic every level start because DOOM
        // doesn't start from tic 0.
        if (settings["rta_mode"]) {
            vars.totalGameTime += 1;
        }
        
        return true;
    }
}

split {
    // Split on level intermission.
    if (current.gamestate == 1 && old.gamestate == 0) {
        // In RTA mode, we need to add one tic every level start because DOOM
        // doesn't start from tic 0.
        if (settings["rta_mode"]) {
            vars.totalGameTime += 1;
        }
        // In demo mode, this is where we add the current level time to the running total.
        else {
            // Use integer division to truncate the ms to match traditional DOOM timing.
            vars.totalGameTime += current.gametic / 35;
        }

        return true;
    }
}

reset {
    if (!settings["rta_mode"] && current.attempt > old.attempt) {
        return true;
    }

    return false;
}

gameTime {
    // In RTA mode, we keep a running total using delta time because we can no longer
    // rely solely on the level time (for example, to account for saving/loading). 
    if (settings["rta_mode"]) {
        int delta = current.gametic - old.gametic;
        if (delta < 0) {
            delta = 0;
        }

        vars.totalGameTime += delta;

        return TimeSpan.FromSeconds(vars.totalGameTime / 35f);
    }
    // In demo mode, we display the running total + current level time.
    // Milliseconds are truncated to follow traditional DOOM timing.
    else {
        // Just return current total during intermissions.
        // NOTE: Waits one refresh to let the split block run first. 
        if (current.gamestate != 0 && old.gamestate != 0) {
            return TimeSpan.FromSeconds(vars.totalGameTime);
        }

        return TimeSpan.FromSeconds(vars.totalGameTime + current.gametic / 35);
    }
}

isLoading {
    return true;
}

onReset {
    vars.totalGameTime = 0f;
}
