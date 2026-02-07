import Foundation
import ServiceManagement
import AppKit
import Combine

class FortressController: ObservableObject {
    @Published var isTouchIDEnabled: Bool = true
    @Published var isHelperActive: Bool = false
    @Published var statusMessage: String = "Initializing..."
    
    let service = SMAppService.daemon(plistName: "com.HumbleFoundry.FortressHelper.plist")

    private var xpcConnection: NSXPCConnection?

    init() {
        checkHelperStatus()
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(didWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    private func connection() -> NSXPCConnection? {
        if let conn = xpcConnection { return conn }
        
        let conn = NSXPCConnection(machServiceName: "com.HumbleFoundry.FortressHelper", options: .privileged)
        conn.remoteObjectInterface = NSXPCInterface(with: FortressProtocol.self)
        conn.resume()
        self.xpcConnection = conn
        return conn
    }
    
    func installHelper() {
        do {
            try service.register()
            statusMessage = "Helper Installed. Checking connection..."
            checkHelperStatus()
        } catch {
            statusMessage = "Install Failed: \(error.localizedDescription)"
            isHelperActive = false
        }
    }
    
    func checkHelperStatus() {
        guard let proxy = connection()?.remoteObjectProxy as? FortressProtocol else {
            isHelperActive = false
            statusMessage = "Connection Failed"
            return
        }
        
        proxy.ping { [weak self] success in
            DispatchQueue.main.async {
                self?.isHelperActive = success
                self?.statusMessage = success ? "Ready" : "Helper Inactive"
            }
        }
    }

    func toggleLockdown(enableLockdown: Bool) {
        
        guard let proxy = connection()?.remoteObjectProxy as? FortressProtocol else { return }
        
        proxy.setTouchID(enabled: !enableLockdown) { [weak self] success, msg in
            DispatchQueue.main.async {
                self?.isTouchIDEnabled = !enableLockdown
                self?.statusMessage = enableLockdown ? "Locked Down" : "Restored"
            }
        }
    }
    
    func lockdownAndSleep() {
        toggleLockdown(enableLockdown: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let script = "tell application \"System Events\" to sleep"
            NSAppleScript(source: script)?.executeAndReturnError(nil)
        }
    }
    
    @objc func didWake() {
        print("System Woke Up - Restoring TouchID")
        toggleLockdown(enableLockdown: false)
    }
}
