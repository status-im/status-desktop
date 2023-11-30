#include <QtTest>
#include <QAbstractListModel>
#include <QCoreApplication>

#include "StatusQ/sumaggregator.h"

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

} // anonymous namespace

class TestSumAggregator : public QObject
{
    Q_OBJECT

private:
    QString m_roleNameWarningText = "Provided role name does not exist in the current model";
    QString m_unsuportedTypeWarningText = "Unsupported type for given role (not convertible to double)";

private slots:
    void testEmpty() {
        SumAggregator aggregator;
        QCOMPARE(aggregator.value(), 0.0);
    }

    void testModel() {
        SumAggregator aggregator;
        TestSourceModel sourceModel({
                                        { "chainId", { "12", "13", "1", "321" }},
                                        { "balance", { "0.123", "0.0000015", "1.45", "25.45221001" }}
                                    });
        QSignalSpy modelChangedSpy(&aggregator, &Aggregator::modelChanged);
        QSignalSpy valueChangedSpy(&aggregator, &Aggregator::valueChanged);

        // Test 1: Real model
        aggregator.setModel(&sourceModel);
        QCOMPARE(aggregator.model(), &sourceModel);
        QCOMPARE(modelChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 0);

        // Test 2: Non existing model
        aggregator.setModel(nullptr);
        QCOMPARE(aggregator.model(), nullptr);
        QCOMPARE(modelChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 0);
    }

    void testRoleName() {
        SumAggregator aggregator;
        TestSourceModel sourceModel({
                                        { "chainId", { "12", "13", "1", "321" }},
                                        { "balance", { "0.123", "0.0000015", "1.45", "25.45221001" }}
                                    });
        QSignalSpy roleNameSpy(&aggregator, &SingleRoleAggregator::roleNameChanged);
        QSignalSpy valueChangedSpy(&aggregator, &Aggregator::valueChanged);

        // Test 1 - Assign role name but model is nullptr
        aggregator.setRoleName("TestRole");
        QTest::ignoreMessage(QtWarningMsg,
                             m_roleNameWarningText.toUtf8());
        QCOMPARE(aggregator.roleName(), QString("TestRole"));
        QCOMPARE(roleNameSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 0);

        // Test 2 - New role but doesn't exist in the current model
        aggregator.setModel(&sourceModel);
        QTest::ignoreMessage(QtWarningMsg,
                             m_roleNameWarningText.toUtf8());
        aggregator.setRoleName("TestRole2");
        QCOMPARE(aggregator.roleName(), QString("TestRole2"));
        QCOMPARE(roleNameSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 0);

        // Test 3 - New role existing in the current model
        aggregator.setRoleName("balance");
        QCOMPARE(aggregator.roleName(), QString("balance"));
        QCOMPARE(roleNameSpy.count(), 3);
        QCOMPARE(valueChangedSpy.count(), 1);
    }

    void testStringTypeValue() {
        SumAggregator aggregator;
        TestSourceModel sourceModel({
                                        { "chainId", { "12", "13", "1", "321" }},
                                        { "balance", { "0.123", "1", "1.45", "25.45" }}
                                    });
        QSignalSpy valueChangedSpy(&aggregator, &Aggregator::valueChanged);
        int valueChangedSpyCount = 0;

        // Test 1 - Initial:
        aggregator.setModel(&sourceModel);
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        aggregator.setRoleName("balance");
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 28.023);

        // Test 2 - Delete row:
        sourceModel.remove(0);
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 27.9);

        // Test 3 - Update value row:
        sourceModel.update(2, 1, "26.45");
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 28.9);

        // Test 4 - Update value row but other role, not `balance`, so it will not trigger a value change:
        sourceModel.update(2, 0, "52");
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 28.9);
    }

    void testFloatTypeValue() {
        SumAggregator aggregator;
        TestSourceModel sourceModel({
                                        { "chainId", { "12", "13", "1", "321" }},
                                        { "balance", { 0.123, 1.0, 1.45, 25.45 }}
                                    });
        QSignalSpy valueChangedSpy(&aggregator, &Aggregator::valueChanged);
        int valueChangedSpyCount = 0;

        // Test 1 - Initial:
        aggregator.setModel(&sourceModel);
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        aggregator.setRoleName("balance");
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 28.023);

        // Test 2 - Delete row:
        sourceModel.remove(0);
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 27.9);

        // Test 3 - Update value row:
        sourceModel.update(2, 1, 26.45);
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 28.9);

        // Test 4 - Update value row but other role, not `balance`, so it will not trigger a value change:
        sourceModel.update(2, 0, "52");
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
        QCOMPARE(aggregator.value().toDouble(), 28.9);
    }

    void testStringUnsupportedTypeValue() {
        SumAggregator aggregator;
        TestSourceModel sourceModel({
                                        { "chainId", { "12", "13" }},
                                        { "balance", { "aa", "bb" }}
                                    });
        QSignalSpy valueChangedSpy(&aggregator, &Aggregator::valueChanged);

        aggregator.setModel(&sourceModel);
        QCOMPARE(valueChangedSpy.count(), 0);
        QTest::ignoreMessage(QtWarningMsg,
                             m_unsuportedTypeWarningText.toUtf8());
        QTest::ignoreMessage(QtWarningMsg,
                             m_unsuportedTypeWarningText.toUtf8());
        aggregator.setRoleName("balance");

        // Value didn't change, it was an unsuported type!
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(aggregator.value().toDouble(), 0);
    }

    void testUnsupportedTypeValue() {
        SumAggregator aggregator;
        TestSourceModel sourceModel({
                                        { "chainId", { "12", "13" }},
                                        { "balance", { QByteArray(), QByteArray() }}
                                    });
        QSignalSpy valueChangedSpy(&aggregator, &Aggregator::valueChanged);

        aggregator.setModel(&sourceModel);
        QCOMPARE(valueChangedSpy.count(), 0);
        QTest::ignoreMessage(QtWarningMsg,
                             m_unsuportedTypeWarningText.toUtf8());
        QTest::ignoreMessage(QtWarningMsg,
                             m_unsuportedTypeWarningText.toUtf8());
        aggregator.setRoleName("balance");

        // Value didn't change, it was an unsuported type!
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(aggregator.value().toDouble(), 0);
    }
};

QTEST_MAIN(TestSumAggregator)
#include "tst_SumAggregator.moc"
