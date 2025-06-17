state("dsda-doom", "0.29.0") {
    int gametic: 0x97EF70;
    int gamestate: 0x732590;
    int map: 0x72F7B4;
    int attempt: 0x8182EC;
    int isMenuOpen: 0x9A0B4C;
    int isDemoPlaying: 0x9A3064;
}

state("dsda-doom", "0.28.3") {
    int gametic: 0x96ca90;
    int gamestate: 0x71fef0;
    int map: 0x71d114;
    int attempt: 0x810ad0;
    int isMenuOpen: 0x98E7DC;
    int isDemoPlaying: 0x990BE8;
}

startup {
    vars.totalGameTime = 0;

    settings.Add("rta_mode", false, "Set splitter for non-demo runs using RTA.");
}

start {
    // Start only when all pause/menu indicators are gone.
    if (current.isMenuOpen == 0 && current.isDemoPlaying == 0 && current.gamestate == 0) {
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
