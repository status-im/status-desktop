// Helper functions for instantiating QWebChannel
// Requires loading of qwebchannel.js first
function initializeWebChannel() {
    if (window.statusq && window.statusq.channel) {
        console.error("WebChannel already initialized");
        window.statusq.error = "WebChannel already initialized";
        return;
    }

    window.statusq = {error: ""}
    try {
        window.statusq.channel = new QWebChannel(qt.webChannelTransport);
    } catch (e) {
        console.error("Unable to initialize WebChannel", e);
        window.statusq.error = "initialize WebChannel fail: " + e.message;
    }
}

initializeWebChannel();