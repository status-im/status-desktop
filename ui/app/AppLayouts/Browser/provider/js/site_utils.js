"use strict";

// Site utilities for Status Browser - clears origin-scoped storage
(function() {
    let _adapter = null;

    async function clearSiteData() {
        // Clear localStorage
        try { localStorage.clear(); } catch(e) {}

        // Clear sessionStorage
        try { sessionStorage.clear(); } catch(e) {}

        // Clear all IndexedDB databases
        if (indexedDB?.databases) {
            try {
                const dbs = await indexedDB.databases();
                await Promise.all(dbs.map(db => new Promise(resolve => {
                    const req = indexedDB.deleteDatabase(db.name);
                    req.onsuccess = req.onerror = req.onblocked = resolve;
                })));
            } catch(e) {}
        }

        // Clear Cache Storage (Service Worker caches)
        if (window.caches) {
            try {
                const cacheNames = await caches.keys();
                await Promise.all(cacheNames.map(name => caches.delete(name)));
            } catch(e) {}
        }

        // Unregister all Service Workers
        if (navigator.serviceWorker) {
            try {
                const registrations = await navigator.serviceWorker.getRegistrations();
                await Promise.all(registrations.map(reg => reg.unregister()));
            } catch(e) {}
        }

        // Clear cookies for current domain
        try {
            document.cookie.split(";").forEach(cookie => {
                const name = cookie.split("=")[0].trim();
                document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/";
            });
        } catch(e) {}
    }

    async function clearSiteDataAndReload() {
        await clearSiteData();
        location.reload();
    }

    function connectToAdapter(adapter) {
        if (_adapter || !adapter?.clearSiteDataAndReloadRequested?.connect) return;
        _adapter = adapter;
        adapter.clearSiteDataAndReloadRequested.connect(clearSiteDataAndReload);
    }

    window.StatusSiteUtils = { clearSiteData, clearSiteDataAndReload, connectToAdapter };
})();
