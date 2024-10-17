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
        QCOMPARE(modelCount.empty(), false);

        QSignalSpy countSpy(&modelCount, &ModelCount::countChanged);
        QSignalSpy emptySpy(&modelCount, &ModelCount::emptyChanged);

        model.insert(1, { "e" });

        QCOMPARE(countSpy.count(), 1);
        QCOMPARE(emptySpy.count(), 0);
        QCOMPARE(modelCount.count(), 5);
        QCOMPARE(modelCount.empty(), false);

        model.remove(0);

        QCOMPARE(countSpy.count(), 2);
        QCOMPARE(emptySpy.count(), 0);
        QCOMPARE(modelCount.count(), 4);
        QCOMPARE(modelCount.empty(), false);

        model.update(0, 0, "aa");

        QCOMPARE(countSpy.count(), 2);
        QCOMPARE(emptySpy.count(), 0);
        QCOMPARE(modelCount.count(), 4);
        QCOMPARE(modelCount.empty(), false);

        model.invert();

        QCOMPARE(countSpy.count(), 2);
        QCOMPARE(emptySpy.count(), 0);
        QCOMPARE(modelCount.count(), 4);
        QCOMPARE(modelCount.empty(), false);

        model.removeEverySecond();

        QCOMPARE(countSpy.count(), 3);
        QCOMPARE(emptySpy.count(), 0);
        QCOMPARE(modelCount.count(), 2);
        QCOMPARE(modelCount.empty(), false);

        model.reset();

        QCOMPARE(countSpy.count(), 3);
        QCOMPARE(emptySpy.count(), 0);
        QCOMPARE(modelCount.count(), 2);
        QCOMPARE(modelCount.empty(), false);

        model.resetAndClear();

        QCOMPARE(countSpy.count(), 4);
        QCOMPARE(emptySpy.count(), 1);
        QCOMPARE(modelCount.count(), 0);
        QCOMPARE(modelCount.empty(), true);
    }
};

QTEST_MAIN(TestModelCount)
#include "tst_ModelCount.moc"
