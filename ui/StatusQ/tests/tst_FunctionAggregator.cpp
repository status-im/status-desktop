#include <QtTest>

#include <QQmlEngine>

#include <StatusQ/functionaggregator.h>
#include <TestHelpers/testmodel.h>

class TestFunctionAggregator : public QObject
{
    Q_OBJECT

private:
    void makeQmlEngineAvailable(QQmlEngine& engine, QObject& obj)
    {
        auto jsObj = engine.newQObject(&obj);
        engine.setObjectOwnership(&obj, QQmlEngine::CppOwnership);
        Q_UNUSED(jsObj);
    }

private slots:
    void basicTest() {
        QQmlEngine engine;
        FunctionAggregator aggregator;
        makeQmlEngineAvailable(engine, aggregator);

        auto jsLambda = engine.evaluate("(aggr, val) => [...aggr, val]");
        QCOMPARE(jsLambda.isError(), false);
        QCOMPARE(jsLambda.isCallable(), true);

        TestModel sourceModel({
            { "chainId", { "12", "13", "1", "321" }},
            { "balance", { "4", "3", "5", "5" }}
        });

        aggregator.setModel(&sourceModel);
        aggregator.setRoleName("balance");
        aggregator.setInitialValue(QVariantList());
        aggregator.setAggregateFunction(jsLambda);

        QVariantList expected{"4", "3", "5", "5"};
        QCOMPARE(aggregator.value(), expected);
    }

    void typeMismatchTest() {
        QQmlEngine engine;
        FunctionAggregator aggregator;
        makeQmlEngineAvailable(engine, aggregator);

        auto jsLambda = engine.evaluate("(aggr, val) => [...aggr, val]");
        QCOMPARE(jsLambda.isError(), false);
        QCOMPARE(jsLambda.isCallable(), true);

        TestModel sourceModel({{ "balance", { "4", "3", "5", "5" }}});

        aggregator.setModel(&sourceModel);
        aggregator.setRoleName("balance");
        aggregator.setInitialValue(0);

        QTest::ignoreMessage(QtWarningMsg,
                             "Aggregation calculation failed. Error type: 6");

        aggregator.setAggregateFunction(jsLambda);

        QCOMPARE(aggregator.value(), 0);
    }

    void roleNameNotFoundTest() {
        QQmlEngine engine;
        FunctionAggregator aggregator;
        makeQmlEngineAvailable(engine, aggregator);

        TestModel sourceModel({{ "balance", { "4", "3", "5", "5" }}});
        aggregator.setModel(&sourceModel);
        aggregator.setInitialValue(0);

        QTest::ignoreMessage(QtWarningMsg,
                             "Provided role name does not exist in the current model.");

        aggregator.setRoleName("notExisiting");
        QCOMPARE(aggregator.value(), 0);
    }

    void invalidFunctionTest() {
        FunctionAggregator aggregator;

        QTest::ignoreMessage(QtWarningMsg,
                             "FunctionAggregator::aggregateFunction must be a "
                                                   "callable object.");
        aggregator.setAggregateFunction(5);
    }

    void noJsEngineTest() {
        QQmlEngine engine;
        FunctionAggregator aggregator;

        auto jsLambda = engine.evaluate("(aggr) => aggr");
        QCOMPARE(jsLambda.isError(), false);
        QCOMPARE(jsLambda.isCallable(), true);

        TestModel sourceModel({
            { "balance", { "4", "3", "5", "5" }}
        });

        aggregator.setModel(&sourceModel);
        aggregator.setRoleName("balance");
        aggregator.setInitialValue(0);

        QTest::ignoreMessage(QtWarningMsg,
                             "FunctionAggregator is intended to be used in JS "
                             "environment. QJSEngine must be available.");

        aggregator.setAggregateFunction(jsLambda);
        QCOMPARE(aggregator.value(), 0);
    }

    void providingInitialValueIfNotReadyTest() {
        QQmlEngine engine;
        FunctionAggregator aggregator;
        makeQmlEngineAvailable(engine, aggregator);

        auto jsLambda = engine.evaluate("(aggr, val) => aggr + val");
        QCOMPARE(jsLambda.isError(), false);
        QCOMPARE(jsLambda.isCallable(), true);

        TestModel sourceModel({
            { "chainId", { "12", "13", "1", "321" }},
            { "balance", { "4", "3", "5", "5" }}
        });

        QCOMPARE(aggregator.value(), {});

        aggregator.setInitialValue("-");
        QCOMPARE(aggregator.value(), "-");

        aggregator.setModel(&sourceModel);
        QCOMPARE(aggregator.value(), "-");

        aggregator.setRoleName("balance");
        QCOMPARE(aggregator.value(), "-");

        aggregator.setAggregateFunction(jsLambda);
        QCOMPARE(aggregator.value(), "-4355");
    }
};

QTEST_MAIN(TestFunctionAggregator)
#include "tst_FunctionAggregator.moc"
