#ifndef NATIVEWEBVIEW_H
#define NATIVEWEBVIEW_H

#include <QQuickItem>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <QWebChannel>
class NativeWebViewBackend;
class NativeWebViewTransport;

/**
 * @brief QML component for displaying web content using native platform WebView.
 * 
 * This component provides a platform-independent interface to native WebViews
 * (WKWebView on Darwin, android.webkit.WebView on Android) with support for
 * QWebChannel communication.
 * 
 * Example usage in QML:
 * @code
 * import QtWebChannel 1.0
 * 
 * NativeWebView {
 *     id: webView
 *     anchors.fill: parent
 *     url: "https://example.com"
 *     
 *     webChannel: WebChannel {
 *         registeredObjects: [myObject]
 *     }
 * }
 * @endcode
 */
class NativeWebView : public QQuickItem
{
    Q_OBJECT
    QML_NAMED_ELEMENT(NativeWebView)
    
    // Content properties
    Q_PROPERTY(QString htmlContent READ htmlContent WRITE setHtmlContent NOTIFY htmlContentChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    
    // WebChannel properties
    Q_PROPERTY(QWebChannel* webChannel READ webChannel WRITE setWebChannel NOTIFY webChannelChanged)
    Q_PROPERTY(QString webChannelNamespace READ webChannelNamespace WRITE setWebChannelNamespace NOTIFY webChannelNamespaceChanged)
    Q_PROPERTY(QStringList allowedOrigins READ allowedOrigins WRITE setAllowedOrigins NOTIFY allowedOriginsChanged)
    Q_PROPERTY(QString webChannelScriptPath READ webChannelScriptPath WRITE setWebChannelScriptPath NOTIFY webChannelScriptPathChanged)
    Q_PROPERTY(QStringList userScripts READ userScripts WRITE setUserScripts NOTIFY userScriptsChanged)
    
    // Status properties
    Q_PROPERTY(bool loading READ isLoading NOTIFY loadingChanged)

public:
    explicit NativeWebView(QQuickItem *parent = nullptr);
    ~NativeWebView() override;

    // Content accessors
    QString htmlContent() const { return m_htmlContent; }
    void setHtmlContent(const QString &html);
    
    QUrl url() const { return m_url; }
    void setUrl(const QUrl &url);
    
    // WebChannel accessors
    QWebChannel* webChannel() const { return m_channel; }
    void setWebChannel(QWebChannel *channel);
    
    QString webChannelNamespace() const { return m_namespace; }
    void setWebChannelNamespace(const QString &ns);
    
    QStringList allowedOrigins() const { return m_allowedOrigins; }
    void setAllowedOrigins(const QStringList &origins);
    
    QString webChannelScriptPath() const { return m_webChannelScriptPath; }
    void setWebChannelScriptPath(const QString &path);
    
    QStringList userScripts() const { return m_userScripts; }
    void setUserScripts(const QStringList &scripts);
    
    // Status
    bool isLoading() const { return m_loading; }

    // Methods
    Q_INVOKABLE void loadHtml(const QString &html, const QUrl &baseUrl = QUrl());
    Q_INVOKABLE void loadUrl(const QUrl &url);
    Q_INVOKABLE void runJavaScript(const QString &script);
    
    /**
     * @brief Send a message to JavaScript via the WebChannel transport.
     * 
     * This is called by NativeWebViewTransport to send QWebChannel messages.
     */
    void postMessageToJavaScript(const QString &json);
    
    /**
     * @brief Get the platform-specific backend.
     */
    NativeWebViewBackend* backend() const { return m_backend; }

signals:
    void htmlContentChanged();
    void urlChanged();
    void webChannelChanged();
    void webChannelNamespaceChanged();
    void allowedOriginsChanged();
    void webChannelScriptPathChanged();
    void userScriptsChanged();
    void loadingChanged();
    void bridgeReady();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private slots:
    void onWebMessageReceived(const QString &message, const QString &origin, bool isMainFrame);
    void onLoadStarted();
    void onLoadingChanged(bool loading);
    void onBackendUrlChanged(const QUrl &url);

private:
    void setupNativeView();
    void updateNativeViewGeometry();
    void installWebChannelBridge();
    void generateNewInvokeKey();

    // Backend (platform-specific implementation)
    NativeWebViewBackend *m_backend;
    
    // WebChannel
    QWebChannel *m_channel;
    NativeWebViewTransport *m_transport;
    QString m_namespace;
    QStringList m_allowedOrigins;
    QString m_invokeKey;
    
    // Content state
    QString m_htmlContent;
    QUrl m_url;
    QString m_webChannelScriptPath;
    QStringList m_userScripts;
    bool m_loading;
    bool m_viewSetup;
};

#endif // NATIVEWEBVIEW_H
