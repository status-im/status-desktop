#include "directorieswatcher.h"

#include <QFileSystemWatcher>
#include <QDirIterator>

DirectoriesWatcher::DirectoriesWatcher(QObject *parent)
    : QObject{parent}, fsWatcher(new QFileSystemWatcher(this))
{
    connect(fsWatcher, &QFileSystemWatcher::directoryChanged,
            this, &DirectoriesWatcher::changed);
}

void DirectoriesWatcher::addPaths(const QStringList &paths)
{
    for (auto& path : paths) {
        QDirIterator it(path, QDir::AllDirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);

        while (it.hasNext()) {
            const auto& subpath = it.filePath();

            if (!subpath.isEmpty())
                fsWatcher->addPath(subpath);

            it.next();
        }

        fsWatcher->addPath(path);
    }
}
