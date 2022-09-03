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
