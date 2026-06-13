# Codex Chrome Extension - Installation Guide

This guide will help you install the Codex Eye Guardian Chrome Extension on your local machine.

## Prerequisites

- Google Chrome or Chromium browser
- The extension files from this repository

## Installation Steps

### Step 1: Enable Developer Mode

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable **Developer mode** using the toggle in the top-right corner
3. You should now see options for "Load unpacked", "Pack extension", etc.

### Step 2: Load the Extension

1. In the `chrome://extensions/` page, click **Load unpacked**
2. Navigate to the `ai-eye-guardian` directory (where you cloned this repository)
3. Select the folder and click **Select**
4. The extension should now appear in your extensions list with the ID and status

### Step 3: Verify Installation

1. Look for the eye icon (👁️) in your Chrome toolbar
2. Click the extension icon to open the popup
3. You should see:
   - Extension status (Active/Paused)
   - Toggle button to pause/resume
   - Interval and duration sliders
   - Time until next break

## Features

### Popup Controls
- **Toggle button**: Pause or resume eye break reminders
- **Reset timer**: Start a new interval immediately
- **Interval slider**: Set how often you get break reminders (5-60 minutes)
- **Duration slider**: Set break duration (10-60 seconds)
- **Timer display**: Shows time until next break

### How It Works

1. The extension monitors your browsing time
2. Every time the set interval passes (default: 20 minutes), you'll get a notification
3. The notification reminds you to look away for the set duration (default: 20 seconds)
4. You can pause reminders, adjust intervals, or reset the timer anytime

## Tips for Best Results

- Set a comfortable interval (20-30 minutes is recommended)
- Keep your duration between 20-30 seconds
- Use the timer display to know when your next break is due
- Pause the extension if you're in a meeting or focused work

## Generating Extension Icons

To generate proper PNG icons for the extension:

```bash
# Option 1: Using ImageMagick
./generate_icons.sh

# Option 2: Using Python (requires Pillow)
pip install Pillow
python3 generate_icons.py
```

If icons don't generate, the extension will still work with placeholder icons.

## Troubleshooting

### Notification not appearing?
- Check that notifications are enabled in Chrome settings
- Make sure the extension is set to "Active" in the popup
- Check browser notification permissions for the extension

### Extension not loading?
- Make sure you selected the correct directory (the one containing `manifest.json`)
- Try clicking the refresh icon on the extension card
- Check the console for errors (click the extension -> Errors)

### Changes not taking effect?
- After making changes to the code, click the refresh icon on the extension card
- Close and reopen the popup to see new changes

## File Structure

```
ai-eye-guardian/
├── manifest.json          # Extension configuration
├── popup.html            # Extension popup UI
├── popup.js              # Popup logic and controls
├── background.js         # Background service worker
├── content.js            # Content script for web pages
├── icons/                # Extension icons
│   ├── icon-16.png
│   ├── icon-32.png
│   ├── icon-48.png
│   └── icon-128.png
└── generate_icons.sh     # Icon generation script
```

## Next Steps

1. Open a few tabs and start browsing
2. Wait for the interval to pass (or click "Reset Timer" to test immediately)
3. You should see a notification prompting an eye break
4. Try adjusting the interval and duration sliders

Enjoy your eye breaks! 👁️🐓
