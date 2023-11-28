#pragma once

#include <QAbstractProxyModel>

#include <optional>
#include <memory>

class RangeModel;

class GroupingModel : public QAbstractProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QString groupingRoleName READ groupingRoleName
               WRITE setGroupingRoleName NOTIFY groupingRoleNameChanged)
    Q_PROPERTY(QString submodelRoleName READ submodelRoleName
               WRITE setSubmodelRoleName NOTIFY submodelRoleNameChanged)

public:
    explicit GroupingModel(QObject* parent = nullptr);
    ~GroupingModel();

    void setSourceModel(QAbstractItemModel* sourceModel) override;

    QModelIndex mapToSource(const QModelIndex& proxyIndex) const override;
    QModelIndex mapFromSource(const QModelIndex& sourceIndex) const override;

    void setGroupingRoleName(const QString& groupingRoleName);
    const QString& groupingRoleName() const;

    void setSubmodelRoleName(const QString& submodelRoleName);
    const QString& submodelRoleName() const;

    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int	columnCount(const QModelIndex& parent = QModelIndex()) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QModelIndex index(int row, int column = 0, const QModelIndex& parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex& child) const override;

signals:
    void groupingRoleNameChanged();
    void submodelRoleNameChanged();

protected slots:
    void resetInternalData();

private:
    static constexpr auto s_defaultSubmodelRoleName = "submodel";

    struct Entry {
        int submodel = 0;      // index of submodel
        int submodelIndex = 0; // index within submodel
        int sourceIndex = 0;   // index within source model
    };

    void init();
    void initRoles();
    void initSubmodelRole();

    void connectSignals(QAbstractItemModel* model);

    std::vector<Entry> m_entries;
    std::vector<std::unique_ptr<RangeModel>> m_submodels;

    RangeModel* m_pendingMergeSubmodel = nullptr;
    RangeModel* m_pendingRemovalSubmodel = nullptr;

    QHash<int, QByteArray> m_roleNames;
    QString m_groupingRoleName;
    QString m_submodelRoleName = s_defaultSubmodelRoleName;

    std::optional<int> m_groupingRole;

    int m_submodelRole = -1;
    bool m_rolesInitialized = false;

    friend class RangeModel;
};
