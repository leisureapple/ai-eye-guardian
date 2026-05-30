# Little Ant Runner

A tiny macOS desktop toy: a green ant crawls across the screen while a colorful rooster chases it.

The app is a transparent, click-through overlay. It does not take focus, does not show a Dock icon, and can run across one or more displays.

## What It Does

- Draws a vivid green ant that crawls around the desktop.
- Plays a real rooster frame animation extracted from `hen.mp4`.
- Lets the rooster chase the ant.
- Supports one display and multi-display setups.
- Adds a menu bar item named `蚂蚁` for pause, speed changes, bring-to-front, and quit.

## Display Behavior

The app checks the active macOS screens at runtime with `NSScreen.screens`.

### Single Display

If the Mac has only one screen:

- The ant and rooster stay on that screen.
- Edge tunneling is disabled because there is no other screen to tunnel into.
- Movement targets are generated inside the usable screen area so the animation remains visible.

### Main Display + External Display

If the Mac has a main display and one or more external displays:

- A transparent overlay window is created for every screen.
- The ant can move between screens.
- The rooster can chase across screens.
- When the rooster exits from the left, right, top, or bottom edge of one screen, it enters another screen from the opposite edge.
- If a display is connected or disconnected while the app is running, the overlay windows are rebuilt automatically.

## Build

Requirements:

- macOS
- Xcode Command Line Tools with `swiftc`

Build the app:

```bash
./04_scripts/build_app.sh
```

The app will be created at:

```text
03_outputs/Little Ant Runner.app
```

## Run

```bash
./04_scripts/start_ant.sh
```

Stop it:

```bash
./04_scripts/stop_ant.sh
```

You can also open:

```text
03_outputs/Little Ant Runner.app
```

## Package a Zip

```bash
./04_scripts/package_app.sh
```

The zip will be saved to:

```text
03_outputs/LittleAntRunner-macOS.zip
```

## Replace the Rooster Video

The packaged app uses PNG frames from:

```text
Assets/rooster_frames/
```

To regenerate those frames from a different video:

```bash
./04_scripts/generate_rooster_frames.sh /path/to/your/rooster.mp4
```

This script requires `ffmpeg`.

## Notes for Downloaded Apps

This is a locally built, unsigned macOS app. If someone downloads the zip from GitHub, macOS Gatekeeper may require them to right-click the app and choose `Open` the first time.

## License

No open-source license has been selected yet. Before making the repository public or accepting outside reuse, add the license you want and confirm that the rooster video/frame assets are allowed to be redistributed.
