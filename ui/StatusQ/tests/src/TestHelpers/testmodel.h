#pragma once

#include <QAbstractListModel>

class TestModel : public QAbstractListModel {

public:
    explicit TestModel(QList<QPair<QString, QVariantList>> data);
    explicit TestModel(QList<QString> roles);

    int rowCount(const QModelIndex& parent) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex& index, int role) const override;

    void insert(int index, QVariantList row);
    void update(int index, int role, QVariant value);
    void remove(int index);

private:
    void initRoles();

    QList<QPair<QString, QVariantList>> m_data;
    QHash<int, QByteArray> m_roles;
};
