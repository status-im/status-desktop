"use strict";

// Site utilities for Status Browser
// Clears origin-scoped browser storage (localStorage, sessionStorage, IndexedDB)
const SiteUtils = (function() {
    let _connected = false;

    function clearSiteData() {
        return new Promise((resolve) => {
            try {
                const result = {
                    success: true,
                    cleared: {
                        localStorage: false,
                        sessionStorage: false,
                        indexedDB: false
                    },
                    origin: window.location.origin
                };
                
                // Clear localStorage
                if (window.localStorage) {
                    try {
                        window.localStorage.clear();
                        result.cleared.localStorage = true;
                        console.log('[SiteUtils] localStorage cleared');
                    } catch (e) {
                        console.warn('[SiteUtils] Failed to clear localStorage:', e);
                    }
                }
                
                // Clear sessionStorage
                if (window.sessionStorage) {
                    try {
                        window.sessionStorage.clear();
                        result.cleared.sessionStorage = true;
                        console.log('[SiteUtils] sessionStorage cleared');
                    } catch (e) {
                        console.warn('[SiteUtils] Failed to clear sessionStorage:', e);
                    }
                }
                
                // Clear IndexedDB databases
                if (window.indexedDB && window.indexedDB.databases) {
                    window.indexedDB.databases()
                        .then((databases) => {
                            const count = databases.length;
                            console.log('[SiteUtils] Found', count, 'IndexedDB databases to clear');
                            
                            databases.forEach((db) => {
                                const req = window.indexedDB.deleteDatabase(db.name);
                                req.onsuccess = () => {
                                    console.log('[SiteUtils] Deleted IndexedDB:', db.name);
                                };
                                req.onerror = () => {
                                    console.warn('[SiteUtils] Failed to delete IndexedDB:', db.name);
                                };
                                req.onblocked = () => {
                                    console.warn('[SiteUtils] IndexedDB deletion blocked:', db.name);
                                };
                            });
                            
                            result.cleared.indexedDB = true;
                            resolve(result);
                        })
                        .catch((err) => {
                            console.warn('[SiteUtils] Failed to enumerate IndexedDB:', err);
                            resolve(result);
                        });
                } else {
                    console.warn('[SiteUtils] indexedDB.databases() not available');
                    resolve(result);
                }
                
            } catch (e) {
                console.error('[SiteUtils] Error clearing site data:', e);
                resolve({ success: false, error: e.message });
            }
        });
    }

    // Connect to SiteUtilsAdapter signal from QML
    function connectToAdapter(adapter) {
        if (_connected || !adapter) return;
        
        if (adapter.clearSiteDataRequested && adapter.clearSiteDataRequested.connect) {
            adapter.clearSiteDataRequested.connect(() => {
                console.log('[SiteUtils] clearSiteDataRequested signal received');
                clearSiteData();
            });
            _connected = true;
            console.log('[SiteUtils] Connected to SiteUtilsAdapter');
        }
    }

    window.StatusSiteUtils = {
        clearSiteData: clearSiteData,
        connectToAdapter: connectToAdapter
    };
    
    return {
        clearSiteData: clearSiteData,
        connectToAdapter: connectToAdapter
    };
    
})();
