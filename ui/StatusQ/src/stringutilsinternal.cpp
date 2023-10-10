#include "StatusQ/stringutilsinternal.h"

#include <QFile>
#include <QFileSelector>
#include <QQmlEngine>
#include <QQmlFileSelector>
#include <QUrl>

StringUtilsInternal::StringUtilsInternal(QQmlEngine* engine, QObject* parent)
    : m_engine(engine)
    , QObject(parent)
{ }

QString StringUtilsInternal::escapeHtml(const QString& unsafe) const
{
    return unsafe.toHtmlEscaped();
}

QString StringUtilsInternal::readTextFile(const QString& filePath) const
{
    auto selector = QQmlFileSelector::get(m_engine);
    if (!selector) {
        qWarning() << Q_FUNC_INFO << "No QQmlFileSelector available to load text file:" << filePath;
        return {};
    }

    const auto resolvedFilePath = selector->selector()->select(filePath);

    QFile file(resolvedFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << Q_FUNC_INFO << "Error opening" << resolvedFilePath << "for reading";
        return {};
    }

    return file.readAll();
}

QString StringUtilsInternal::extractDomainFromLink(const QString& link) const
{
    const auto url = QUrl::fromUserInput(link);
    if (!url.isValid()) {
        qWarning() << Q_FUNC_INFO << "Invalid URL:" << link;
        return {};
    }
    return url.host();
}
