// Initialize extension
chrome.runtime.onInstalled.addListener(() => {
  chrome.storage.sync.set({
    enabled: true,
    interval: 20, // minutes
    duration: 20, // seconds
    lastBreakTime: Date.now()
  });
});

// Check for eye break reminders
chrome.alarms.create('checkEyeBreak', { periodInMinutes: 1 });

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'checkEyeBreak') {
    checkAndNotifyEyeBreak();
  }
});

function checkAndNotifyEyeBreak() {
  chrome.storage.sync.get({
    enabled: true,
    interval: 20,
    duration: 20,
    lastBreakTime: Date.now()
  }, (settings) => {
    if (!settings.enabled) return;

    const now = Date.now();
    const elapsedMinutes = (now - settings.lastBreakTime) / (1000 * 60);

    if (elapsedMinutes >= settings.interval) {
      // Time for a break!
      showBreakNotification(settings.duration);
      chrome.storage.sync.set({ lastBreakTime: now });
    }
  });
}

function showBreakNotification(duration) {
  chrome.notifications.create('eyebreak', {
    type: 'basic',
    iconUrl: 'icons/icon-128.png',
    title: '👁️ Time for an Eye Break!',
    message: `Look away from the screen for ${duration} seconds. Follow the rooster! 🐓`,
    priority: 2,
    requireInteraction: true
  });

  // Auto-close notification after duration
  setTimeout(() => {
    chrome.notifications.clear('eyebreak');
  }, duration * 1000 + 2000);
}

// Handle notification click
chrome.notifications.onClicked.addListener((notificationId) => {
  if (notificationId === 'eyebreak') {
    chrome.notifications.clear(notificationId);
  }
});

// Inject content script into all tabs
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete') {
    chrome.tabs.sendMessage(tabId, { action: 'checkEnabled' }).catch(() => {
      // Tab might not have content script loaded
    });
  }
});
