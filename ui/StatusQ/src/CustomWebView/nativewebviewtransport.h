#ifndef NATIVEWEBVIEWTRANSPORT_H
#define NATIVEWEBVIEWTRANSPORT_H

#include <QWebChannelAbstractTransport>
#include <QJsonObject>
#include <QString>
#include <QStringList>

class NativeWebView;

/**
 * @brief QWebChannel transport implementation for NativeWebView.
 * 
 * This transport bridges QWebChannel with the native WebView's IPC mechanism.
 * Messages from QWebChannel are sent to JavaScript via postMessageToJavaScript(),
 * and messages from JavaScript are received via handleJsEnvelope().
 */
class NativeWebViewTransport : public QWebChannelAbstractTransport
{
    Q_OBJECT

public:
    explicit NativeWebViewTransport(NativeWebView *view, const QString &ns, QObject *parent = nullptr);
    ~NativeWebViewTransport() override = default;

    /**
     * @brief Send a message from QWebChannel to JavaScript.
     * 
     * Implements QWebChannelAbstractTransport::sendMessage().
     */
    void sendMessage(const QJsonObject &message) override;

    /**
     * @brief Set allowed origins for security filtering.
     */
    void setAllowedOrigins(const QStringList &origins);

    /**
     * @brief Set the invoke key for the current navigation session.
     * 
     * The invoke key is regenerated on each navigation to prevent
     * stale messages from previous pages.
     */
    void setInvokeKey(const QString &key);

    /**
     * @brief Handle an envelope received from JavaScript.
     * 
     * The envelope format is:
     * { "origin": "<location.origin>", "invokeKey": "<key>", "data": "<qwebchannel JSON>" }
     * 
     * @param envelopeJson The JSON envelope from JavaScript
     * @param reportedOrigin The origin reported by the native layer
     * @param isMainFrame Whether the message came from the main frame
     */
    void handleJsEnvelope(const QString &envelopeJson,
                         const QString &reportedOrigin,
                         bool isMainFrame);

private:
    NativeWebView *m_view;
    QString m_ns;
    QString m_invokeKey;
    QStringList m_allowedOrigins;
};

#endif // NATIVEWEBVIEWTRANSPORT_H

