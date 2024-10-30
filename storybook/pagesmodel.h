#pragma once

#include <QAbstractListModel>
#include <QDateTime>

#include "figmalinksmodel.h"

class DirectoryFilesWatcher;

struct PagesModelItem {
    QString path;
    QDateTime lastModified;
    QString title;
    QString category;
    int status = 0;
    QStringList figmaLinks;
};

class PagesModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit PagesModel(const QString &path, QObject *parent = nullptr);

    enum Roles {
        TitleRole = Qt::UserRole + 1,
        CategoryRole,
        StatusRole,
        FigmaRole
    };

    enum Status : int {
        Uncategorized = 0,
        Bad,
        Decent,
        Good
    };

    Q_ENUM(Status)

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    void onPagesChanged(const QStringList& added, const QStringList& removed,
                        const QStringList& changed);

    int getIndexByPath(const QString& path) const;

    static PagesModelItem readMetadata(const QString& path);
    static QList<PagesModelItem> readMetadata(const QStringList& paths);

    static void readMetadata(PagesModelItem &item);
    static void readMetadata(QList<PagesModelItem> &items);

    static QString extractCategory(const QByteArray& content);
    static PagesModel::Status extractStatus(const QByteArray& content);
    static QStringList extractFigmaLinks(const QByteArray& content);

    void setFigmaLinks(const QString& title, const QStringList& links);

    QString m_path;
    QList<PagesModelItem> m_items;
    QMap<QString, FigmaLinksModel*> m_figmaSubmodels;
    DirectoryFilesWatcher* m_pagesWatcher;
};
