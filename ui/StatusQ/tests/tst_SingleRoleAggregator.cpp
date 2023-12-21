#include <QtTest>

#include <StatusQ/singleroleaggregator.h>
#include <TestHelpers/testmodel.h>

namespace {

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
        TestModel sourceModel({
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
