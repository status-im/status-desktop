#pragma once

#include <QObject>
#include <QImage>

class QClipboard;
class QJSEngine;
class QQmlEngine;

class ClipboardUtils : public QObject
{
    Q_OBJECT

    Q_DISABLE_COPY(ClipboardUtils)

    Q_PROPERTY(bool hasText READ hasText NOTIFY contentChanged)
    Q_PROPERTY(QString text READ text NOTIFY contentChanged)

    Q_PROPERTY(bool hasHtml READ hasHtml NOTIFY contentChanged)
    Q_PROPERTY(QString html READ html NOTIFY contentChanged)

    Q_PROPERTY(bool hasImage READ hasImage NOTIFY contentChanged)
    Q_PROPERTY(QImage image READ image NOTIFY contentChanged)
    Q_PROPERTY(QString imageBase64 READ imageBase64 NOTIFY contentChanged)

    Q_PROPERTY(bool hasUrls READ hasUrls NOTIFY contentChanged)
    Q_PROPERTY(QList<QUrl> urls READ urls NOTIFY contentChanged)

    ClipboardUtils();

    bool hasText() const;
    QString text() const;

    bool hasHtml() const;
    QString html() const;

    bool hasImage() const;
    QImage image() const;
    QString imageBase64() const;

    bool hasUrls() const;
    QList<QUrl> urls() const;

    QClipboard* m_clipboard{nullptr};

public:
    static QObject* qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine)
    {
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);

        return new ClipboardUtils;
    }

    Q_INVOKABLE bool isValidImageUrl(const QUrl &url, const QStringList &acceptedExtensions) const;
    Q_INVOKABLE qint64 getFileSize(const QUrl &url) const;
    Q_INVOKABLE void copyTextToClipboard(const QString& text);
    Q_INVOKABLE void clear();

signals:
    void contentChanged();
};
