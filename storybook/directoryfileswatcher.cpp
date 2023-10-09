#include "directoryfileswatcher.h"

#include <QDir>
#include <QFileSystemWatcher>

DirectoryFilesWatcher::DirectoryFilesWatcher(
        const QString &path, const QString &pattern, QObject *parent)
    : QObject{parent}, m_path{path}, m_pattern{pattern},
      m_fsWatcher{new QFileSystemWatcher(this)}
{
    auto files = readDirectory();
    m_files.reserve(files.size());
    m_files.insert(std::move_iterator(files.begin()),
                   std::move_iterator(files.end()));

    m_fsWatcher->addPath(path);

    connect(m_fsWatcher, &QFileSystemWatcher::directoryChanged,
            this, &DirectoryFilesWatcher::onDirectoryChanged);
}

QStringList DirectoryFilesWatcher::files() const
{
    QStringList list;
    list.reserve(m_files.size());

    for (auto& [file, _] : m_files)
        list << file;

    return list;
}

std::vector<std::pair<QString, QDateTime>> DirectoryFilesWatcher::readDirectory() const
{
    QDir dir(m_path);
    dir.setFilter(QDir::Files);
    dir.setNameFilters({m_pattern});

    const QFileInfoList filesInfo = dir.entryInfoList();
    std::vector<std::pair<QString, QDateTime>> files;
    files.reserve(filesInfo.size());

    std::transform(filesInfo.begin(), filesInfo.end(),
                   std::back_inserter(files),
                   [] (auto &info) {
        return std::make_pair(info.filePath(), info.lastModified());
    });

    return files;
}

void DirectoryFilesWatcher::onDirectoryChanged() {
    auto files = readDirectory();

    QStringList added;
    QStringList removed;
    QStringList changed;

    for (auto& [file, date] : files) {
        auto it = m_files.find(file);

        if (it == m_files.end()) {
            added.push_back(file);
        } else {
            if (date != it->second)
                changed.push_back(file);

            m_files.erase(it);
        }
    }

    for (auto& [file, date] : m_files)
        removed.push_back(file);

    m_files.clear();
    m_files.reserve(files.size());
    m_files.insert(std::move_iterator(files.begin()),
                   std::move_iterator(files.end()));

    emit filesChanged(added, removed, changed);
}
