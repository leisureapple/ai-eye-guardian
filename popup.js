// UI elements
const toggleBtn = document.getElementById('toggleBtn');
const resetBtn = document.getElementById('resetBtn');
const statusDot = document.getElementById('statusDot');
const statusText = document.getElementById('statusText');
const intervalSlider = document.getElementById('intervalSlider');
const durationSlider = document.getElementById('durationSlider');
const intervalValue = document.getElementById('intervalValue');
const durationValue = document.getElementById('durationValue');
const timerDisplay = document.getElementById('timer');

// Load settings
chrome.storage.sync.get({
  enabled: true,
  interval: 20,
  duration: 20,
  lastBreakTime: 0
}, (settings) => {
  updateUI(settings);
  intervalSlider.value = settings.interval;
  durationSlider.value = settings.duration;
  intervalValue.textContent = settings.interval;
  durationValue.textContent = settings.duration;
});

// Toggle eye breaks
toggleBtn.addEventListener('click', () => {
  chrome.storage.sync.get({ enabled: true }, (settings) => {
    const newState = !settings.enabled;
    chrome.storage.sync.set({ enabled: newState });
    updateUI({ enabled: newState });
  });
});

// Reset timer
resetBtn.addEventListener('click', () => {
  chrome.storage.sync.set({ lastBreakTime: Date.now() });
  updateTimer();
});

// Update interval
intervalSlider.addEventListener('input', (e) => {
  const value = parseInt(e.target.value);
  intervalValue.textContent = value;
  chrome.storage.sync.set({ interval: value });
});

// Update duration
durationSlider.addEventListener('input', (e) => {
  const value = parseInt(e.target.value);
  durationValue.textContent = value;
  chrome.storage.sync.set({ duration: value });
});

function updateUI(settings) {
  if (settings.enabled) {
    statusDot.classList.remove('inactive');
    statusText.textContent = 'Active';
    toggleBtn.textContent = 'Pause Eye Breaks';
  } else {
    statusDot.classList.add('inactive');
    statusText.textContent = 'Paused';
    toggleBtn.textContent = 'Resume Eye Breaks';
  }
}

function updateTimer() {
  chrome.storage.sync.get({
    interval: 20,
    lastBreakTime: 0
  }, (settings) => {
    const now = Date.now();
    const elapsed = Math.floor((now - settings.lastBreakTime) / 1000);
    const totalSeconds = settings.interval * 60;
    const remaining = Math.max(0, totalSeconds - elapsed);

    const minutes = Math.floor(remaining / 60);
    const seconds = remaining % 60;

    timerDisplay.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;
  });
}

// Update timer every second
setInterval(updateTimer, 1000);
updateTimer();

// Listen for changes from background script
chrome.storage.onChanged.addListener((changes, areaName) => {
  if (areaName === 'sync' && changes.enabled) {
    updateUI({ enabled: changes.enabled.newValue });
  }
});
