#pragma once

#include <QAbstractListModel>

struct PagesModelItem {
    QString title;
    QString category;
};

class PagesModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit PagesModel(const QString &path, QObject *parent = nullptr);

    enum Roles {
        TitleRole = Qt::UserRole + 1,
        CategoryRole
    };

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    QList<PagesModelItem> m_items;
};
