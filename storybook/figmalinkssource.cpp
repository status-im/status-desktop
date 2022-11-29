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

void FigmaLinksSource::remove(const QString &key, const QList<int> &indexes)
{
    if (m_filePath.isEmpty()) {
        qWarning("FigmaLinksSource::remove - file path is not set!");
        return;
    }

    QMap<QString, QStringList> linksMap;

    if (m_figmaLinks)
        linksMap = m_figmaLinks->getLinksMap();

    auto it = linksMap.find(key);

    if (it == linksMap.end()) {
        qWarning("FigmaLinksSource::remove - provided key doesn't exist!");
        return;
    }

    if (indexes.isEmpty())
        return;

    auto indexesSorted = indexes;
    std::sort(indexesSorted.begin(), indexesSorted.end());

    if (std::adjacent_find(indexesSorted.cbegin(), indexesSorted.cend())
            != indexesSorted.cend()) {
        qWarning("FigmaLinksSource::remove - provided indexes list contains duplicates!");
        return;
    }

    auto& linksList = it.value();

    if (indexesSorted.first() < 0 || indexesSorted.last() >= linksList.size()) {
        qWarning("FigmaLinksSource::remove - at least one provided index is out of range!");
        return;
    }

    if (linksList.size() == indexesSorted.size()) {
        linksMap.erase(it);
    } else {
        std::for_each(std::crbegin(indexesSorted), std::crend(indexesSorted),
                      [&linksList](int idx) {
            linksList.removeAt(idx);
        });
    }

    FigmaIO::write(m_filePath.path(), linksMap);
}

void FigmaLinksSource::append(const QString &key, const QList<QString> &links)
{
    QMap<QString, QStringList> linksMap;


    if (m_filePath.isEmpty()) {
        qWarning("FigmaLinksSource::append - file path is not set!");
        return;
    }

    if (m_figmaLinks)
        linksMap = m_figmaLinks->getLinksMap();

    linksMap[key].append(links);

    FigmaIO::write(m_filePath.path(), linksMap);
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
