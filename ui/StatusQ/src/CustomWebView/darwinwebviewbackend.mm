// Uses WKWebView with WKUserContentController for WebChannel IPC

#if defined(__APPLE__)
#include <TargetConditionals.h>
#endif

#if defined(__APPLE__)

#include "nativewebviewbackend.h"

#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>
#include <QFile>
#include <QUrl>

#import <WebKit/WebKit.h>

#ifdef Q_OS_IOS
#import <UIKit/UIKit.h>
typedef UIView PlatformView;
#else
#import <AppKit/AppKit.h>
typedef NSView PlatformView;
#endif

// Forward declarations
@class QtBridgeHandler;

// ===== QtBridgeHandler =====
// WKScriptMessageHandler implementation for receiving messages from JavaScript

@interface QtBridgeHandler : NSObject <WKScriptMessageHandler>
@property (nonatomic, assign) NativeWebViewBackend *owner;
@end

@implementation QtBridgeHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    Q_UNUSED(userContentController);
    
    NSLog(@"QtBridgeHandler: Received message from JS, name=%@", message.name);
    
    if (!self.owner) {
        NSLog(@"QtBridgeHandler: No owner!");
        return;
    }
    
    // Extract message body
    NSString *body = [message.body isKindOfClass:[NSString class]] 
        ? (NSString *)message.body
        : [NSString stringWithFormat:@"%@", message.body];
    
    NSLog(@"QtBridgeHandler: Body=%@", [body substringToIndex:MIN(200, body.length)]);
    
    // Determine if this is the main frame
    BOOL isMainFrame = message.frameInfo && message.frameInfo.isMainFrame;
    
    NSLog(@"QtBridgeHandler: Emitting webMessageReceived signal");
    
    // Extract origin from security origin
    NSString *origin = @"";
    if (message.frameInfo && message.frameInfo.securityOrigin) {
        WKSecurityOrigin *so = message.frameInfo.securityOrigin;
        if (so.port > 0) {
            origin = [NSString stringWithFormat:@"%@://%@:%ld", so.protocol, so.host, (long)so.port];
        } else {
            origin = [NSString stringWithFormat:@"%@://%@", so.protocol, so.host];
        }
    }
    
    // Emit signal to Qt
    Q_EMIT self.owner->webMessageReceived(
        QString::fromNSString(body),
        QString::fromNSString(origin),
        isMainFrame
    );
}

@end

// ===== QtNavigationDelegate =====
// WKNavigationDelegate for tracking loading state

@interface QtNavigationDelegate : NSObject <WKNavigationDelegate>
@property (nonatomic, assign) NativeWebViewBackend *owner;
@end

@implementation QtNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
    
    if (self.owner) {
        Q_EMIT self.owner->loadStarted();
        Q_EMIT self.owner->loadingChanged(true);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    Q_UNUSED(navigation);
    
    if (self.owner) {
        Q_EMIT self.owner->loadingChanged(false);
        Q_EMIT self.owner->urlChanged(QUrl::fromNSURL(webView.URL));
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
    Q_UNUSED(error);
    
    if (self.owner) {
        Q_EMIT self.owner->loadingChanged(false);
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
    Q_UNUSED(error);
    
    if (self.owner) {
        Q_EMIT self.owner->loadingChanged(false);
    }
}

@end

// ===== DarwinWebViewBackend =====
// Platform-specific implementation using WKWebView

class DarwinWebViewBackend : public NativeWebViewBackend
{
    Q_OBJECT

public:
    explicit DarwinWebViewBackend(QObject *parent = nullptr)
        : NativeWebViewBackend(parent)
        , m_webView(nil)
        , m_bridgeHandler(nil)
        , m_navigationDelegate(nil)
    {
        // Create WKWebView configuration
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // Enable developer extras for debugging
        [config.preferences setValue:@YES forKey:@"developerExtrasEnabled"];
        
        // Create WebView
        CGRect frame = CGRectMake(0, 0, 400, 400);
        m_webView = [[WKWebView alloc] initWithFrame:frame configuration:config];
        
        // Set up navigation delegate
        m_navigationDelegate = [[QtNavigationDelegate alloc] init];
        m_navigationDelegate.owner = this;
        m_webView.navigationDelegate = m_navigationDelegate;
        
        qDebug() << "DarwinWebViewBackend: Created WKWebView";
    }
    
    ~DarwinWebViewBackend() override
    {
        if (m_webView) {
            [m_webView stopLoading];
            [m_webView removeFromSuperview];
            m_webView.navigationDelegate = nil;
            m_webView = nil;
        }
        m_bridgeHandler = nil;
        m_navigationDelegate = nil;
    }
    
    void loadUrl(const QUrl &url) override
    {
        if (!m_webView) return;
        
        NSURL *nsUrl = url.toNSURL();
        NSURLRequest *request = [NSURLRequest requestWithURL:nsUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_webView loadRequest:request];
        });
    }
    
    void loadHtml(const QString &html, const QUrl &baseUrl) override
    {
        if (!m_webView) return;
        
        NSString *nsHtml = html.toNSString();
        NSURL *nsBaseUrl = baseUrl.isValid() ? baseUrl.toNSURL() : nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_webView loadHTMLString:nsHtml baseURL:nsBaseUrl];
        });
    }
    
    void* nativeHandle() const override
    {
        return (__bridge void *)m_webView;
    }
    
    void runJavaScript(const QString &script) override
    {
        if (!m_webView) return;
        
        NSString *nsScript = script.toNSString();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_webView evaluateJavaScript:nsScript completionHandler:^(id result, NSError *error) {
                if (error) {
                    qWarning() << "DarwinWebViewBackend: JavaScript error:" 
                               << QString::fromNSString(error.localizedDescription);
                }
            }];
        });
    }
    
    bool installMessageBridge(const QString &ns,
                              const QStringList &allowedOrigins,
                              const QString &invokeKey,
                              const QString &webChannelScriptPath = QString(),
                              const QStringList &userScripts = QStringList()) override
    {
        Q_UNUSED(allowedOrigins); // Security enforced in transport layer
        
        if (!m_webView) return false;
        
        m_bridgeNs = ns;
        m_invokeKey = invokeKey;
        
        WKUserContentController *ucc = m_webView.configuration.userContentController;
        
        // Remove previous handlers and scripts (fresh state for new navigation)
        [ucc removeAllScriptMessageHandlers];
        [ucc removeAllUserScripts];
        
        // Create and register message handler
        m_bridgeHandler = [[QtBridgeHandler alloc] init];
        m_bridgeHandler.owner = this;
        [ucc addScriptMessageHandler:m_bridgeHandler name:@"qtbridge"];
        
        // Load and inject qwebchannel.js
        // Try user-provided path first, then fallback paths
        QStringList qwcPaths;
        if (!webChannelScriptPath.isEmpty()) {
            qwcPaths << webChannelScriptPath;
        }
        qwcPaths << QStringLiteral(":/qtwebchannel/qwebchannel.js");
        
        bool loaded = false;
        for (const QString &qwcPath : qwcPaths) {
            QFile qwcFile(qwcPath);
            if (qwcFile.open(QIODevice::ReadOnly)) {
                QString qwcSource = QString::fromUtf8(qwcFile.readAll());
                NSString *nsQwc = qwcSource.toNSString();
                WKUserScript *qwcScript = [[WKUserScript alloc] 
                    initWithSource:nsQwc
                    injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                    forMainFrameOnly:NO];
                [ucc addUserScript:qwcScript];
                qDebug() << "DarwinWebViewBackend: Injected qwebchannel.js from" << qwcPath;
                loaded = true;
                break;
            }
        }
        
        if (!loaded) {
            qWarning() << "DarwinWebViewBackend: Failed to load qwebchannel.js from any path:" << qwcPaths;
        }
        
        // Generate and inject bootstrap script
        QString bootstrap = generateBootstrapScript(ns, invokeKey);
        NSString *nsBootstrap = bootstrap.toNSString();
        WKUserScript *bootScript = [[WKUserScript alloc]
            initWithSource:nsBootstrap
            injectionTime:WKUserScriptInjectionTimeAtDocumentStart
            forMainFrameOnly:NO];
        [ucc addUserScript:bootScript];
        
        // Inject user scripts from resources (AtDocumentStart for EIP-1193 provider availability)
        for (const QString &scriptPath : userScripts) {
            QFile scriptFile(scriptPath);
            if (scriptFile.open(QIODevice::ReadOnly)) {
                QString scriptSource = QString::fromUtf8(scriptFile.readAll());
                NSString *nsScript = scriptSource.toNSString();
                WKUserScript *userScript = [[WKUserScript alloc]
                    initWithSource:nsScript
                    injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                    forMainFrameOnly:YES];
                [ucc addUserScript:userScript];
                qDebug() << "DarwinWebViewBackend: Injected user script from" << scriptPath;
            } else {
                qWarning() << "DarwinWebViewBackend: Failed to load user script:" << scriptPath;
            }
        }
        
        qDebug() << "DarwinWebViewBackend: Message bridge installed with namespace:" << ns;
        return true;
    }
    
    void postMessageToJavaScript(const QString &json) override
    {
        if (!m_webView) return;
        
        // Generate JavaScript code to deliver the message
        QString deliverScript = QString::fromLatin1(
            "(function(ns, msg) {"
            "  var t = window[ns] && window[ns].webChannelTransport;"
            "  if (t && typeof t.onmessage === 'function') {"
            "    t.onmessage({data: msg});"
            "  }"
            "})('%1', %2);")
            .arg(m_bridgeNs, json);
        
        NSString *nsScript = deliverScript.toNSString();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_webView evaluateJavaScript:nsScript completionHandler:nil];
        });
    }
    
    void setupInItem(QQuickItem *item) override
    {
        if (!m_webView || !item) return;
        
        QQuickWindow *window = item->window();
        if (!window) {
            qWarning() << "DarwinWebViewBackend: No window available";
            return;
        }
        
#ifdef Q_OS_IOS
        UIView *hostView = (__bridge UIView *)reinterpret_cast<void *>(window->winId());
#else
        NSView *hostView = (__bridge NSView *)reinterpret_cast<void *>(window->winId());
#endif
        
        if (!hostView) {
            qWarning() << "DarwinWebViewBackend: Could not get native view from window";
            return;
        }
        
        // Add WebView as subview
        [hostView addSubview:m_webView];
        
        qDebug() << "DarwinWebViewBackend: WebView added to window";
    }
    
    void updateGeometry(QQuickItem *item) override
    {
        if (!m_webView || !item) return;
        
        QQuickWindow *window = item->window();
        if (!window) return;
        
        // Convert QML coordinates to native coordinates
        QPointF pos = item->mapToScene(QPointF(0, 0));
        QRectF rect(pos.x(), pos.y(), item->width(), item->height());
        
#ifdef Q_OS_IOS
        // iOS uses top-left origin (same as Qt)
        CGRect frame = CGRectMake(rect.x(), rect.y(), rect.width(), rect.height());
#else
        // macOS uses bottom-left origin
        qreal windowHeight = window->height();
        CGFloat y = windowHeight - rect.y() - rect.height();
        CGRect frame = CGRectMake(rect.x(), y, rect.width(), rect.height());
#endif
        
        [m_webView setFrame:frame];
    }
    
private:
    QString generateBootstrapScript(const QString &ns, const QString &invokeKey)
    {
        // This script sets up the WebChannel transport on the JS side
        return QString::fromLatin1(
            "(function(ns, key) {"
            "  window[ns] = window[ns] || {};"
            "  window[ns].__qtbridge_postMessage = function(pkt) {"
            "    webkit.messageHandlers.qtbridge.postMessage(pkt);"
            "  };"
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
            .arg(ns, invokeKey);
    }
    
    WKWebView *m_webView;
    QtBridgeHandler *m_bridgeHandler;
    QtNavigationDelegate *m_navigationDelegate;
    QString m_bridgeNs;
    QString m_invokeKey;
};

// Factory function implementation for Darwin
NativeWebViewBackend* createPlatformBackend(QObject *parent)
{
    return new DarwinWebViewBackend(parent);
}

#include "darwinwebviewbackend.moc"

#endif // __APPLE__

