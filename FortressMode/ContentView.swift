//
//  ContentView.swift
//  FortressMode
//
//  Created by Aishwarya Rana on 26/01/26.
//

import SwiftUI
import ServiceManagement

struct ContentView: View {
    @State private var statusMessage: String = "Ready"
    @State private var isLockedDown: Bool = false
    
    let service = SMAppService.daemon(plistName: "com.HumbleFoundry.FortressMode.Helper.plist")
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isLockedDown ? "lock.shield.fill" : "lock.open.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundStyle(isLockedDown ? .red : .green)
            
            Text(isLockedDown ? "TouchID Disabled" : "TouchID Enabled").font(.headline)
            
            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(height: 40)
            
            Divider()
            
            HStack(spacing: 12) {
                Button(action: {
                    toggleTouchID(enable: false)
                }) {
                    Label("Lockdown", systemImage: "lock.slash.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isLockedDown)
                
                Button(action: {
                    toggleTouchID(enable: true)
                }) {
                    Label("Restore", systemImage: "lock.open.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!isLockedDown)
            }
            
            Button("Install Helper") {
                installHelper()
            }
            .font(.caption)
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 250)
    }
    
    func connection() -> NSXPCConnection {
        let connection = NSXPCConnection(machServiceName: "com.HumbleFoundry.FortressMode.Helper", options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: FortressModeProtocol.self)
        connection.resume()
        return connection
    }
    
    func toggleTouchID(enable: Bool) {
        let xpc = connection()
        let proxy = xpc.remoteObjectProxyWithErrorHandler { error in DispatchQueue.main.async {
            statusMessage = "Connection Error: \(error.localizedDescription)" }
        } as? FortressModeProtocol
        
        proxy?.enableTouchID(withReply: { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    statusMessage = "Error: \(error.localizedDescription)"
                } else {
                    isLockedDown = !enable
                    statusMessage = enable ? "Restored Touch ID" : "Disabled Touch ID"
                }
            }
        })
        
        if !enable {
            proxy?.disableTouchID(withReply: { success, error in
                DispatchQueue.main.async {
                    if let error = error { statusMessage = "Error: \(error.localizedDescription)" }
                    else {
                        isLockedDown = true
                        statusMessage = "TouchID Disabled"
                    }
                }
            })
        }
    }
    
    func installHelper() {
        try? service.unregister()
        do {
            try service.register()
            statusMessage = "Helper Registered"
        } catch {
            statusMessage = "Install Failed via Service: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
