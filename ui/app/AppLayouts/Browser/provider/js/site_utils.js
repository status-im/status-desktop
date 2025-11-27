"use strict";

// Site utilities for Status Browser - clears origin-scoped storage
(function() {
    let _adapter = null;

    async function clearSiteData() {
        try { localStorage.clear(); } catch(e) {}
        try { sessionStorage.clear(); } catch(e) {}

        if (indexedDB?.databases) {
            try {
                const dbs = await indexedDB.databases();
                await Promise.all(dbs.map(db => new Promise(resolve => {
                    const req = indexedDB.deleteDatabase(db.name);
                    req.onsuccess = req.onerror = req.onblocked = resolve;
                })));
            } catch(e) {}
        }
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
