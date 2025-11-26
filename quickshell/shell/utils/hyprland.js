function findWorkspaceByClass(Hyprland, className) {
    console.log("[HyprlandUtils] findWorkspaceByClass called with:", className);
    if (!className) {
        console.log("[HyprlandUtils] No className provided");
        return null;
    }
    
    Hyprland.refreshWorkspaces();
    Hyprland.refreshToplevels();
    
    var lowerClassName = className.toLowerCase();
    console.log("[HyprlandUtils] Searching for class:", lowerClassName);
    
    var toplevels = Hyprland.toplevels.values;
    console.log("[HyprlandUtils] Total toplevels:", toplevels.length);
    
    for (var i = 0; i < toplevels.length; i++) {
        var toplevel = toplevels[i];
        if (toplevel.lastIpcObject) {
            var toplevelClass = toplevel.lastIpcObject.class.toLowerCase();
            console.log("[HyprlandUtils] Checking toplevel:", toplevel.title, "class:", toplevelClass);
            if (toplevelClass === lowerClassName || toplevelClass.includes(lowerClassName)) {
                console.log("[HyprlandUtils] MATCH FOUND! Workspace:", toplevel.workspace ? toplevel.workspace.name : "null");
                if (toplevel.workspace) {
                    return toplevel.workspace;
                }
            }
        } else {
            console.log("[HyprlandUtils] Toplevel has no IPC object:", toplevel.title);
        }
    }
    
    console.log("[HyprlandUtils] No workspace found by class");
    return null;
}

function findWorkspaceByTitle(Hyprland, title) {
    console.log("[HyprlandUtils] findWorkspaceByTitle called with:", title);
    if (!title) {
        console.log("[HyprlandUtils] No title provided");
        return null;
    }
    
    Hyprland.refreshWorkspaces();
    Hyprland.refreshToplevels();
    
    var lowerTitle = title.toLowerCase();
    console.log("[HyprlandUtils] Searching for title:", lowerTitle);
    
    var toplevels = Hyprland.toplevels.values;
    for (var i = 0; i < toplevels.length; i++) {
        var toplevel = toplevels[i];
        console.log("[HyprlandUtils] Checking toplevel title:", toplevel.title);
        if (toplevel.title && toplevel.title.toLowerCase().includes(lowerTitle)) {
            console.log("[HyprlandUtils] MATCH FOUND! Workspace:", toplevel.workspace ? toplevel.workspace.name : "null");
            if (toplevel.workspace) {
                return toplevel.workspace;
            }
        }
    }
    
    console.log("[HyprlandUtils] No workspace found by title");
    return null;
}
