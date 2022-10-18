#pragma once

#include <QObject>

class QFileSystemWatcher;

class DirectoriesWatcher : public QObject
{
    Q_OBJECT
public:
    explicit DirectoriesWatcher(QObject *parent = nullptr);
    void addPaths(const QStringList &paths);

signals:
    void changed();

private:
    QFileSystemWatcher* fsWatcher;
};
