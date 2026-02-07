import SwiftUI

@main
struct FortressModeApp: App {
    var body: some Scene {
        MenuBarExtra() {
            ContentView()
        } label: {
            Image("menuIcon")
        }
        .menuBarExtraStyle(.window)
    }
}
