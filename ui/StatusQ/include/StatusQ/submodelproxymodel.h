#pragma once

#include <QIdentityProxyModel>
#include <QPointer>

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

    QQmlComponent* delegateModel() const;
    void setDelegateModel(QQmlComponent* delegateModel);

    const QString& submodelRoleName() const;
    void setSubmodelRoleName(const QString& sumodelRoleName);

signals:
    void delegateModelChanged();
    void submodelRoleNameChanged();

private:
    void initializeIfReady();
    void initialize();
    void initRoles();

    void onDelegateChanged();

    QPointer<QQmlComponent> m_delegateModel;
    QString m_submodelRoleName;

    bool m_initialized = false;
    bool m_sourceModelDeleted = false;
    int m_submodelRole = 0;
};
