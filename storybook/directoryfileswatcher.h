#pragma once

#include <QDateTime>
#include <QObject>
#include <QStringList>

#include <unordered_map>

class QFileSystemWatcher;

class DirectoryFilesWatcher : public QObject
{
    Q_OBJECT
public:
    explicit DirectoryFilesWatcher(const QString &path, const QString &pattern,
                                   QObject *parent = nullptr);

    QStringList files() const;

signals:
    void filesChanged(const QStringList& added, const QStringList& removed,
                      const QStringList& changed);

private:
    std::vector<std::pair<QString, QDateTime>> readDirectory() const;
    void onDirectoryChanged();

    QString m_path;
    QString m_pattern;
    std::unordered_map<QString, QDateTime> m_files;
    QFileSystemWatcher* m_fsWatcher;
};
