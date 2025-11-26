pragma Singleton
import QtQuick 2.15
import Quickshell.Io

Item {
    id: root
    
    // Pool of reusable Process objects
    property var processPool: []
    property int poolSize: 5
    // Cap the total pool size to avoid unbounded growth
    property int maxPoolSize: 32
    
    Component.onCompleted: {
        // Initialize process pool with safety checks
        if (!processComponent) {
            console.error("ExecutorService: processComponent is undefined. Aborting pool initialization.");
            return;
        }
        // Initialize process pool up to the configured poolSize, respect maxPoolSize
        var initialSize = Math.min(poolSize, maxPoolSize)
        for (var i = 0; i < initialSize; i++) {
            var proc = processComponent.createObject(root)
            if (proc) {
                proc.inUse = false
                processPool.push(proc)
            } else {
                console.error("ExecutorService: Failed to create process object at index", i)
            }
        }
    }
    
    Component {
        id: processComponent
        Process {
            property bool inUse: false
        }
    }
    
    // Get an available process from the pool
    function getAvailableProcess() {
        for (var i = 0; i < processPool.length; i++) {
            if (processPool[i] && !processPool[i].inUse) {
                return processPool[i]
            }
        }
        // If no available process, create a new one
        if (!processComponent) {
            console.error("ExecutorService: processComponent is undefined when creating a new process.");
            return null
        }
        if (processPool.length >= maxPoolSize) {
            console.warn("ExecutorService: maximum pool size reached; recycling timeout may occur.");
            return null
        }
        var proc = processComponent.createObject(root)
        processPool.push(proc)
        return proc
    }
    
    // Execute a command and return immediately (fire and forget)
    function exec(command, args) {
        if (!command) return false
        
        var proc = getAvailableProcess()
        if (!proc) {
            console.error("ExecutorService: No available process could be allocated.");
            return false
        }
        proc.inUse = true
        
        if (typeof command === "string") {
            // Single string command
            proc.command = [command].concat(args || [])
        } else if (Array.isArray(command)) {
            // Array of command parts
            proc.command = command
        } else {
            proc.inUse = false
            return false
        }
        
        proc.startDetached()
        
        // Mark as available after a short delay
        Qt.callLater(function() {
            proc.inUse = false
        })
        
        return true
    }
    
    // Execute a shell command
    function execShell(shellCommand) {
        return exec("sh", ["-c", shellCommand])
    }
    
    // Kill a process by name
    function killProcess(processName) {
        return exec("pkill", ["-f", processName])
    }
    
    // Check if a process is running (returns a Process object that you can connect to)
    function checkProcess(processName, callback) {
        var proc = getAvailableProcess()
        proc.inUse = true
        proc.command = ["pgrep", "-x", processName]
        
        proc.exited.connect(function(exitCode) {
            if (callback) {
                try {
                    callback(exitCode === 0)
                } catch (e) {
                    console.error("ExecutorService: Callback error:", e)
                }
            }
            proc.inUse = false
        })
        
        proc.running = true
        return proc
    }
    
    Component {
        id: outputProcessComponent
        Process {
            property var userCallback: null
            property bool hasExited: false
            property int processExitCode: 0
            property string collectedOutput: ""
            
            stdout: StdioCollector {
                id: collector
                onStreamFinished: {
                    console.log("ExecutorService: Stream finished, text length:", this.text.length)
                    collectedOutput = this.text
                    
                    // If process already exited, call callback now
                    if (hasExited && userCallback) {
                        console.log("ExecutorService: Calling callback with output")
                        try {
                            userCallback(collectedOutput, "", processExitCode)
                        } catch (e) {
                            console.error("ExecutorService: Callback error:", e)
                        }
                    }
                }
            }
            
            onExited: function(code, status) {
                console.log("ExecutorService: Process exited with code:", code)
                hasExited = true
                processExitCode = code
                
                // If stream already finished, call callback now
                if (collectedOutput && userCallback) {
                    console.log("ExecutorService: Calling callback after exit")
                    try {
                        userCallback(collectedOutput, "", code)
                    } catch (e) {
                        console.error("ExecutorService: Callback error:", e)
                    }
                } else if (code !== 0 && userCallback) {
                    console.log("ExecutorService: Process failed")
                    try {
                        userCallback("", "Process failed", code)
                    } catch (e) {
                        console.error("ExecutorService: Callback error:", e)
                    }
                }
                
                Qt.callLater(function() { destroy() })
            }
        }
    }
    
    // Execute a command and capture stdout/stderr using StdioCollector
    function execWithOutput(command, args, callback) {
        if (!command) {
            if (callback) callback(null, "No command provided", 1)
            return false
        }
        
        var cmdArray = typeof command === "string" ? [command].concat(args || []) : command
        
        var proc = outputProcessComponent.createObject(root, {
            command: cmdArray,
            userCallback: callback,
            running: true
        })
        
        if (!proc) {
            if (callback) callback(null, "Failed to create process", 1)
            return false
        }
        
        return true
    }
}
