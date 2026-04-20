# BenBio

A Biorhythm app for the iPhone, Apple Watch and MacOS.

## Trouble Shooting for Apple Watch

### Make Xcode recognize your paired Apple Watch

If your Apple Watch is paired with your iPhone but doesn’t show up in Xcode, work through these steps.

#### 1) Check version compatibility
- Ensure your Xcode version supports the installed iOS and watchOS versions.
- If you’re on beta iOS/watchOS, use the matching Xcode beta.
- After updating Xcode, open it once and let it finish installing components.

#### 2) Enable Developer Mode on both devices
- iPhone: Settings > Privacy & Security > Developer Mode > On (restart if prompted).
- Apple Watch: Settings (on the watch) > Developer > Developer Mode > On (restart if prompted).

#### 3) Prepare devices in Xcode
- Connect the iPhone to your Mac via USB (first time is most reliable).
- On iPhone, tap "Trust This Computer" if prompted.
- In Xcode: Window > Devices and Simulators, select your iPhone.
- Wait for any status like "Preparing debugger support" / "Installing symbol files" to finish.
- Keep the watch unlocked and on your wrist; briefly opening an app can help wake it fully.

You should see a "Paired Watches" section when your iPhone is selected. Your watch should appear there once preparation finishes.

#### 4) Choose the correct run destination (scheme matters)
- The watch only appears as a run destination when a watchOS target is active.
- In Xcode, switch to your Watch App scheme: Product > Scheme > select your Watch App.
- Use the run destination menu (next to the Play/Stop buttons) and pick:
  - "Apple Watch • <Your iPhone’s name>"

If your project doesn’t include a watchOS target, the watch won’t appear as a run destination in the toolbar. It can still appear under Window > Devices and Simulators (nested under the iPhone), but you can’t run to it without a watch target.

#### 5) Enable wireless debugging (optional but helpful)
- In Devices and Simulators, select your iPhone and check "Connect via network".
- On iPhone: Settings > Developer > Wireless Debugging > On.
- Ensure Mac and iPhone are on the same Wi‑Fi network.

Note: The watch debug connection goes through the iPhone, so the iPhone must be visible to Xcode first.

#### 6) If it still doesn’t appear, try these resets
- Restart Mac, iPhone, and Apple Watch.
- Toggle Developer Mode off/on on both devices, then restart.
- Unplug/replug the iPhone and reopen Window > Devices and Simulators.
- Ensure device support files are present by keeping Xcode up-to-date.

#### 7) Quick diagnostics
- In Devices and Simulators, select your iPhone and check the "Paired Watches" section.
- Verify the watch is unlocked and on your wrist.
- Confirm the watchOS version is supported by your Xcode build tools.

#### 8) What to share if you need help
- Xcode version (Xcode > About Xcode)
- iPhone model and iOS version
- Apple Watch model and watchOS version
- Whether your project has a watchOS target/scheme
- Whether the watch appears under Window > Devices and Simulators > (select your iPhone) > Paired Watches

#### Fixes when nothing helps

0.) I turned on developer mode on my iPhone 1.) I tried to run watchOS app from Xcode on my watch although it said its unavailable 2.) I turned off developer mode on my iPhone (for me untrust devices helped already plus reattaching the Phone va cable twice and Trust) and they turned it back on 3.) Tried to run app watchOS app from Xcode again on my watch, this time I got error massage that I need to turn on developer mode 4.) I went back to Privacy&Settings on my watch I Developer Mode appeared on the bottom
