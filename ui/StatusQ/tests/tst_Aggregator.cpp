#include <QtTest>

#include <StatusQ/aggregator.h>
#include <TestHelpers/testmodel.h>

namespace {

class ChildAggregator : public Aggregator
{
    Q_OBJECT

public:
    explicit ChildAggregator(QObject* parent = nullptr) {}

protected slots:
    QVariant calculateAggregation() override
    {
        return {m_counter++};
    }

    bool acceptRoles(const QVector<int>& roles) override
    {
        return roles.contains(model()->roleNames().key("balance", -1));
    }

private:
    int m_counter = 0;
};

} // anonymous namespace

class TestAggregator : public QObject
{
    Q_OBJECT

private:
    static constexpr auto s_roleNameWarningText
        = "Provided role name does not exist in the current model";
    static constexpr auto s_unsuportedTypeWarningText
        = "Unsupported type for given role (not convertible to double)";

private slots:
    void testModel()
    {
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

    void testCalculateAggregationTrigger()
    {
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

        // Test 3 - Update value row of accepted role:
        sourceModel.update(2, 1, 26.45);
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);

        // Test 4 - Update value row of not accepted role:
        sourceModel.update(2, 0, "3");
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);

        // Test 5 - Layout change, no removals:
        sourceModel.invert();
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);

        // Test 6 - Layout change, with removing rows:
        sourceModel.removeEverySecond();
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);

        // Test 7 - Model reset:
        sourceModel.reset();
        valueChangedSpyCount++;
        QCOMPARE(valueChangedSpy.count(), valueChangedSpyCount);
    }
};

QTEST_MAIN(TestAggregator)
#include "tst_Aggregator.moc"
