// Content script for Eye Guardian
// This runs on every page and can inject visual elements

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'checkEnabled') {
    chrome.storage.sync.get({ enabled: true }, (settings) => {
      sendResponse({ enabled: settings.enabled });
    });
    return true;
  }
});

// Listen for break notifications
chrome.storage.onChanged.addListener((changes, areaName) => {
  if (areaName === 'sync' && changes.lastBreakTime) {
    // Could trigger a visual indicator on the page
    showBreakIndicator();
  }
});

function showBreakIndicator() {
  // Create a subtle break indicator
  const indicator = document.createElement('div');
  indicator.id = 'eye-guardian-break';
  indicator.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 12px 16px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 6px;
    z-index: 999999;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 14px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    animation: slideIn 0.3s ease-out;
  `;
  indicator.textContent = '👁️ Time for an eye break! Look away for 20 seconds. 🐓';

  const style = document.createElement('style');
  style.textContent = `
    @keyframes slideIn {
      from {
        opacity: 0;
        transform: translateX(400px);
      }
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }

    @keyframes slideOut {
      from {
        opacity: 1;
        transform: translateX(0);
      }
      to {
        opacity: 0;
        transform: translateX(400px);
      }
    }

    #eye-guardian-break.remove {
      animation: slideOut 0.3s ease-out forwards;
    }
  `;

  document.head.appendChild(style);
  document.body.appendChild(indicator);

  // Remove after 5 seconds
  setTimeout(() => {
    indicator.classList.add('remove');
    setTimeout(() => {
      indicator.remove();
    }, 300);
  }, 5000);
}
