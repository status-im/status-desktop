#ifndef NATIVEWEBVIEWBACKEND_H
#define NATIVEWEBVIEWBACKEND_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QUrl>

class QQuickItem;

/**
 * @brief Abstract interface for platform-specific WebView implementations.
 * 
 * This interface defines the contract for WebView backends that support
 * WebChannel communication through platform-native IPC mechanisms
 * (WKUserContentController on Darwin, JavaScriptInterface on Android).
 */
class NativeWebViewBackend : public QObject
{
    Q_OBJECT

public:
    explicit NativeWebViewBackend(QObject *parent = nullptr) : QObject(parent) {}
    virtual ~NativeWebViewBackend() = default;

    // ===== WebView Operations =====
    
    /**
     * @brief Load a URL in the WebView.
     */
    virtual void loadUrl(const QUrl &url) = 0;
    
    /**
     * @brief Load HTML content with an optional base URL.
     */
    virtual void loadHtml(const QString &html, const QUrl &baseUrl = QUrl()) = 0;
    
    /**
     * @brief Get the native WebView handle (WKWebView* on Darwin, jobject on Android).
     */
    virtual void* nativeHandle() const = 0;
    
    /**
     * @brief Execute JavaScript in the WebView.
     */
    virtual void runJavaScript(const QString &script) = 0;

    // ===== WebChannel Bridge =====
    
    /**
     * @brief Install the message bridge for WebChannel communication.
     * 
     * This sets up the native IPC mechanism (WKScriptMessageHandler on Darwin,
     * JavaScriptInterface on Android) and injects the necessary JavaScript.
     * 
     * @param ns The JavaScript namespace for the bridge (e.g., "qt")
     * @param allowedOrigins List of allowed origins for security
     * @param invokeKey Unique key for this navigation session
     * @param webChannelScriptPath Path to qwebchannel.js resource (optional)
     * @param userScripts List of resource paths to additional scripts to inject
     * @return true if bridge was installed successfully
     */
    virtual bool installMessageBridge(const QString &ns,
                                      const QStringList &allowedOrigins,
                                      const QString &invokeKey,
                                      const QString &webChannelScriptPath = QString(),
                                      const QStringList &userScripts = QStringList()) = 0;
    
    /**
     * @brief Send a message to JavaScript via the WebChannel transport.
     * 
     * @param json JSON-encoded message to send
     */
    virtual void postMessageToJavaScript(const QString &json) = 0;

    // ===== View Setup =====
    
    /**
     * @brief Set up the native view within the given QQuickItem's window.
     * 
     * @param item The QQuickItem that will host the native view
     */
    virtual void setupInItem(QQuickItem *item) = 0;
    
    /**
     * @brief Update the native view's geometry to match the QQuickItem.
     * 
     * @param item The QQuickItem whose geometry to match
     */
    virtual void updateGeometry(QQuickItem *item) = 0;

signals:
    /**
     * @brief Emitted when a message is received from JavaScript.
     * 
     * @param message The message content (JSON string)
     * @param origin The origin of the message
     * @param isMainFrame Whether the message came from the main frame
     */
    void webMessageReceived(const QString &message,
                           const QString &origin,
                           bool isMainFrame);
    
    /**
     * @brief Emitted when loading state changes.
     * 
     * @param loading Whether the WebView is currently loading
     */
    void loadingChanged(bool loading);
    
    /**
     * @brief Emitted when the URL changes.
     */
    void urlChanged(const QUrl &url);
    
    /**
     * @brief Emitted when loading starts (for bridge reinstallation).
     */
    void loadStarted();
};

/**
 * @brief Factory function to create the platform-specific backend.
 * 
 * @param parent Parent QObject
 * @return Platform-specific NativeWebViewBackend implementation
 */
NativeWebViewBackend* createPlatformBackend(QObject *parent = nullptr);

#endif // NATIVEWEBVIEWBACKEND_H

