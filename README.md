This is a macOS MenuBar application which makes your mac more secure in public or unsafe environment.
This also happens to be my first time developing an app for macOS.

# What does it offer?
Enhanced Security in privacy-compromised environment.
- **Lockdown Mode:** Fast Disabling of touchID for enhanced security in privacy-compromised environment.
- **Restore:** Easy Re-Enabling
- **Lockdown & Sleep:** Automatic Lockdown -> Sleep -> Automatic Restore at Wake

# How to use it?
- Mount the dmg file.
- Move FortressMode.app to /Applications
- Run
- Allow apps from unknown developers in Settings > Privac & Security > Scroll Down to the bottom > Allow FortressMode
- Install Helper Tool
- Use as you need!

# How it works & How I created it?
- I first tried using AI to get a roadmap & suggestions. I followed it and it was a disaster. But I learned basic functionalities of Swift and how project management, targets, permissions, etc. work on XCode.
- I started googling everything and re-built everything from scratch.
- A Helper Tool is installed that communicates with bioutil to enable/disable TouchID.
- The main app lives in the menu bar where you have a few options to choose from -- all basically leading to enabling/disabling TouchID.
- Now that I've finished building it, it seems easy but it was extremely difficult when I was building it... took me a lot of googling to work my way around things and figure everything out.

# Declaration of AI Usage
- Getting name inspirations for the app
- Getting a roadmap to create the app -- which did not work, sadly :sob:
- Fixing Bugs & Errors

# 🏰 FortressMode
FortressMode is a lightweight macOS menu bar utility designed to harden your Mac's security in public or high-risk environments.
This is my first time developing a macOS app for the first time and it has not been an easy journey but fun; and I learned swift so that's a plus. 

# 🚀 Features
#### Lockdown Mode: 
Instantly disables TouchID via a privileged helper tool. This ensures that in a compromised environment, biometric access cannot be forced.

#### Restore Mode: 
Quickly re-enables TouchID functionality once you are back in a safe zone.

#### Lockdown & Sleep:
A macro that triggers Lockdown, puts the Mac to sleep immediately, and prepares it to automatically Restore TouchID upon wake-up.
Typical for briefly leaving your desk or taking a nap.

# 🛠️ How to Use
#### Install: 
Download the .dmg and move FortressMode.app to your /Applications folder.

#### Authorize: 
On the first run, macOS will protect you from an "Unknown Developer." 
Go to System Settings > Privacy & Security, scroll to the bottom, and click Allow Anyway for FortressMode.

#### Install Helper:
Click "Install Helper Tool" within the app. 
You will be prompted for your administrator password—this allows the app to communicate with system-level biometric settings.

#### Stay Secure: 
Use the menu bar icon to toggle your security state as needed.

# 🏗️ The Build Journey
This project was a masterclass in "Learning by Doing."

**The AI Beginning:** I started with an AI roadmap that, frankly, didn't work. However, the failure was the best teacher; it forced me to learn the core architecture of Xcode, target management, and how Swift actually talks to the OS.

**The Rebuild:** I scrapped the initial code and rebuilt the app from scratch using documentation and a lot of trial and error.

**Under the Hood:** The app utilizes a Privileged Helper Tool that runs with elevated permissions to interact with bioutil. It uses an XPC (XPC Inter-Process Communication) bridge to send commands safely between the user interface and the system level.

"It seems easy now that it's finished, but the journey was filled with 'Permission Denied' errors and configuration hurdles that made the final 'Success' feel incredible."

# 🤖 Declaration of AI Usage
- Brainstorming the name "FortressMode."
- Attempting an initial roadmap (not very helpful though _sob_).
- Helping troubleshoot specific syntax errors and refining logic during the final stages of development.
- Emojis for this README file.

# ⚖️ License
Internal/Personal Project - Created by aishwaryarana819
