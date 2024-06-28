#include <QtTest>

#include <StatusQ/modelcount.h>

#include <TestHelpers/testmodel.h>


class TestModelCount : public QObject
{
    Q_OBJECT

private slots:
    void modelCountTest()
    {
        TestModel model({
            { "name", { "a", "b", "c", "d" }}
        });

        ModelCount modelCount(&model);

        QCOMPARE(modelCount.count(), 4);

        QSignalSpy spy(&modelCount, &ModelCount::countChanged);

        model.insert(1, { "e" });

        QCOMPARE(spy.count(), 1);
        QCOMPARE(modelCount.count(), 5);

        model.remove(0);

        QCOMPARE(spy.count(), 2);
        QCOMPARE(modelCount.count(), 4);

        model.update(0, 0, "aa");

        QCOMPARE(spy.count(), 2);
        QCOMPARE(modelCount.count(), 4);

        model.invert();

        QCOMPARE(spy.count(), 2);
        QCOMPARE(modelCount.count(), 4);

        model.removeEverySecond();

        QCOMPARE(spy.count(), 3);
        QCOMPARE(modelCount.count(), 2);

        model.reset();

        QCOMPARE(spy.count(), 3);
        QCOMPARE(modelCount.count(), 2);

        model.resetAndClear();

        QCOMPARE(spy.count(), 4);
        QCOMPARE(modelCount.count(), 0);
    }
};

QTEST_MAIN(TestModelCount)
#include "tst_ModelCount.moc"
