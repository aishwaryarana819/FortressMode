import Foundation
import ServiceManagement
import Security
import AppKit
import Combine

class FortressController: ObservableObject {
    @Published var isTouchIDEnabled: Bool = true
    @Published var isHelperActive: Bool = false
    @Published var statusMessage: String = "Initializing..."
    
    // The specifics of your helper
    let helperLabel = "com.HumbleFoundry.FortressHelper"
    
    private var xpcConnection: NSXPCConnection?

    init() {
        // Check if already connected on launch
        checkHelperStatus()
    }

    // MARK: - Installation (The Magic Fix)
    func installHelper() {
            // 1. Prepare the Authorization Item safely
            // kSMRightBlessPrivilegedHelper is a Swift String, C needs a pointer.
            let authItem = kSMRightBlessPrivilegedHelper.withCString { namePtr in
                return AuthorizationItem(name: namePtr, valueLength: 0, value: nil, flags: 0)
            }

            // 2. Allocate memory for the Rights list
            // We create a specific pointer 'itemsPtr' so we can write to it directly
            let itemsPtr = UnsafeMutablePointer<AuthorizationItem>.allocate(capacity: 1)
            itemsPtr.initialize(to: authItem) // Write data to the pointer

            // Ensure memory is freed when the function exits
            defer {
                itemsPtr.deallocate()
            }

            // 3. Create the Rights Structure
            // We pass 'itemsPtr' (which is valid) to the struct
            var authRights = AuthorizationRights(count: 1, items: itemsPtr)

            var authRef: AuthorizationRef?

            // 4. Request Authorization
            let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
            let status = AuthorizationCreate(&authRights, nil, flags, &authRef)

            guard status == errAuthorizationSuccess, let auth = authRef else {
                DispatchQueue.main.async {
                    self.statusMessage = "Authorization Failed: \(status)"
                }
                return
            }

            // 5. Bless the Job (Install)
            var error: Unmanaged<CFError>?
            let success = SMJobBless(kSMDomainSystemLaunchd, helperLabel as CFString, auth, &error)

            if success {
                DispatchQueue.main.async {
                    self.statusMessage = "Helper Installed. Connecting..."
                    self.checkHelperStatus()
                }
            } else {
                let err = error?.takeRetainedValue()
                DispatchQueue.main.async {
                    self.statusMessage = "Install Error: \(err?.localizedDescription ?? "Unknown")"
                }
            }
        }
    
    // MARK: - XPC Connection
    private func connection() -> NSXPCConnection? {
        if let conn = xpcConnection { return conn }
        
        // Connect to the installed helper
        let conn = NSXPCConnection(machServiceName: helperLabel, options: .privileged)
        conn.remoteObjectInterface = NSXPCInterface(with: FortressProtocol.self)
        
        conn.interruptionHandler = { [weak self] in
            // Handle crash/interruption
            self?.xpcConnection = nil
            DispatchQueue.main.async { self?.statusMessage = "Connection Interrupted" }
        }
        
        conn.invalidationHandler = { [weak self] in
            // Handle valid invalidation
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
                // If the command worked, update the UI
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
        
        // Small delay to ensure command sends before sleep
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let script = "tell application \"System Events\" to sleep"
            NSAppleScript(source: script)?.executeAndReturnError(nil)
        }
    }
}
