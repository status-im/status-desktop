#include <QtTest>

#include <StatusQ/aggregator.h>
#include <TestHelpers/testmodel.h>

namespace {

class ChildAggregator : public Aggregator {
 Q_OBJECT

public:
    explicit ChildAggregator(QObject *parent = nullptr) {}

protected slots:
    QVariant calculateAggregation() override {
        return {counter++};
    }

private:
    int counter = 0;
};

} // anonymous namespace

class TestAggregator : public QObject
{
    Q_OBJECT

private:
    QString m_roleNameWarningText = "Provided role name does not exist in the current model";
    QString m_unsuportedTypeWarningText = "Unsupported type for given role (not convertible to double)";

private slots:
    void testModel() {
        ChildAggregator aggregator;
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
        QCOMPARE(valueChangedSpy.count(), 1);

        // Test 2: Non existing model
        aggregator.setModel(nullptr);
        QCOMPARE(aggregator.model(), nullptr);
        QCOMPARE(modelChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 2);
    }

    void testCalculateAggregationTrigger() {
        ChildAggregator aggregator;
        TestModel sourceModel({
            { "chainId", { "12", "13", "1", "321" }},
            { "balance", { 0.123, 1.0, 1.45, 25.45 }}
        });
        QSignalSpy valueChangedSpy(&aggregator, &Aggregator::valueChanged);
        int valueChangedSpyCount = 0;

        // Test 1 - Initial:
        aggregator.setModel(&sourceModel);
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);

        // Test 2 - Delete row:
        sourceModel.remove(0);
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);

        // Test 3 - Update value row:
        sourceModel.update(2, 1, 26.45);
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
    }
};

QTEST_MAIN(TestAggregator)
#include "tst_Aggregator.moc"
