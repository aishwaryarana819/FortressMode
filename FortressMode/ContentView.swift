import SwiftUI

struct ContentView: View {
    @StateObject private var controller = FortressController()
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Color.gray.opacity(0.1)
                Text("FortressMode")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 10)
            }
            .frame(height: 40)
            
            Divider()
            
            VStack(spacing: 5) {
                HStack {
                    Text("Status")
                        .font(.headline)
                    Spacer()
                }
                .padding([.bottom],5)
                HStack {
                    Image(systemName: controller.isTouchIDEnabled ? "lock.open.fill" : "lock.fill")
                        .font(.title3)
                        .foregroundStyle(controller.isTouchIDEnabled ? .red : .green)
                    
                    VStack(alignment: .leading) {
                        Text(controller.isTouchIDEnabled ? "TouchID Enabled" : "TouchID Disabled")
                            .font(.system(size: 12, weight: .semibold))
                        Text(controller.statusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: { controller.toggleLockdown(enableLockdown: true) }) {
                        Text("Lockdown")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { controller.toggleLockdown(enableLockdown: false) }) {
                        Text("Restore")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: { controller.lockdownAndSleep() }) {
                    HStack {
                        Text("Lockdown & Sleep")
                        Text("- Auto Restore at wake")
                            .font(.caption)
                            .opacity(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 10) {
                HStack {
                    Text("Helper Status")
                        .font(.headline)
                    Spacer()
                }
                
                HStack {
                    Circle()
                        .fill(controller.isHelperActive ? Color.green : Color.orange)
                        .frame(width: 10, height: 10)
                    
                    Text(controller.isHelperActive ? "Helper Active" : "Helper Inactive")
                        .font(.caption)
                    
                    Spacer()
                }
                
                Button(action: { controller.installHelper() }) {
                    Text("Install/Re-install Helper")
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            
            VStack(spacing: 10) {
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding()
            }
        }
        .frame(width: 300)
    }
}
