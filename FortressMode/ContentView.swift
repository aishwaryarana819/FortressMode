import SwiftUI

struct ContentView: View {
    @StateObject private var controller = FortressController()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FortressMode")
                    .font(.system(size: 14, weight: .bold))
                    .padding([.vertical, .leading], 13)
                Spacer()
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack {
                        Image(systemName: "power")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                    .foregroundColor(.black)
                }
                .buttonStyle(.accessoryBar)
                .padding()
                .cornerRadius(10)
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
                    }
                    Spacer()
                }
                .cornerRadius(10)
                .padding(.leading, 4)
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: { controller.toggleLockdown(enableLockdown: true) }) {
                        Text("Lockdown")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.bordered)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.9))
                    
                    Button(action: { controller.toggleLockdown(enableLockdown: false) }) {
                        Text("Restore")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.bordered)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.9))
                }
                
                Button(action: { controller.lockdownAndSleep() }) {
                    VStack {
                        Text("Lockdown & Sleep")
                        Text("Auto-Restore on Wake")
                            .font(.caption2)
                            .font(.system(size: 8))
                            .opacity(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundColor(.black)
                    
                }
                .buttonStyle(.bordered)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.9))
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
                        .foregroundColor(.black)
                }
                .buttonStyle(.bordered)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
        .frame(width: 250)
    }
}
