#pragma once

#include <QObject>
#include <QMimeDatabase>

class UrlUtils : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString validImageNameFilters READ validImageNameFilters FINAL CONSTANT) // "*.jpg *.jpe *.jp *.jpeg *.png *.webp *.gif *.svg"
    Q_PROPERTY(QStringList validPreferredImageExtensions READ validPreferredImageExtensions FINAL CONSTANT) // ["jpg", "png", "webp", "gif", "svg"]
    Q_PROPERTY(QStringList allValidImageExtensions READ allValidImageExtensions FINAL CONSTANT) // ["jpg", "jpe", "jp", "jpeg", "png", "webp", "gif", "svg"]

public:
    explicit UrlUtils(QObject* parent = nullptr);

    Q_INVOKABLE bool isValidImageUrl(const QUrl &url) const;
    Q_INVOKABLE static qint64 getFileSize(const QUrl &url);

    Q_INVOKABLE QString convertUrlToLocalPath(const QString& url) const;
    Q_INVOKABLE QStringList convertUrlsToLocalPaths(const QStringList& urls) const;

private:
    QMimeDatabase m_mimeDb;

    QStringList m_validImageMimeTypes{QStringLiteral("image/jpeg"),
                                      QStringLiteral("image/png"),
                                      QStringLiteral("image/gif"),
                                      QStringLiteral("image/svg")};

    // "*.jpg *.jpe *.jp *.jpeg *.png *.webp *.gif *.svg"
    QString m_imgFilters;
    QString validImageNameFilters() const { return m_imgFilters; }

    // ["jpg", "png", "webp", "gif", "svg"]
    QStringList m_imgExtensions;
    QStringList validPreferredImageExtensions() const { return m_imgExtensions; }

    // ["jpg", "jpe", "jp", "jpeg", "png", "webp", "gif", "svg"]
    QStringList m_allImgExtensions;
    QStringList allValidImageExtensions() const { return m_allImgExtensions; }
};
