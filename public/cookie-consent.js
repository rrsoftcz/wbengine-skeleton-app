// Load the Google Analytics tag only after a visitor allows analytics storage.
(function () {
  var storageKey = 'wbengine.analytics.consent.v1';
  var measurementId = 'G-PRGMM4N3S6';
  var banner = document.getElementById('cookie-banner');
  var settingsButton = document.getElementById('cookie-settings');
  var acceptButton = document.getElementById('cookie-accept');
  var rejectButton = document.getElementById('cookie-reject');
  var currentChoice = null;
  var tagLoaded = false;
  window['ga-disable-' + measurementId] = true;

  if (!banner || !settingsButton || !acceptButton || !rejectButton) { return; }

  function readChoice() {
    if (currentChoice !== null) { return currentChoice; }
    try { return window.localStorage.getItem(storageKey); }
    catch (error) { return null; }
  }

  function saveChoice(choice) {
    currentChoice = choice;
    try { window.localStorage.setItem(storageKey, choice); }
    catch (error) { /* The choice still applies until this page is closed. */ }
  }

  function loadAnalytics() {
    if (tagLoaded) { return; }
    window['ga-disable-' + measurementId] = false;
    tagLoaded = true;

    window.dataLayer = window.dataLayer || [];
    window.gtag = window.gtag || function () { window.dataLayer.push(arguments); };
    window.gtag('consent', 'default', {
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
      analytics_storage: 'denied'
    });
    window.gtag('js', new Date());
    window.gtag('consent', 'update', { analytics_storage: 'granted' });
    window.gtag('config', measurementId);

    var script = document.createElement('script');
    script.async = true;
    script.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(measurementId);
    document.head.appendChild(script);
  }

  function removeAnalyticsCookies() {
    var names = document.cookie.split(';').map(function (cookie) {
      return cookie.trim().split('=')[0];
    }).filter(function (name) {
      return /^(_ga|_gid|_gat|_gac_|_gcl_)/.test(name);
    });
    var labels = window.location.hostname.split('.');
    var domains = [''];
    for (var i = 0; i < labels.length - 1; i++) {
      domains.push('; domain=' + labels.slice(i).join('.'));
      domains.push('; domain=.' + labels.slice(i).join('.'));
    }
    names.forEach(function (name) {
      domains.forEach(function (domain) {
        document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/' + domain + '; SameSite=Lax';
      });
    });
  }

  function closeBanner() {
    banner.classList.add('hidden');
    settingsButton.setAttribute('aria-expanded', 'false');
  }

  function openBanner(moveFocus) {
    banner.classList.remove('hidden');
    settingsButton.setAttribute('aria-expanded', 'true');
    if (moveFocus) { rejectButton.focus(); }
  }

  acceptButton.addEventListener('click', function () {
    saveChoice('granted');
    closeBanner();
    window['ga-disable-' + measurementId] = false;
    loadAnalytics();
  });

  rejectButton.addEventListener('click', function () {
    var wasGranted = readChoice() === 'granted';
    saveChoice('denied');
    closeBanner();
    if (wasGranted) {
      window['ga-disable-' + measurementId] = true;
      if (typeof window.gtag === 'function') {
        window.gtag('consent', 'update', {
          ad_storage: 'denied',
          ad_user_data: 'denied',
          ad_personalization: 'denied',
          analytics_storage: 'denied'
        });
      }
      removeAnalyticsCookies();
      window.location.reload();
    }
  });

  settingsButton.setAttribute('aria-expanded', 'false');
  settingsButton.addEventListener('click', function () { openBanner(true); });

  if (readChoice() === 'granted') { loadAnalytics(); }
  else if (readChoice() !== 'denied') { openBanner(false); }
})();
