function initializeWebChannel() {
    if (typeof qt !== 'undefined' && qt.webChannelTransport) {
        console.log("[Ethereum Injector] WebChannel transport available, initializing...");
        
        try {
            new QWebChannel(qt.webChannelTransport, setupProviders);
        } catch (error) {
            console.error("[Ethereum Injector] Error initializing WebChannel:", error);
        }
    }
}

initializeWebChannel();

function setupProviders(channel) {
    // Setup Ethereum Provider (Eip1193ProviderAdapter.qml)
    window.ethereumProvider = channel.objects.ethereumProvider;
    
    if (!window.ethereumProvider) {
        console.error("[Ethereum Injector] ethereumProvider not found in channel.objects");
        return;
    }
    
    console.log("[Ethereum Injector] ethereumProvider exposed to window");

    // Setup Site Utils (SiteUtilsAdapter.qml)
    const siteUtils = channel.objects.siteUtils;
    if (siteUtils && window.StatusSiteUtils) {
        window.StatusSiteUtils.connectToAdapter(siteUtils);
    }

    // Install the EIP-1193 js wrapper
    if (typeof EthereumWrapper !== 'undefined' && EthereumWrapper.install) {
        EthereumWrapper.install();
    } else {
        console.error("[Ethereum Injector] EthereumWrapper not available");
    }
}


