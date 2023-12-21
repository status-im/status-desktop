#include <QtTest>

#include <StatusQ/sumaggregator.h>
#include <TestHelpers/testmodel.h>

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
        TestModel sourceModel({
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
        TestModel sourceModel({
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
        TestModel sourceModel({
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
        TestModel sourceModel({
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
        TestModel sourceModel({
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
        TestModel sourceModel({
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
