import Foundation
import ServiceManagement

class FortressHelper: NSObject, FortressProtocol {
    func checkStatus(withReply reply: @escaping (Bool, String) -> Void) {
        let output = runCommand("/usr/bin/bioutil", args: ["-r"])
        
        if output.contains("1") {
            reply(true, "TouchID is Enabled.")
        }
        else if output.contains("0") {
            reply(false, "TouchID is Disabled")
        }
        else {
            reply(false, "Unknown State: \(output)")
        }
    }
    
    func setTouchID(enabled: Bool, withReply reply: @escaping (Bool, String) -> Void) {
        let state = enabled ? "1" : "0"
        let output = runCommand("/usr/bin/bioutil", args: ["-w", "-u", state])
        reply(true, "Executed: \(output)")
    }
    
    func ping(withReply reply: @escaping (Bool) -> Void) { reply(true) }
    
    private func runCommand(_ path: String, args: [String]) -> String {
        let task = Process()
        task.launchPath = path
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

class ServiceDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: FortressProtocol.self)
        newConnection.exportedObject = FortressHelper()
        newConnection.resume()
        return true
    }
}

let delegate = ServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()

RunLoop.main.run()
