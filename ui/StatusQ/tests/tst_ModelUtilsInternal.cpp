#include <QtTest>

#include <QQmlEngine>

#include <StatusQ/modelutilsinternal.h>
#include <TestHelpers/listmodelwrapper.h>

class TestModelUtilsInternal : public QObject
{
    Q_OBJECT

private slots:
    void testIndexOf()
    {
        QQmlEngine engine;

        ListModelWrapper model(engine, R"([
            { name: "A", balance: 1, valid: true },
            { name: "B", balance: 2, valid: false },
            { name: "B", balance: 3, valid: false },
            { name: "C", balance: 4, valid: false }
        ])");

        ModelUtilsInternal utils;

        QCOMPARE(utils.indexOf(nullptr, "name", "A"), -1);
        QCOMPARE(utils.indexOf(model, "notExisting", "A"), -1);

        QCOMPARE(utils.indexOf(model, "name", "A"), 0);
        QCOMPARE(utils.indexOf(model, "name", "B"), 1);
        QCOMPARE(utils.indexOf(model, "name", "C"), 3);
        QCOMPARE(utils.indexOf(model, "name", "D"), -1);

        QCOMPARE(utils.indexOf(model, "valid", true), 0);
        QCOMPARE(utils.indexOf(model, "valid", false), 1);
        QCOMPARE(utils.indexOf(model, "valid", "true"), 0);
        QCOMPARE(utils.indexOf(model, "valid", "false"), 1);
        QCOMPARE(utils.indexOf(model, "valid", 1), 0);
        QCOMPARE(utils.indexOf(model, "valid", 0), 1);

        QCOMPARE(utils.indexOf(model, "balance", 1), 0);
        QCOMPARE(utils.indexOf(model, "balance", 2), 1);
        QCOMPARE(utils.indexOf(model, "balance", 3), 2);
        QCOMPARE(utils.indexOf(model, "balance", 4), 3);
        QCOMPARE(utils.indexOf(model, "balance", "4"), 3);
    }
};

QTEST_MAIN(TestModelUtilsInternal)
#include "tst_ModelUtilsInternal.moc"
