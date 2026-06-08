// Service worker mínimo: habilita la instalación (PWA) y toma control al activarse.
self.addEventListener("install",  ()      => self.skipWaiting())
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()))
// Passthrough: el navegador gestiona la red. La presencia de un handler de fetch
// satisface el criterio de instalabilidad.
self.addEventListener("fetch", () => {})
