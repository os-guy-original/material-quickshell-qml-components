pragma Singleton
import QtQuick 2.15
import Quickshell
import Quickshell.Io

QtObject {
    id: powerService
    
    property var shellInstance: null
    
    property bool isLaptop: false
    property bool supportsHibernate: false
    property bool capabilitiesChecked: false
    
    Component.onCompleted: {
        checkSystemCapabilities()
    }
    
    function checkSystemCapabilities() {
        console.log("PowerService: Checking system capabilities...")
        
        // Check if it's a laptop (has battery)
        ExecutorService.execWithOutput("test", ["-e", "/sys/class/power_supply/BAT0"], function(stdout, stderr, exitCode) {
            isLaptop = (exitCode === 0)
            console.log("PowerService: isLaptop =", isLaptop, "(exitCode:", exitCode + ")")
        })
        
        // Also check for AC adapter as alternative
        ExecutorService.execWithOutput("test", ["-e", "/sys/class/power_supply/AC"], function(stdout, stderr, exitCode) {
            if (exitCode === 0) {
                isLaptop = true
                console.log("PowerService: Found AC adapter, isLaptop = true")
            }
        })
        
        // Check if hibernate is supported
        ExecutorService.execWithOutput("systemctl", ["can-hibernate"], function(stdout, stderr, exitCode) {
            supportsHibernate = (exitCode === 0)
            capabilitiesChecked = true
            console.log("PowerService: supportsHibernate =", supportsHibernate, "(exitCode:", exitCode + ")")
        })
        
        // Force laptop to true for testing - remove this later
        Qt.callLater(function() {
            if (!isLaptop) {
                console.log("PowerService: No battery detected, checking chassis type...")
                ExecutorService.execWithOutput("hostnamectl", ["chassis"], function(stdout, stderr, exitCode) {
                    var chassis = stdout.trim().toLowerCase()
                    console.log("PowerService: Chassis type:", chassis)
                    if (chassis.indexOf("laptop") !== -1 || chassis.indexOf("portable") !== -1) {
                        isLaptop = true
                        console.log("PowerService: Detected laptop from chassis type")
                    }
                })
            }
        })
    }
    
    function lock() {
        console.log("PowerService: Executing lock")
        // Use our custom lockscreen
        if (shellInstance && shellInstance.lockScreen) {
            shellInstance.lockScreen()
        } else {
            console.log("PowerService: Shell instance not available, using hyprlock fallback")
            ExecutorService.exec("hyprlock")
        }
    }
    
    function logout() {
        console.log("PowerService: Executing logout")
        ExecutorService.exec("hyprctl", ["dispatch", "exit"])
    }
    
    function hibernate() {
        console.log("PowerService: Executing hibernate")
        ExecutorService.exec("systemctl", ["hibernate"])
    }
    
    function shutdown() {
        console.log("PowerService: Executing shutdown")
        ExecutorService.exec("systemctl", ["poweroff"])
    }
    
    function reboot() {
        console.log("PowerService: Executing reboot")
        ExecutorService.exec("systemctl", ["reboot"])
    }
    
    function suspend() {
        console.log("PowerService: Executing suspend")
        ExecutorService.exec("systemctl", ["suspend"])
    }
    
    property Component processComponent: Component {
        Process {}
    }
}
