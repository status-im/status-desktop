#include "figmalinkssource.h"

#include <QQmlEngine>

#include "figmaio.h"
#include "figmalinks.h"

FigmaLinksSource::FigmaLinksSource(QObject *parent)
    : QObject{parent}
{
    connect(&m_watcher, &QFileSystemWatcher::fileChanged,
            this, [this](const QString &path) {
        this->readFile();

        if (!this->m_watcher.files().contains(path))
            this->m_watcher.addPath(path);
    });
}

const QUrl& FigmaLinksSource::getFilePath() const
{
    return m_filePath;
}

void FigmaLinksSource::setFilePath(const QUrl& path)
{
    if (path == m_filePath)
        return;

    m_filePath = path;
    readFile();
    setupWatcher();
    emit filePathChanged();
}

FigmaLinks* FigmaLinksSource::getFigmaLinks() const
{
    return m_figmaLinks;
}

void FigmaLinksSource::updateFigmaLinks(const QMap<QString, QStringList>& map)
{
    FigmaLinks *mapping = new FigmaLinks(map, this);

    if (m_figmaLinks && qjsEngine(m_figmaLinks)) {
        m_figmaLinks->setParent(nullptr);
        QQmlEngine::setObjectOwnership(m_figmaLinks, QQmlEngine::JavaScriptOwnership);
    }

    m_figmaLinks = mapping;
    emit figmaLinksChanged();
}

void FigmaLinksSource::readFile()
{
    QMap<QString, QStringList> figmaLinks = FigmaIO::read(m_filePath.path());
    updateFigmaLinks(figmaLinks);
}

void FigmaLinksSource::setupWatcher()
{
    auto currentlyWatched = m_watcher.files();

    if (!currentlyWatched.isEmpty())
        m_watcher.removePaths(currentlyWatched);

    if (m_filePath.isEmpty())
        return;

    m_watcher.addPath(m_filePath.path());
}
