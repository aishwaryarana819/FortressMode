//
//  main.swift
//  com.HumbleFoundry.FortressMode.Helper
//
//  Created by Aishwarya Rana on 26/01/26.
//

import Foundation

@main
class HelperDelegate: NSObject, NSXPCListenerDelegate {
    
    static func main () {
        let delegate = HelperDelegate()
        let listener = NSXPCListener(machServiceName: "com.HumbleFoundry.FortressMode.Helper")
        listener.delegate = delegate
        listener.resume()
        RunLoop.main.run()
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: FortressModeProtocol.self)
        newConnection.exportedObject = FortressModeHelper()
        newConnection.resume()
        return true
    }
}

class FortressModeHelper: NSObject, FortressModeProtocol {
    func disableTouchID(withReply reply: @escaping (Bool, Error?) -> Void) {
        runCommand(unlock: false, reply: reply)
    }
    
    func enableTouchID(withReply reply: @escaping (Bool, Error?) -> Void) {
        runCommand(unlock: true, reply: reply)
    }
    
    func runCommand(unlock: Bool, reply: @escaping (Bool, Error?) -> Void) {
        let task = Process()
        task.launchPath = "/usr/bin/bioutil"
        task.arguments = ["-w", "-s", "-u", unlock ? "1" : "0"]
        try? task.run()
        task.waitUntilExit()
        reply(task.terminationStatus == 0, nil)
    }
}
