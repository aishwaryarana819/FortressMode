import Foundation
import ServiceManagement

class FortressHelper: NSObject, FortressProtocol {
    
    // MARK: - Protocol Methods
    
    func checkStatus(withReply reply: @escaping (Bool, String) -> Void) {
        // Read status (Reading is usually allowed without strict permissions)
        let output = runCommand("/usr/bin/bioutil", args: ["-r", "-s"])
        
        if output.contains("1") {
            reply(true, "TouchID is Enabled")
        } else if output.contains("0") {
            reply(false, "TouchID is Disabled")
        } else {
            // Fallback: User specific read
            let userOutput = runCommand("/usr/bin/bioutil", args: ["-r"])
            parseOutput(userOutput, reply: reply)
        }
    }
    
    func setTouchID(enabled: Bool, withReply reply: @escaping (Bool, String) -> Void) {
        let state = enabled ? "1" : "0"
        
        // Command: bioutil -w (write) -u (user) 1/0
        let output = runCommand("/usr/bin/bioutil", args: ["-w", "-u", state])
        
        // Strict Error Checking
        let lowerOutput = output.lowercased()
        if lowerOutput.contains("error") || lowerOutput.contains("denied") || lowerOutput.contains("failed") {
            reply(false, "Failed: \(output)")
        } else {
            reply(true, "Success: \(output)")
        }
    }
    
    func ping(withReply reply: @escaping (Bool) -> Void) {
        reply(true)
    }
    
    // MARK: - Helper Methods
    
    private func parseOutput(_ output: String, reply: @escaping (Bool, String) -> Void) {
        if output.contains("1") {
            reply(true, "TouchID is Enabled")
        } else if output.contains("0") {
            reply(false, "TouchID is Disabled")
        } else {
            reply(false, "Status: \(output)")
        }
    }

    private func runCommand(_ path: String, args: [String]) -> String {
        let task = Process()
        task.launchPath = path
        task.arguments = args
        
        // 1. Get the Console User (The person sitting at the screen)
        var info = stat()
        if stat("/dev/console", &info) == 0, let pw = getpwuid(info.st_uid) {
            let username = String(cString: pw.pointee.pw_name)
            let home = String(cString: pw.pointee.pw_dir)
            let uid = "\(info.st_uid)"
            
            // 2. Inject the User's Environment to target their Biometric Database
            var env = ProcessInfo.processInfo.environment
            env["USER"] = username
            env["HOME"] = home
            env["LOGNAME"] = username
            env["UID"] = uid
            task.environment = env
        }
        
        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe
        
        do {
            try task.run()
        } catch {
            return "Launch Error: \(error.localizedDescription)"
        }
        
        task.waitUntilExit()
        
        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        
        let outString = String(data: outData, encoding: .utf8) ?? ""
        let errString = String(data: errData, encoding: .utf8) ?? ""
        
        if !errString.isEmpty {
            return "\(outString) [Error: \(errString)]"
        }
        return outString
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
let machServiceName = "com.HumbleFoundry.FortressHelper"
let listener = NSXPCListener(machServiceName: machServiceName)
listener.delegate = delegate
listener.resume()

RunLoop.main.run()
