#pragma once

#include <QAbstractListModel>

class FigmaLinksModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count  READ rowCount NOTIFY countChanged)

public:
    static constexpr auto LinkRole = 0;

    explicit FigmaLinksModel(const QStringList &links,
                             QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setContent(const QStringList &links);

signals:
    void countChanged();

private:
    QStringList m_links;
};
