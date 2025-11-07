"use strict";

// IIFE start (https://developer.mozilla.org/ru/docs/Glossary/IIFE)
const EthereumWrapper = (function() {
    if (window.__ETHEREUM_WRAPPER_INSTANCE__) {
        return window.__ETHEREUM_WRAPPER_INSTANCE__;
    }
    
    // Manages EIP-1193 provider wrapper around Qml ethereum object (EIP1193ProviderAdapter.qml)
    class EthereumProvider extends EventTarget {
        constructor(nativeEthereum) {
            super();
            
            if (!nativeEthereum) {
                console.error("[Ethereum Wrapper] nativeEthereum is not available");
                throw new Error("nativeEthereum is required");
            }

            this.listeners = new Map(); // event -> Set<handler>
            this.nativeEthereum = nativeEthereum;
            this.requestIdCounter = 1; // async requests
            this.pendingRequests = new Map(); // requestId -> { resolve, reject }
            
            // Wire native signals to events
            this._wireSignals();
            
            // Set up EIP-1193 properties from QML
            this.isStatus = nativeEthereum.isStatus !== undefined ? nativeEthereum.isStatus : true;
            this.isMetaMask = nativeEthereum.isMetaMask !== undefined ? nativeEthereum.isMetaMask : false;
            this.chainId = null;  // Will be set on first eth_chainId request or providerStateChanged event
            this.networkVersion = null;  // decimal string format (deprecated)
            this.selectedAddress = null;  // current active address
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
                this._emit('connect', info);
            });

            this._connectSignal('disconnectEvent', (error) => {
                this._emit('disconnect', error);
            });

            this._connectSignal('messageEvent', (message) => {
                this._emit('message', message);
            });

            this._connectSignal('chainChangedEvent', (chainId) => {
                this._emit('chainChanged', chainId);
            });

            this._connectSignal('accountsChangedEvent', (accounts) => {
                this._emit('accountsChanged', accounts);
            });

            // Provider state changed - update all properties at once
            this._connectSignal('providerStateChanged', () => {
                this.isStatus = this.nativeEthereum.isStatus !== undefined ? this.nativeEthereum.isStatus : this.isStatus;
                this.isMetaMask = this.nativeEthereum.isMetaMask !== undefined ? this.nativeEthereum.isMetaMask : this.isMetaMask;
                this.chainId = this.nativeEthereum.chainId || this.chainId;
                this.networkVersion = this.nativeEthereum.networkVersion || this.networkVersion;
                this.selectedAddress = this.nativeEthereum.selectedAddress || null;
                this._connected = this.nativeEthereum.connected !== undefined ? this.nativeEthereum.connected : this._connected;
            });

            // Handle async RPC responses
            this._connectSignal('requestCompletedEvent', this.handleRequestCompleted.bind(this));
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

        isConnected() {
            return this._connected;
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
                    }
                    // Response will come via requestCompletedEvent
                } catch (e) {
                    this.pendingRequests.delete(requestId);
                    reject(e);
                }
            });
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
        
        let provider;
        try {
            provider = new EthereumProvider(window.ethereumProvider);
        } catch (error) {
            console.error('[Ethereum Wrapper] Failed to create EthereumProvider:', error);
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


