#pragma once

#include <QObject>

class QClipboard;
class QJSEngine;
class QQmlEngine;

class QClipboardProxy : public QObject
{
    Q_OBJECT

    Q_DISABLE_COPY(QClipboardProxy)

    Q_PROPERTY(bool hasText READ hasText NOTIFY contentChanged)
    Q_PROPERTY(QString text READ text NOTIFY contentChanged)

    Q_PROPERTY(bool hasHtml READ hasHtml NOTIFY contentChanged)
    Q_PROPERTY(QString html READ html NOTIFY contentChanged)

    Q_PROPERTY(bool hasImage READ hasImage NOTIFY contentChanged)
    Q_PROPERTY(QImage image READ image NOTIFY contentChanged)
    Q_PROPERTY(QByteArray imageBase64 READ imageBase64 NOTIFY contentChanged)

    Q_PROPERTY(bool hasUrls READ hasUrls NOTIFY contentChanged)
    Q_PROPERTY(QList<QUrl> urls READ urls NOTIFY contentChanged)

    QClipboardProxy();

    bool hasText() const;
    QString text() const;

    bool hasHtml() const;
    QString html() const;

    bool hasImage() const;
    QImage image() const;
    QByteArray imageBase64() const;

    bool hasUrls() const;
    QList<QUrl> urls() const;

    QClipboard* m_clipboard{nullptr};

public:
    static QObject* qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine)
    {
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);

        return new QClipboardProxy;
    }

signals:
    void contentChanged();
};
