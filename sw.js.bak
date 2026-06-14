/* ═══════════════════════════════════════════════════════════
   Mama Daily Tracker — Service Worker
   Handles: push notifications, network-first caching
═══════════════════════════════════════════════════════════ */

const CACHE = 'mama-daily-v2';

// ── Install & cache shell ────────────────────────────────
self.addEventListener('install', e => {
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// ── Network-first fetch (keeps app up to date) ───────────
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request)
      .then(res => {
        const clone = res.clone();
        caches.open(CACHE).then(c => c.put(e.request, clone));
        return res;
      })
      .catch(() => caches.match(e.request))
  );
});

// ── Push received ────────────────────────────────────────
self.addEventListener('push', e => {
  let data = { title: 'Mama Daily', body: 'You have a reminder.' };
  try { data = e.data.json(); } catch(_) {}

  e.waitUntil(
    self.registration.showNotification(data.title, {
      body:    data.body,
      icon:    'icons/icon-192.png',
      badge:   'icons/icon-192.png',
      tag:     data.tag || 'mama-daily',
      data:    { url: self.location.origin },
      vibrate: [200, 100, 200],
    })
  );
});

// ── Notification click → open / focus the app ───────────
self.addEventListener('notificationclick', e => {
  e.notification.close();
  const target = e.notification.data?.url || self.location.origin;
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
      const existing = list.find(c => c.url.startsWith(target));
      if (existing) return existing.focus();
      return clients.openWindow(target);
    })
  );
});
