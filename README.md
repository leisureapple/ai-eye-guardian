# AI Eye Guardian

AI Eye Guardian is a playful macOS eye-break companion for people who spend long hours in front of a computer, especially AI builders, developers, designers, writers, analysts, and other screen-heavy workers.

Instead of another silent timer that is easy to ignore, it places a moving visual target on your desktop: a vivid green ant crawls around, while a colorful rooster chases it. The tiny chase scene gives your eyes something to follow, helping you break the habit of staring at one fixed point for too long.

> This is not medical software and does not diagnose, treat, or cure eye conditions. It is a lightweight desktop reminder that encourages eye movement and short visual breaks during long work sessions.

## Why It Exists

Modern AI work often means hours of reading prompts, watching logs, comparing model outputs, editing code, and checking dashboards. Your eyes may stay locked on the same small area of the screen for a long time.

AI Eye Guardian turns a small corner of your desktop into a moving focus exercise:

- Follow the ant for a few seconds.
- Let your eyes track the rooster as it chases across the screen.
- Use the motion as a gentle cue to blink, look away, or take a short break.

The goal is simple: make eye breaks less boring, more visible, and harder to forget.

## What It Does

- Runs as a transparent, click-through macOS desktop overlay.
- Shows a green ant crawling across the screen.
- Shows a colorful rooster chasing the ant.
- Supports one display and multi-display setups.
- Works across a main display and external displays.
- Adds a menu bar item named `护眼鸡` for pause, speed changes, bring-to-front, and quit.
- Stays out of the Dock and does not block mouse clicks.

## Display Behavior

The app checks the active macOS screens at runtime with `NSScreen.screens`.

### Single Display

If the Mac has only one screen:

- The ant and rooster stay on that screen.
- Edge tunneling is disabled because there is no other screen to tunnel into.
- Movement targets are generated inside the usable screen area so the animation remains visible.
- The app still works as a moving visual cue for eye breaks.

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
03_outputs/AI Eye Guardian.app
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
03_outputs/AI Eye Guardian.app
```

## Package a Zip

```bash
./04_scripts/package_app.sh
```

The zip will be saved to:

```text
03_outputs/AIEyeGuardian-macOS.zip
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
