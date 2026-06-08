// Service worker de Planner — instalable + offline básico.
// Estrategia:
//  - /assets/* (inmutables, digeridos): cache-first.
//  - navegaciones (HTML): network-first, con fallback a la última página
//    cacheada y, si no hay, una página "sin conexión".
//  - escrituras (POST/PATCH/DELETE): siempre a la red (no se cachean).
const VERSION    = "v1";
const ASSETS     = `planner-assets-${VERSION}`;
const PAGES      = `planner-pages-${VERSION}`;
const OFFLINE_URL = "/offline";

self.addEventListener("install", (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(PAGES);
    try { await cache.add(new Request(OFFLINE_URL, { cache: "reload" })); } catch (e) {}
    self.skipWaiting();
  })());
});

self.addEventListener("activate", (event) => {
  event.waitUntil((async () => {
    const keep = [ASSETS, PAGES];
    for (const key of await caches.keys()) {
      if (!keep.includes(key)) await caches.delete(key);
    }
    await self.clients.claim();
  })());
});

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;                  // escrituras: a la red
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;   // solo same-origin

  if (url.pathname.startsWith("/assets/")) {
    event.respondWith(cacheFirst(req));
  } else if (req.mode === "navigate") {
    event.respondWith(networkFirstPage(req));
  }
});

async function cacheFirst(req) {
  const cache = await caches.open(ASSETS);
  const hit = await cache.match(req);
  if (hit) return hit;
  const res = await fetch(req);
  if (res.ok) cache.put(req, res.clone());
  return res;
}

async function networkFirstPage(req) {
  const cache = await caches.open(PAGES);
  try {
    const res = await fetch(req);
    if (res.ok) cache.put(req, res.clone());
    return res;
  } catch (e) {
    return (await cache.match(req)) ||
           (await cache.match(OFFLINE_URL)) ||
           new Response("Sin conexión", { status: 503, headers: { "Content-Type": "text/plain" } });
  }
}
