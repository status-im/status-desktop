#include <QtTest>
#include <QAbstractListModel>
#include <QCoreApplication>

#include "StatusQ/singleroleaggregator.h"

namespace {

// TODO: To be removed once issue #12843 is resolved and we have a testing utils
class TestSourceModel : public QAbstractListModel {

public:
    explicit TestSourceModel(QList<QPair<QString, QVariantList>> data)
        : m_data(std::move(data)) {
        m_roles.reserve(m_data.size());

        for (auto i = 0; i < m_data.size(); i++)
            m_roles.insert(i, m_data.at(i).first.toUtf8());
    }

    int rowCount(const QModelIndex& parent) const override {
        Q_ASSERT(m_data.size());
        return m_data.first().second.size();
    }

    QVariant data(const QModelIndex& index, int role) const override {
        if (!index.isValid() || role < 0 || role >= m_data.size())
            return {};

        const auto row = index.row();

        if (role >= m_data.length() || row >= m_data.at(0).second.length())
            return {};

        return m_data.at(role).second.at(row);
    }

    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override {
        beginInsertRows(parent, row, row + count - 1);
        m_data.insert(row, QPair<QString, QVariantList>());
        endInsertRows();
        return true;
    }

    void update(int index, int role, QVariant value) {
        Q_ASSERT(role < m_data.size() && index < m_data[role].second.size());
        m_data[role].second[index].setValue(std::move(value));

        emit dataChanged(this->index(index, 0), this->index(index, 0), { role });
    }

    void remove(int index) {
        beginRemoveRows(QModelIndex{}, index, index);

        for (int i = 0; i < m_data.size(); i++) {
            auto& roleVariantList = m_data[i].second;
            Q_ASSERT(index < roleVariantList.size());
            roleVariantList.removeAt(index);
        }

        endRemoveRows();
    }

    QHash<int, QByteArray> roleNames() const override {
        return m_roles;
    }

private:
    QList<QPair<QString, QVariantList>> m_data;
    QHash<int, QByteArray> m_roles;
};

class ChildSingleRoleAggregator : public SingleRoleAggregator {
    Q_OBJECT

public:
    explicit ChildSingleRoleAggregator(QObject *parent = nullptr) {}

protected slots:
    QVariant calculateAggregation() override { return {}; }
};

} // anonymous namespace

class TestSingleRoleAggregator : public QObject
{
    Q_OBJECT

private:
    QString m_roleNameWarningText = "Provided role name does not exist in the current model";

private slots:

    void testRoleName() {
        ChildSingleRoleAggregator aggregator;
        TestSourceModel sourceModel({
                                        { "chainId", { "12", "13", "1", "321" }},
                                        { "balance", { "0.123", "0.0000015", "1.45", "25.45221001" }}
                                    });
        QSignalSpy roleNameSpy(&aggregator, &SingleRoleAggregator::roleNameChanged);

        // Test 1 - Assign role name but model is nullptr
        aggregator.setRoleName("TestRole");
        QCOMPARE(aggregator.roleName(), QString("TestRole"));
        QCOMPARE(roleNameSpy.count(), 1);

        // Test 2 - New role but doesn't exist in the current model
        aggregator.setModel(&sourceModel);
        aggregator.setRoleName("TestRole2");
        QCOMPARE(aggregator.roleName(), QString("TestRole2"));
        QCOMPARE(roleNameSpy.count(), 2);

        // Test 3 - New role existing in the current model
        aggregator.setRoleName("balance");
        QCOMPARE(aggregator.roleName(), QString("balance"));
        QCOMPARE(roleNameSpy.count(), 3);
    }
};

QTEST_MAIN(TestSingleRoleAggregator)
#include "tst_SingleRoleAggregator.moc"
