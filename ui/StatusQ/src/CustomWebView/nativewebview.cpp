#include "nativewebview.h"
#include "nativewebviewbackend.h"
#include "nativewebviewtransport.h"

#include <QDebug>
#include <QQuickWindow>
#include <QUuid>
#include <QWebChannel>

NativeWebView::NativeWebView(QQuickItem *parent)
    : QQuickItem(parent)
    , m_backend(nullptr)
    , m_channel(nullptr)
    , m_transport(nullptr)
    , m_namespace(QStringLiteral("qt"))
    , m_loading(false)
    , m_viewSetup(false)
{
    setFlag(ItemHasContents, true);
    
    // Create platform-specific backend
    m_backend = createPlatformBackend(this);
    
    if (m_backend) {
        // Connect backend signals
        connect(m_backend, &NativeWebViewBackend::webMessageReceived,
                this, &NativeWebView::onWebMessageReceived);
        connect(m_backend, &NativeWebViewBackend::loadStarted,
                this, &NativeWebView::onLoadStarted);
        connect(m_backend, &NativeWebViewBackend::loadingChanged,
                this, &NativeWebView::onLoadingChanged);
        connect(m_backend, &NativeWebViewBackend::urlChanged,
                this, &NativeWebView::onBackendUrlChanged);
    }
    
    qDebug() << "NativeWebView: Created";
}

NativeWebView::~NativeWebView()
{
    // Backend and transport are children, will be deleted automatically
}

void NativeWebView::setHtmlContent(const QString &html)
{
    if (m_htmlContent == html)
        return;
    
    m_htmlContent = html;
    emit htmlContentChanged();
    
    loadHtml(html, QUrl(QStringLiteral("http://localhost")));
}

void NativeWebView::setUrl(const QUrl &url)
{
    if (m_url == url)
        return;
    
    m_url = url;
    emit urlChanged();
    
    loadUrl(url);
}

void NativeWebView::setWebChannel(QWebChannel *channel)
{
    qDebug() << "NativeWebView::setWebChannel called, channel=" << channel;
    
    if (m_channel == channel)
        return;
    
    m_channel = channel;
    
    // Create transport if needed
    if (m_channel && !m_transport) {
        qDebug() << "NativeWebView: Creating transport";
        m_transport = new NativeWebViewTransport(this, m_namespace, this);
        m_transport->setAllowedOrigins(m_allowedOrigins);
    }
    
    // Connect channel to transport
    if (m_channel && m_transport) {
        qDebug() << "NativeWebView: Connecting channel to transport";
        m_channel->connectTo(m_transport);
    }
    
    // Install bridge if we don't have an invoke key yet
    if (m_invokeKey.isEmpty()) {
        installWebChannelBridge();
    }
    
    emit webChannelChanged();
}

void NativeWebView::setWebChannelNamespace(const QString &ns)
{
    QString newNs = ns.isEmpty() ? QStringLiteral("qt") : ns;
    
    if (m_namespace == newNs)
        return;
    
    m_namespace = newNs;
    
    // Reinstall bridge with new namespace
    if (m_channel) {
        installWebChannelBridge();
    }
    
    emit webChannelNamespaceChanged();
}

void NativeWebView::setAllowedOrigins(const QStringList &origins)
{
    if (m_allowedOrigins == origins)
        return;
    
    m_allowedOrigins = origins;
    
    if (m_transport) {
        m_transport->setAllowedOrigins(origins);
    }
    
    // Reinstall bridge with new origins
    if (m_channel) {
        installWebChannelBridge();
    }
    
    emit allowedOriginsChanged();
}

void NativeWebView::setWebChannelScriptPath(const QString &path)
{
    if (m_webChannelScriptPath == path)
        return;
    
    m_webChannelScriptPath = path;
    
    // Reinstall bridge with new script path
    if (m_channel) {
        installWebChannelBridge();
    }
    
    emit webChannelScriptPathChanged();
}

void NativeWebView::setUserScripts(const QStringList &scripts)
{
    if (m_userScripts == scripts)
        return;
    
    m_userScripts = scripts;
    
    // Reinstall bridge with new user scripts
    if (m_channel) {
        installWebChannelBridge();
    }
    
    emit userScriptsChanged();
}

void NativeWebView::loadHtml(const QString &html, const QUrl &baseUrl)
{
    qDebug() << "NativeWebView::loadHtml, baseUrl:" << baseUrl;
    
    if (m_backend) {
        // Install bridge BEFORE loading content
        generateNewInvokeKey();
        installWebChannelBridge();
        
        m_backend->loadHtml(html, baseUrl);
    } else {
        qWarning() << "NativeWebView: No backend available";
    }
}

void NativeWebView::loadUrl(const QUrl &url)
{
    qDebug() << "NativeWebView::loadUrl:" << url;
    
    if (m_backend) {
        // Install bridge BEFORE loading content
        generateNewInvokeKey();
        installWebChannelBridge();
        
        m_backend->loadUrl(url);
    } else {
        qWarning() << "NativeWebView: No backend available";
    }
}

void NativeWebView::runJavaScript(const QString &script)
{
    if (m_backend) {
        m_backend->runJavaScript(script);
    }
}

void NativeWebView::postMessageToJavaScript(const QString &json)
{
    if (m_backend) {
        m_backend->postMessageToJavaScript(json);
    }
}

void NativeWebView::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    updateNativeViewGeometry();
}

void NativeWebView::itemChange(ItemChange change, const ItemChangeData &value)
{
    QQuickItem::itemChange(change, value);
    
    if (change == ItemSceneChange && value.window) {
        setupNativeView();
    }
}

void NativeWebView::onWebMessageReceived(const QString &message, 
                                         const QString &origin, 
                                         bool isMainFrame)
{
    qDebug() << "NativeWebView::onWebMessageReceived:" << message.left(100);
    
    // Route message to transport for QWebChannel
    if (m_transport) {
        m_transport->handleJsEnvelope(message, origin, isMainFrame);
    } else {
        qWarning() << "NativeWebView: No transport available!";
    }
}

void NativeWebView::onLoadStarted()
{
    // Bridge is now installed before loadHtml/loadUrl
    // This handler is kept for potential future use
}

void NativeWebView::onLoadingChanged(bool loading)
{
    if (m_loading == loading)
        return;
    
    m_loading = loading;
    emit loadingChanged();
}

void NativeWebView::onBackendUrlChanged(const QUrl &url)
{
    if (m_url == url)
        return;
    
    m_url = url;
    emit urlChanged();
}

void NativeWebView::setupNativeView()
{
    if (m_viewSetup)
        return;
    
    QQuickWindow *qmlWindow = window();
    if (!qmlWindow) {
        qWarning() << "NativeWebView: No window available";
        return;
    }
    
    if (m_backend) {
        m_backend->setupInItem(this);
        m_viewSetup = true;
        
        updateNativeViewGeometry();
        
        qDebug() << "NativeWebView: Native view set up";
        emit bridgeReady();
    }
}

void NativeWebView::updateNativeViewGeometry()
{
    if (!m_viewSetup || !m_backend)
        return;
    
    m_backend->updateGeometry(this);
}

void NativeWebView::installWebChannelBridge()
{
    if (!m_backend)
        return;
    
    // Generate invoke key if not set
    if (m_invokeKey.isEmpty()) {
        generateNewInvokeKey();
    }
    
    // Update transport with current key
    if (m_transport) {
        m_transport->setInvokeKey(m_invokeKey);
    }
    
    // Install bridge in backend
    m_backend->installMessageBridge(m_namespace, m_allowedOrigins, m_invokeKey, m_webChannelScriptPath, m_userScripts);
    
    qDebug() << "NativeWebView: WebChannel bridge installed";
}

void NativeWebView::generateNewInvokeKey()
{
    m_invokeKey = QUuid::createUuid().toString(QUuid::WithoutBraces);
    
    if (m_transport) {
        m_transport->setInvokeKey(m_invokeKey);
    }
}

