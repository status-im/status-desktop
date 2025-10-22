// WebChannel integration with retry mechanism
function initializeWebChannel() {
    if (typeof qt !== 'undefined' && qt.webChannelTransport) {
        console.log("[Ethereum Injector] WebChannel transport available, initializing...");
        
        try {
            new QWebChannel(qt.webChannelTransport, setupEthereumProvider);
        } catch (error) {
            console.error("[Ethereum Injector] Error initializing WebChannel:", error);
        }
    } else {
        // console.log("[Ethereum Injector] WebChannel transport not available, retrying...");
        // Retry after a short delay
        // setTimeout(initializeWebChannel, 100);
    }
}

// Start initialization
initializeWebChannel();

// Setup Ethereum provider
function setupEthereumProvider(channel) {
    // Get the EIP-1193 provider QtObject object (WebChannel.id = "ethereumProvider")
    window.ethereumProvider = channel.objects.ethereumProvider;
    
    if (!window.ethereumProvider) {
        console.error("[Ethereum Injector] ethereumProvider not found in channel.objects");
        return;
    }
    
    console.log("[Ethereum Injector] ethereumProvider exposed to window");

    // Install the EIP-1193 js wrapper
    if (typeof EthereumWrapper !== 'undefined' && EthereumWrapper.install) {
        EthereumWrapper.install();
    } else {
        console.error("[Ethereum Injector] EthereumWrapper not available");
    }
}


