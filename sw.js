/* ═══════════════════════════════════════════════════════════════
   Mama Daily Tracker — Service Worker v4
   Auto-update: bumps cache on every deploy, notifies app to reload
═══════════════════════════════════════════════════════════════ */

const CACHE_VERSION = 'mama-daily-v4';
const BASE = '/mama-daily-tracker';
const ASSETS = [
  BASE + '/',
  BASE + '/index.html',
  BASE + '/manifest.json',
  'https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,500;0,600;1,400&family=DM+Sans:wght@300;400;500&display=swap',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js',
];

/* ─── INSTALL: cache all assets ────────────────────────────── */
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then(cache =>
      cache.addAll(ASSETS).catch(err => console.warn('[SW] Cache failed:', err))
    )
  );
  // Activate immediately — don't wait for old SW to die
  self.skipWaiting();
});

/* ─── ACTIVATE: wipe old caches, take control now ─────────── */
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(k => k !== CACHE_VERSION)
          .map(k => {
            console.log('[SW] Deleting old cache:', k);
            return caches.delete(k);
          })
      )
    ).then(() => self.clients.claim()) // take control of all open tabs immediately
  );
});

/* ─── FETCH: cache-first for assets, network-first for API ── */
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // Supabase — always network, never cache
  if (url.hostname.includes('supabase.co')) {
    event.respondWith(
      fetch(event.request).catch(() =>
        new Response(JSON.stringify({ error: 'offline' }), {
          headers: { 'Content-Type': 'application/json' },
        })
      )
    );
    return;
  }

  // Everything else — cache first, fall back to network
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      return fetch(event.request).then(response => {
        if (response.ok) {
          const clone = response.clone();
          caches.open(CACHE_VERSION).then(cache => cache.put(event.request, clone));
        }
        return response;
      }).catch(() => {
        if (event.request.mode === 'navigate') {
          return caches.match(BASE + '/index.html');
        }
      });
    })
  );
});

/* ─── MESSAGE: tell the app a new version is ready ────────── */
self.addEventListener('message', event => {
  if (event.data === 'skipWaiting') self.skipWaiting();
});
