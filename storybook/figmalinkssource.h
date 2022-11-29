#pragma once

#include <QObject>
#include <QFileSystemWatcher>
#include <QUrl>

class FigmaLinks;

class FigmaLinksSource : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl filePath READ getFilePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(FigmaLinks* figmaLinks READ getFigmaLinks NOTIFY figmaLinksChanged)

public:
    explicit FigmaLinksSource(QObject *parent = nullptr);

    const QUrl& getFilePath() const;
    void setFilePath(const QUrl& path);
    FigmaLinks* getFigmaLinks() const;

    Q_INVOKABLE void remove(const QString &key, const QList<int> &indexes);
    Q_INVOKABLE void append(const QString &key, const QList<QString> &links);

signals:
    void filePathChanged();
    void figmaLinksChanged();

private:
    void updateFigmaLinks(const QMap<QString, QStringList>& map);
    void readFile();
    void setupWatcher();

    FigmaLinks *m_figmaLinks = nullptr;
    QUrl m_filePath;
    QFileSystemWatcher m_watcher;
};
