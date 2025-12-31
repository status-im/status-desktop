#include "nativewebviewtransport.h"
#include "nativewebview.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

NativeWebViewTransport::NativeWebViewTransport(NativeWebView *view, const QString &ns, QObject *parent)
    : QWebChannelAbstractTransport(parent)
    , m_view(view)
    , m_ns(ns)
{
}

void NativeWebViewTransport::sendMessage(const QJsonObject &message)
{
    if (!m_view) {
        qWarning() << "NativeWebViewTransport: No view available";
        return;
    }

    const QString json = QString::fromUtf8(QJsonDocument(message).toJson(QJsonDocument::Compact));
    qDebug() << "NativeWebViewTransport: Sending to JS:" << json.left(200);
    m_view->postMessageToJavaScript(json);
}

void NativeWebViewTransport::setAllowedOrigins(const QStringList &origins)
{
    m_allowedOrigins = origins;
}

void NativeWebViewTransport::setInvokeKey(const QString &key)
{
    m_invokeKey = key;
}

void NativeWebViewTransport::handleJsEnvelope(const QString &envelopeJson,
                                              const QString &reportedOrigin,
                                              bool /*isMainFrame*/)
{
    qDebug() << "NativeWebViewTransport: Received envelope:" << envelopeJson.left(200);
    
    // Envelope format (stringified JSON object):
    // { "origin": "<location.origin>", "invokeKey": "<key>", "data": "<qwebchannel JSON string>" }
    
    const QJsonDocument doc = QJsonDocument::fromJson(envelopeJson.toUtf8());
    if (doc.isNull() || !doc.isObject()) {
        qWarning() << "NativeWebViewTransport: Invalid envelope JSON";
        return;
    }

    const QJsonObject obj = doc.object();
    const QString origin = obj.value(QLatin1String("origin")).toString(reportedOrigin);
    const QString key = obj.value(QLatin1String("invokeKey")).toString();
    const QString data = obj.value(QLatin1String("data")).toString();

    qDebug() << "NativeWebViewTransport: origin=" << origin << "key=" << key << "data=" << data.left(100);

    // Validate invoke key (prevents stale messages from previous navigations)
    if (!m_invokeKey.isEmpty() && key != m_invokeKey) {
        qDebug() << "NativeWebViewTransport: Ignoring message with stale invoke key, expected:" << m_invokeKey;
        return;
    }

    // Validate origin (security check)
    if (!m_allowedOrigins.isEmpty() && !m_allowedOrigins.contains(origin)) {
        qDebug() << "NativeWebViewTransport: Ignoring message from disallowed origin:" << origin;
        return;
    }

    // Parse the actual QWebChannel message
    const QJsonDocument payload = QJsonDocument::fromJson(data.toUtf8());
    if (!payload.isNull() && payload.isObject()) {
        qDebug() << "NativeWebViewTransport: Emitting messageReceived";
        emit messageReceived(payload.object(), this);
    } else {
        qWarning() << "NativeWebViewTransport: Failed to parse payload";
    }
}

