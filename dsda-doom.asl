state("dsda-doom", "0.29.0") {
    int gametic: 0x97EF70;
    int gamestate: 0x732590;
    int map: 0x72F7B4;
    int attempt: 0x8182EC;
}

state("dsda-doom", "0.28.3") {
    int gametic: 0x96ca90;
    int gamestate: 0x71fef0;
    int map: 0x71d114;
    int attempt: 0x810ad0;
}

state("dsda-doom", "0.25.6") {
    int gametic: 0x2ce1d0;
    int gamestate: 0x14a920;
    int map: 0x20a844;
    int attempt: 0x13f640;
}

state("dsda-doom", "0.24.3") {
    int gametic: 0x2e7170;
    int gamestate: 0x14db80;
    int map: 0x21e584;
    int attempt: 0x149664;
}

startup {
    vars.totalGameTime = 0;
}

init {
    vars.justStarted = true;
}

start {
    if (vars.justStarted) {
        vars.justStarted = false;
        vars.totalGameTime = 0;
        return true;
    }

    return false;
}

split {
    if (current.gamestate == 1 && old.gamestate == 0) {
        // Use an integer division since we don't care about ms
        vars.totalGameTime += current.gametic / 35;
        return true;
    }
    return false;
}

reset {
    if (current.attempt > old.attempt) {
        vars.justStarted = true;
        return true;
    }
    return false;
}

gameTime {
    if (current.gamestate != 0 && old.gamestate != 0) {
        return TimeSpan.FromSeconds(vars.totalGameTime);
    }
    return TimeSpan.FromSeconds(vars.totalGameTime + current.gametic / 35);
}

isLoading {
    return true;
}
