const CACHE_NAME = "worth-pwa-v1.10";
const ASSETS = [
  "/",
  "/features",
  "/download",
  "/changelog",
  "/contact",
  "/support",
  "/roadmap",
  "/update",
  "/privacy",
  "/terms",
  "/manifest.json",
  "/favicon.ico",
  "/icons/icon-192.png",
  "/icons/icon-512.png",
  "/og/og-image.png"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS);
    })
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    })
  );
});

self.addEventListener("fetch", (event) => {
  // Only handle GET requests and exclude wrangler/devtools resources
  if (event.request.method !== "GET" || event.request.url.startsWith("chrome-extension:")) return;

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse;
      }
      return fetch(event.request).then((response) => {
        // Cache new static assets
        if (response.status === 200 && event.request.url.startsWith(self.location.origin)) {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      }).catch(() => {
        // Fallback for document pages if offline and not cached
        if (event.request.headers.get("accept").includes("text/html")) {
          return caches.match("/");
        }
      });
    })
  );
});
