#pragma once

#include <QObject>
#include <QAbstractListModel>

class ContextPropertiesModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ContextPropertiesModel(QObject* parent = nullptr);

    static constexpr int NameRole = Qt::UserRole + 1;

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addContextProperty(const QString &property);

private:
    QStringList m_contextProperties;
};
