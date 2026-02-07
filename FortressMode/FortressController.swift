import Foundation
import ServiceManagement
import Security
import AppKit
import Combine

class FortressController: ObservableObject {
    @Published var isTouchIDEnabled: Bool = true
    @Published var isHelperActive: Bool = false
    @Published var statusMessage: String = "Initializing..."
    
    let helperLabel = "com.HumbleFoundry.FortressHelper"
    
    private var xpcConnection: NSXPCConnection?

    init() {
        checkHelperStatus()
    }

    func installHelper() {
        var authRef: AuthorizationRef?
        var status = AuthorizationCreate(nil, nil, [], &authRef)
        guard status == errAuthorizationSuccess, let authRef else {
            DispatchQueue.main.async {
                self.statusMessage = "AuthorizationCreate failed: \(status)"
            }
            return
        }

        let rightName = "com.apple.ServiceManagement.blesshelper"
        var authItem = rightName.withCString { namePtr in
            AuthorizationItem(name: namePtr, valueLength: 0, value: nil, flags: 0)
        }
        var rights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]

        status = AuthorizationCopyRights(authRef, &rights, nil, flags, nil)
        guard status == errAuthorizationSuccess else {
            DispatchQueue.main.async {
                self.statusMessage = "AuthorizationCopyRights failed: \(status)"
            }
            return
        }

        var cfError: Unmanaged<CFError>?
        let ok = SMJobBless(kSMDomainSystemLaunchd, helperLabel as CFString, authRef, &cfError)

        if ok {
            DispatchQueue.main.async {
                self.statusMessage = "Helper Installed. Connecting..."
                self.checkHelperStatus()
            }
        } else {
            let nsErr = cfError?.takeRetainedValue() as? NSError
            DispatchQueue.main.async {
                if let nsErr {
                    self.statusMessage = "Install Error [\(nsErr.domain) \(nsErr.code)]: \(nsErr.localizedDescription)"
                } else {
                    self.statusMessage = "Install Error: Unknown"
                }
                self.isHelperActive = false
            }
        }
    }
    
    private func connection() -> NSXPCConnection? {
        if let conn = xpcConnection { return conn }
        
        let conn = NSXPCConnection(machServiceName: helperLabel, options: .privileged)
        conn.remoteObjectInterface = NSXPCInterface(with: FortressProtocol.self)
        
        conn.interruptionHandler = { [weak self] in
            self?.xpcConnection = nil
            DispatchQueue.main.async { self?.statusMessage = "Connection Interrupted" }
        }
        
        conn.invalidationHandler = { [weak self] in
            self?.xpcConnection = nil
            DispatchQueue.main.async { self?.statusMessage = "Connection Invalidated" }
        }
        
        conn.resume()
        self.xpcConnection = conn
        return conn
    }
    
    func checkHelperStatus() {
        guard let proxy = connection()?.remoteObjectProxyWithErrorHandler({ error in
            DispatchQueue.main.async {
                self.statusMessage = "XPC Error: \(error.localizedDescription)"
                self.isHelperActive = false
            }
        }) as? FortressProtocol else {
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
        guard let proxy = connection()?.remoteObjectProxy as? FortressProtocol else {
            statusMessage = "No Connection"
            return
        }
        
        proxy.setTouchID(enabled: !enableLockdown) { [weak self] success, msg in
            DispatchQueue.main.async {
                if success {
                    self?.isTouchIDEnabled = !enableLockdown
                    self?.statusMessage = msg
                } else {
                    self?.statusMessage = "Error: \(msg)"
                }
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
}
