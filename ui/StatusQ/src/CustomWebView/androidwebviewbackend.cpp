// Uses Android WebView with JavaScriptInterface for WebChannel IPC
#if defined(__ANDROID__)

#include "nativewebviewbackend.h"

#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>
#include <QFile>
#include <QUrl>
#include <QThread>
#include <QAbstractEventDispatcher>
#include <QGuiApplication>

#include <QtCore/qjniobject.h>
#include <QtCore/private/qjnihelpers_p.h>
#include <QJniEnvironment>

QT_BEGIN_NAMESPACE

// Forward declarations for JNI types
Q_DECLARE_JNI_CLASS(WebView, "android/webkit/WebView")
Q_DECLARE_JNI_CLASS(WebViewController, "org/qtproject/qt/android/webview/QtAndroidWebViewController")
Q_DECLARE_JNI_CLASS(QtBridge, "org/qtproject/qt/android/webview/QtBridge")

using namespace QtJniTypes;

// Global registry for tracking instances (for JNI callbacks)
typedef QSet<NativeWebViewBackend *> WebViewBackends;
Q_GLOBAL_STATIC(WebViewBackends, g_webViewBackends)

class AndroidWebViewBackend : public NativeWebViewBackend
{
    Q_OBJECT

public:
    explicit AndroidWebViewBackend(QObject *parent = nullptr)
        : NativeWebViewBackend(parent)
        , m_viewController(nullptr)
        , m_webView(nullptr)
    {
        // QtAndroidWebViewController constructor blocks the Qt GUI thread until
        // the WebView is created and configured in the UI thread.
        while (!QtAndroidPrivate::acquireAndroidDeadlockProtector()) {
            auto eventDispatcher = QThread::currentThread()->eventDispatcher();
            if (eventDispatcher) {
                eventDispatcher->processEvents(
                    QEventLoop::ExcludeUserInputEvents | QEventLoop::ExcludeSocketNotifiers);
            }
        }
        
        m_viewController = WebViewController(
            QtAndroidPrivate::activity(), 
            reinterpret_cast<jlong>(this)
        );
        
        QtAndroidPrivate::releaseAndroidDeadlockProtector();
        
        m_webView = m_viewController.callMethod<WebView>("getWebView");
        
        g_webViewBackends->insert(this);
        
        connect(qApp, &QGuiApplication::applicationStateChanged,
                this, &AndroidWebViewBackend::onApplicationStateChanged);
        
        qDebug() << "AndroidWebViewBackend: Created";
    }
    
    ~AndroidWebViewBackend() override
    {
        g_webViewBackends->remove(this);
        m_viewController.callMethod<void>("destroy");
    }
    
    void loadUrl(const QUrl &url) override
    {
        m_viewController.callMethod<void>("loadUrl", url.toString());
    }
    
    void loadHtml(const QString &html, const QUrl &baseUrl) override
    {
        const QString mimeType = QStringLiteral("text/html;charset=UTF-8");
        
        if (baseUrl.isEmpty() || baseUrl.scheme() == QLatin1String("data")) {
            const QString encoded = QUrl::toPercentEncoding(html);
            m_viewController.callMethod<void>("loadData", encoded, mimeType, jstring(nullptr));
        } else {
            m_viewController.callMethod<void>("loadDataWithBaseURL", 
                baseUrl.toString(), html, mimeType, 
                jstring(nullptr), jstring(nullptr));
        }
    }
    
    void* nativeHandle() const override
    {
        return m_webView.object<jobject>();
    }
    
    void runJavaScript(const QString &script) override
    {
        m_viewController.callMethod<void>("runJavaScript", script, jlong(-1));
    }
    
    bool installMessageBridge(const QString &ns,
                              const QStringList &allowedOrigins,
                              const QString &invokeKey,
                              const QString &webChannelScriptPath = QString(),
                              const QStringList &userScripts = QStringList()) override
    {
        m_bridgeNs = ns;
        m_allowedOrigins = allowedOrigins;
        m_invokeKey = invokeKey;
        
        // Load qwebchannel.js - try user-provided path first, then fallback
        QString qwebchannelJs;
        QStringList paths;
        if (!webChannelScriptPath.isEmpty()) {
            paths << webChannelScriptPath;
        }
        paths << QStringLiteral(":/qtwebchannel/qwebchannel.js");
        
        for (const QString &path : paths) {
            QFile file(path);
            if (file.open(QIODevice::ReadOnly)) {
                qwebchannelJs = QString::fromUtf8(file.readAll());
                qDebug() << "AndroidWebViewBackend: Loaded qwebchannel.js from" << path;
                break;
            }
        }
        if (qwebchannelJs.isEmpty()) {
            qWarning() << "AndroidWebViewBackend: Failed to load qwebchannel.js from paths:" << paths;
        }
        
        // Load user scripts from resources
        QString userScriptsContent;
        for (const QString &scriptPath : userScripts) {
            QFile scriptFile(scriptPath);
            if (scriptFile.open(QIODevice::ReadOnly)) {
                userScriptsContent += QString::fromUtf8(scriptFile.readAll()) + QStringLiteral("\n");
                qDebug() << "AndroidWebViewBackend: Loaded user script from" << scriptPath;
            } else {
                qWarning() << "AndroidWebViewBackend: Failed to load user script:" << scriptPath;
            }
        }
        
        // Generate bootstrap script
        // Post hook for Android - uses qtbridge.postMessage (WebMessageListener) or QtBridge.postMessage (fallback)
        QString postHook = QString::fromLatin1(
            "function(pkt){"
            "  if(window.qtbridge && window.qtbridge.postMessage) {"
            "    window.qtbridge.postMessage(pkt);"
            "  } else if(window.QtBridge && window.QtBridge.postMessage) {"
            "    window.QtBridge.postMessage(pkt);"
            "  }"
            "}");
        
        QString bootstrapJs = generateBootstrapScript(ns, invokeKey, postHook);
        
        // Install via QtBridge Java helper
        QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=, this]() {
            if (!m_javaBridge.isValid()) {
                m_javaBridge = QJniObject("org/qtproject/qt/android/webview/QtBridge",
                                         "(JLjava/lang/Object;)V",
                                         jlong(this), 
                                         m_webView.object<jobject>());
            }
            
            m_javaBridge.callMethod<void>("installBridge",
                QJniObject::fromString(qwebchannelJs).object<jstring>(),
                QJniObject::fromString(bootstrapJs).object<jstring>(),
                QJniObject::fromString(m_bridgeNs).object<jstring>(),
                QJniObject::fromString(m_allowedOrigins.join(u',')).object<jstring>(),
                QJniObject::fromString(userScriptsContent).object<jstring>());
        });
        
        qDebug() << "AndroidWebViewBackend: Message bridge installed with namespace:" << ns;
        return true;
    }
    
    void postMessageToJavaScript(const QString &json) override
    {
        // Deliver to transport.onmessage
        QString deliverScript = QString::fromLatin1(
            "(function(ns, msg) {"
            "  var t = window[ns] && window[ns].webChannelTransport;"
            "  if (t && typeof t.onmessage === 'function') {"
            "    t.onmessage({data: msg});"
            "  }"
            "})('%1', %2);")
            .arg(m_bridgeNs, json);
        
        m_viewController.callMethod<void>("runJavaScript",
            QJniObject::fromString(deliverScript).object<jstring>(), 
            jlong(-1));
    }
    
    void setupInItem(QQuickItem *item) override
    {
        if (!item) return;
        
        QQuickWindow *window = item->window();
        if (!window) {
            qWarning() << "AndroidWebViewBackend: No window available";
            return;
        }
        
        // On Android, the WebView is managed by the system
        // We just need to make sure our window is set as parent
        // The actual parenting is handled by Qt's Android platform plugin
        
        qDebug() << "AndroidWebViewBackend: WebView setup in item";
    }
    
    void updateGeometry(QQuickItem *item) override
    {
        if (!item) return;
        
        // On Android, geometry is handled through Qt's platform integration
        // The WebViewController manages the native view positioning
        
        QPointF pos = item->mapToScene(QPointF(0, 0));
        QRectF rect(pos.x(), pos.y(), item->width(), item->height());
        
        // Call into Java to update geometry if needed
        // This is typically handled automatically by Qt's Android embedding
    }
    
    // Called from JNI when a message is received from JavaScript
    void onMessageFromJavaScript(const QString &envelope, 
                                  const QString &origin, 
                                  bool isMainFrame)
    {
        emit webMessageReceived(envelope, origin, isMainFrame);
    }
    
    // Called from JNI on page events
    void onPageStarted(const QUrl &url)
    {
        emit loadStarted();
        emit loadingChanged(true);
        emit urlChanged(url);
    }
    
    void onPageFinished(const QUrl &url)
    {
        emit loadingChanged(false);
        emit urlChanged(url);
    }

private slots:
    void onApplicationStateChanged(Qt::ApplicationState state)
    {
        if (state == Qt::ApplicationActive) {
            m_viewController.callMethod<void>("onResume");
        } else {
            m_viewController.callMethod<void>("onPause");
        }
    }

private:
    QString generateBootstrapScript(const QString &ns, 
                                    const QString &invokeKey,
                                    const QString &postHook)
    {
        return QString::fromLatin1(
            "(function(ns, key) {"
            "  window[ns] = window[ns] || {};"
            "  window[ns].__qtbridge_postMessage = %3;"
            "  var t = window[ns].webChannelTransport = {"
            "    send: function(msg) {"
            "      var pkt = JSON.stringify({"
            "        origin: (location.origin || 'null'),"
            "        invokeKey: key,"
            "        data: String(msg)"
            "      });"
            "      window[ns].__qtbridge_postMessage(pkt);"
            "    },"
            "    onmessage: null"
            "  };"
            "})('%1', '%2');")
            .arg(ns, invokeKey, postHook);
    }
    
    WebViewController m_viewController;
    WebView m_webView;
    QJniObject m_javaBridge;
    QString m_bridgeNs;
    QStringList m_allowedOrigins;
    QString m_invokeKey;
};

// ===== JNI Callbacks =====

static void c_onBridgeMessage(JNIEnv *env,
                              jclass thiz,
                              jlong nativePtr,
                              jstring envelope,
                              jstring origin,
                              jboolean isMainFrame)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);
    
    AndroidWebViewBackend *backend = reinterpret_cast<AndroidWebViewBackend *>(nativePtr);
    if (!g_webViewBackends->contains(backend))
        return;
    
    QString qEnvelope = QJniObject(envelope).toString();
    QString qOrigin = QJniObject(origin).toString();
    
    // Post to Qt event loop
    QMetaObject::invokeMethod(backend, [=]() {
        backend->onMessageFromJavaScript(qEnvelope, qOrigin, isMainFrame);
    }, Qt::QueuedConnection);
}

static void c_onPageStarted(JNIEnv *env,
                            jclass thiz,
                            jlong nativePtr,
                            jstring url)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);
    
    AndroidWebViewBackend *backend = reinterpret_cast<AndroidWebViewBackend *>(nativePtr);
    if (!g_webViewBackends->contains(backend))
        return;
    
    QUrl qUrl(QJniObject(url).toString());
    
    QMetaObject::invokeMethod(backend, [=]() {
        backend->onPageStarted(qUrl);
    }, Qt::QueuedConnection);
}

static void c_onPageFinished(JNIEnv *env,
                             jclass thiz,
                             jlong nativePtr,
                             jstring url)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);
    
    AndroidWebViewBackend *backend = reinterpret_cast<AndroidWebViewBackend *>(nativePtr);
    if (!g_webViewBackends->contains(backend))
        return;
    
    QUrl qUrl(QJniObject(url).toString());
    
    QMetaObject::invokeMethod(backend, [=]() {
        backend->onPageFinished(qUrl);
    }, Qt::QueuedConnection);
}

// Factory function implementation for Android
NativeWebViewBackend* createPlatformBackend(QObject *parent)
{
    return new AndroidWebViewBackend(parent);
}

#include "androidwebviewbackend.moc"

QT_END_NAMESPACE

#endif // __ANDROID__

