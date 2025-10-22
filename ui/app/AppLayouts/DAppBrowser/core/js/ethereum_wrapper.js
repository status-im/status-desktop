"use strict";

// IIFE start (https://developer.mozilla.org/ru/docs/Glossary/IIFE)
// Guard against multiple script loads
const EthereumWrapper = (function() {
    // If already loaded, return existing instance
    if (window.__ETHEREUM_WRAPPER_INSTANCE__) {
        return window.__ETHEREUM_WRAPPER_INSTANCE__;
    }
    
    // Manages EIP-1193 provider wrapper around Qml ethereum object (EIP1193ProviderAdapter.qml)
    class EthereumProvider extends EventTarget {
        constructor(nativeEthereum) {
            super();
            
            if (!nativeEthereum) {
                console.error("[Ethereum Wrapper] nativeEthereum is not available");
                return null;
            }

            this.listeners = new Map(); // event -> Set<handler>
            this.nativeEthereum = nativeEthereum;
            this.requestIdCounter = 1; // async requests
            this.pendingRequests = new Map(); // requestId -> { resolve, reject }
            
            // Wire native signals to events
            this._wireSignals();
            
            // Set up EIP-1193 properties
            this.isStatus = true;
            this.isMetaMask = false;
            this.chainId = null;  // Will be set on first eth_chainId request or chainChanged event
            this._connected = false;
        }

        _connectSignal(eventName, handler) {
            const event = this.nativeEthereum[eventName];
            if (event && event.connect) {
                event.connect(handler);
                return true;
            }
            return false;
        }


        _wireSignals() {
            this._connectSignal('connectEvent', (info) => {
                this._connected = true;
                if (info && info.chainId) {
                    this.chainId = info.chainId;
                }
                this._emit('connect', info);
            });

            this._connectSignal('disconnectEvent', (error) => {
                this._connected = false;
                this._emit('disconnect', error);
            });

            this._connectSignal('messageEvent', (message) => {
                this._emit('message', message);
            });

            this._connectSignal('chainChangedEvent', (chainId) => {
                this.chainId = chainId;
                this._emit('chainChanged', chainId);
            });

            this._connectSignal('accountsChangedEvent', (accounts) => {
                this._emit('accountsChanged', accounts);
            });

            const hasAsyncEvents = this._connectSignal('requestCompletedEvent', 
                this.handleRequestCompleted.bind(this)
            );
            
            if (!hasAsyncEvents) {
                console.warn('[Ethereum Wrapper] requestCompletedEvent not available on native provider');
            }
            
            this._hasAsyncEvents = hasAsyncEvents;
        }

        _emit(event, ...args) {
            const set = this.listeners.get(event);
            if (!set) return;
            for (const handler of set) {
                try { 
                    handler(...args); 
                } catch (e) { 
                    console.error("[Ethereum Wrapper] handler error", e); 
                }
            }
        }

        request(args) {
            if (!args || typeof args !== 'object' || !args.method) {
                return Promise.reject(new Error('Invalid request: missing method'));
            }
            const requestId = this.requestIdCounter++;
            const payload = Object.assign({}, args, { requestId });
            
            return new Promise((resolve, reject) => {
                this.pendingRequests.set(requestId, { resolve, reject, method: args.method });
                
                try {
                    const nativeResp = this.nativeEthereum.request(payload);
                    if (nativeResp && typeof nativeResp === 'object' && nativeResp.error) {
                        this.pendingRequests.delete(requestId);
                        reject(nativeResp.error);
                    } else if (nativeResp && nativeResp.result !== undefined && !this._hasAsyncEvents) {
                        this.pendingRequests.delete(requestId);
                        resolve(nativeResp.result);
                    }
                } catch (e) {
                    this.pendingRequests.delete(requestId);
                    reject(e);
                }
            });
        }

        _updateStateFromResponse(method, result) {
            if (method === 'eth_chainId' && result && this.chainId !== result) {
                this.chainId = result;
            }
        }

        _processResponse(resp, method, entry) {
            if (resp && typeof resp === 'string') {
                try {
                    const parsed = JSON.parse(resp);
                    resp = parsed;
                } catch (e) {
                    entry.resolve(resp);
                    return;
                }
            }
            
            if (resp && resp.error) {
                entry.reject(resp.error);
            } else if (resp && resp.result !== undefined) {
                this._updateStateFromResponse(method, resp.result);
                entry.resolve(resp.result);
            } else {
                entry.resolve(resp);
            }
        }

        handleRequestCompleted(payload) {
            try {
                const requestId = payload && (payload.requestId || (payload.response && payload.response.id)) || 0;
                const entry = this.pendingRequests.get(requestId);
                
                if (!entry) {
                    console.warn("[Ethereum Wrapper] No pending request found for ID:", requestId);
                    return;
                }
                
                this.pendingRequests.delete(requestId);
                this._processResponse(payload && payload.response, entry.method, entry);
            } catch (e) {
                console.error('[Ethereum Wrapper] requestCompletedEvent handler error', e);
            }
        }

        on(event, handler) {
            if (typeof handler !== 'function') return this;
            const set = this.listeners.get(event) || new Set();
            set.add(handler);
            this.listeners.set(event, set);
            return this;
        }

        once(event, handler) {
            if (typeof handler !== 'function') return this;
            const self = this;
            function onceHandler() {
                try { 
                    handler.apply(null, arguments); 
                } finally {
                    self.removeListener(event, onceHandler);
                }
            }
            return this.on(event, onceHandler);
        }

        removeListener(event, handler) {
            const set = this.listeners.get(event);
            if (!set) return this;
            set.delete(handler);
            if (set.size === 0) this.listeners.delete(event);
            return this;
        }

        removeAllListeners(event) {
            if (event) {
                this.listeners.delete(event);
            } else {
                this.listeners.clear();
            }
            return this;
        }

        // Deprecated aliases for compatibility
        addListener(event, handler) { 
            return this.on(event, handler); 
        }
        
        off(event, handler) { 
            return this.removeListener(event, handler); 
        }
    }

    function install() {
        if (!window.ethereumProvider) {
            return false;
        }
        
        if (window.__ETHEREUM_INSTALLED__) {
            return true;
        }
        
        const provider = new EthereumProvider(window.ethereumProvider);
        if (!provider) {
            console.error('[Ethereum Wrapper] Failed to create EthereumProvider');
            return false;
        }

        if (!window.ethereum) {
            Object.defineProperty(window, 'ethereum', {
                value: provider,
                writable: false,
                configurable: false,
                enumerable: true
            });
            window.__ETHEREUM_INSTALLED__ = true;
            window.dispatchEvent(new Event('ethereum#initialized'));
            return true;
        } else {
            console.warn('[Ethereum Wrapper] window.ethereum already present; skipping install');
            return false;
        }
    }
    
    function tryInstall() {
        if (install()) {
            return;
        }
        
        let attempts = 0;
        const maxAttempts = 20;
        const retryInterval = 50;
        
        const retry = () => {
            attempts++;
            if (install()) {
                return;
            }
            
            if (attempts < maxAttempts) {
                setTimeout(retry, retryInterval * Math.min(attempts, 5));
            } else {
                console.error('[Ethereum Wrapper] Failed to install after', maxAttempts, 'attempts');
            }
        };
        
        setTimeout(retry, retryInterval);
    }

    // Return public API if needed
    const instance = {
        EthereumProvider: EthereumProvider,
        install: install,
        tryInstall: tryInstall
    };
    
    // Store instance globally to prevent duplicate loading
    window.__ETHEREUM_WRAPPER_INSTANCE__ = instance;
    
    return instance;

})(); // IIFE end

// Auto-install on script load (only if this is the first instance)
if (!window.__ETHEREUM_AUTO_INSTALL_CALLED__) {
    window.__ETHEREUM_AUTO_INSTALL_CALLED__ = true;
    EthereumWrapper.tryInstall();
}


