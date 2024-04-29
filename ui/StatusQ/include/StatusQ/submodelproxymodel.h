#pragma once

#include <QIdentityProxyModel>
#include <QPointer>

#include <limits>

class QQmlComponent;

class SubmodelProxyModel : public QIdentityProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QQmlComponent* delegateModel READ delegateModel
               WRITE setDelegateModel NOTIFY delegateModelChanged)

    Q_PROPERTY(QString submodelRoleName READ submodelRoleName
               WRITE setSubmodelRoleName NOTIFY submodelRoleNameChanged)

public:
    explicit SubmodelProxyModel(QObject* parent = nullptr);

    QVariant data(const QModelIndex& index, int role) const override;
    void setSourceModel(QAbstractItemModel* sourceModel) override;
    QHash<int, QByteArray> roleNames() const override;

    QQmlComponent* delegateModel() const;
    void setDelegateModel(QQmlComponent* delegateModel);

    const QString& submodelRoleName() const;
    void setSubmodelRoleName(const QString& sumodelRoleName);

signals:
    void delegateModelChanged();
    void submodelRoleNameChanged();

private slots:
    void onCustomRoleChanged(QObject* source, int role);
    void emitAllDataChanged();

private:
    void initializeIfReady();
    void initialize();
    void initRoles();

    void onDelegateChanged();

    QPointer<QQmlComponent> m_delegateModel;
    QPointer<QQmlComponent> m_connector;

    QString m_submodelRoleName;

    bool m_initialized = false;
    bool m_sourceModelDeleted = false;
    int m_submodelRole = 0;
    bool m_dataChangedQueued = false;

    QHash<int, QByteArray> m_roleNames;
    QHash<QString, int> m_additionalRolesMap;
    int m_additionalRolesOffset = std::numeric_limits<int>::max();
};
