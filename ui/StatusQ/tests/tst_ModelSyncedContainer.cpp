#include <QtTest>
#include <QQmlEngine>

#include <StatusQ/modelsyncedcontainer.h>

#include <TestHelpers/listmodelwrapper.h>
#include <TestHelpers/testmodel.h>

class TestModelSyncedContainer : public QObject
{
    Q_OBJECT

private slots:
    void basicTest()
    {
        QQmlEngine engine;

        ListModelWrapper model(engine, R"([
            { "name": "A" }, { "name": "A" }, { "name": "B" },
            { "name": "C" }, { "name": "C" }, { "name": "C" }
        ])");

        ModelSyncedContainer<int> container;
        QCOMPARE(container.size(), 0);

        container.setModel(model);
        QCOMPARE(container.size(), 6);

        QCOMPARE(container.data(), std::vector<int>({0, 0, 0, 0, 0, 0}));
    }

    void modelChangeTest()
    {
        QQmlEngine engine;

        ListModelWrapper model1(engine, R"([
            { "name": "A" }, { "name": "A" }, { "name": "B" },
            { "name": "C" }, { "name": "C" }, { "name": "C" }
        ])");

        ListModelWrapper model2(engine, R"([ { "name": "A" } ])");

        ModelSyncedContainer<int> container;
        QCOMPARE(container.size(), 0);

        container.setModel(model1);
        QCOMPARE(container.size(), 6);

        QCOMPARE(container.data(), std::vector<int>({0, 0, 0, 0, 0, 0}));

        container[0] = 3;

        container.setModel(model2);
        QCOMPARE(container.size(), 1);

        QCOMPARE(container.data(), std::vector<int>({0}));

        container.setModel(nullptr);
        QCOMPARE(container.size(), 0);
    }

    void modelChangeDisconnectionTest()
    {
        struct Model : public QIdentityProxyModel
        {
            void connectNotify(const QMetaMethod&) override
            {
                connectionsCount++;
            }

            void disconnectNotify(const QMetaMethod&) override
            {
                connectionsCount--;
            }

            int connectionsCount = 0;
        };

        Model model1, model2;
        ModelSyncedContainer<int> container;

        QCOMPARE(model1.connectionsCount, 0);

        container.setModel(&model1);
        QVERIFY(model1.connectionsCount > 0);

        container.setModel(nullptr);
        QCOMPARE(model1.connectionsCount, 0);

        container.setModel(&model1);
        QVERIFY(model1.connectionsCount > 0);

        container.setModel(&model2);
        QCOMPARE(model1.connectionsCount, 0);
        QVERIFY(model2.connectionsCount > 0);
    }

    void appendTest()
    {
        QQmlEngine engine;

        ListModelWrapper model(engine, R"([
            { "name": "A" }, { "name": "A" }, { "name": "B" },
            { "name": "C" }, { "name": "C" }, { "name": "C" }
        ])");

        ModelSyncedContainer<int> container;
        container.setModel(model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.append(QJsonArray {
            QJsonObject {{ "key", 205}, { "balance", 305 }, { "name", "n205" }},
            QJsonObject {{ "key", 206},{ "balance", 306 }, { "name", "n206" }}
        });

        QCOMPARE(container.data(), std::vector<int>({0, 1, 2, 3, 4, 5, 0, 0}));
    }

    void insertTest()
    {
        QQmlEngine engine;

        ListModelWrapper model(engine, R"([
            { "name": "A" }, { "name": "A" }, { "name": "B" },
            { "name": "C" }, { "name": "C" }, { "name": "C" }
        ])");

        ModelSyncedContainer<int> container;
        container.setModel(model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.insert(2, QJsonArray {
            QJsonObject {{ "key", 205}, { "balance", 305 }, { "name", "n205" }},
            QJsonObject {{ "key", 206},{ "balance", 306 }, { "name", "n206" }}
        });

        QCOMPARE(container.data(), std::vector<int>({0, 1, 0, 0, 2, 3, 4, 5}));
    }

    void moveSingleItemTest()
    {
        QQmlEngine engine;

        ListModelWrapper model(engine, R"([
            { "name": "A" }, { "name": "B" }, { "name": "C" },
            { "name": "D" }, { "name": "E" }, { "name": "F" }
        ])");

        ModelSyncedContainer<int> container;
        container.setModel(model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.move(1, 0);
        QCOMPARE(container.data(), std::vector<int>({1, 0, 2, 3, 4, 5}));

        model.move(5, 0);
        QCOMPARE(container.data(), std::vector<int>({5, 1, 0, 2, 3, 4}));

        model.move(0, 5);
        QCOMPARE(container.data(), std::vector<int>({1, 0, 2, 3, 4, 5}));
    }

    void moveMultipleItemTest()
    {
        QQmlEngine engine;

        ListModelWrapper model(engine, R"([
            { "name": "A" }, { "name": "B" }, { "name": "C" },
            { "name": "D" }, { "name": "E" }, { "name": "F" }
        ])");

        ModelSyncedContainer<int> container;
        container.setModel(model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.move(0, 3, 3);
        QCOMPARE(container.data(), std::vector<int>({3, 4, 5, 0, 1, 2}));

        model.move(3, 0, 3);
        QCOMPARE(container.data(), std::vector<int>({0, 1, 2, 3, 4, 5}));
    }

    void removeTest()
    {
        QQmlEngine engine;

        ListModelWrapper model(engine, R"([
            { "name": "A" }, { "name": "B" }, { "name": "C" },
            { "name": "D" }, { "name": "E" }, { "name": "F" }
        ])");

        ModelSyncedContainer<int> container;
        container.setModel(model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.remove(1, 2);
        QCOMPARE(container.data(), std::vector<int>({0, 3, 4, 5}));
    }

    void layoutChangeTest()
    {
        TestModel model({
            { "name", { "A", "B", "C", "D", "E", "F" }}
        });

        ModelSyncedContainer<int> container;
        container.setModel(&model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.invert();
        QCOMPARE(container.data(), std::vector<int>({5, 4, 3, 2, 1, 0}));
    }

    void layoutChangeWithRomovalTest()
    {
        TestModel model({
            { "name", { "A", "B", "C", "D", "E", "F" }}
        });

        ModelSyncedContainer<int> container;
        container.setModel(&model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.removeEverySecond();
        QCOMPARE(container.data(), std::vector<int>({1, 3, 5}));
    }

    void modelResetTest()
    {
        TestModel model({
            { "name", { "A", "B", "C", "D", "E", "F" }}
        });

        ModelSyncedContainer<int> container;
        container.setModel(&model);

        for (auto i = 0; i < container.size(); i++)
            container[i] = i;

        model.reset();
        QCOMPARE(container.data(), std::vector<int>({0, 0, 0, 0, 0, 0}));
    }

    void modelDestroyedTest()
    {
        ModelSyncedContainer<int> container;

        {
            TestModel model({
                { "name", { "A", "B", "C", "D", "E", "F" }}
            });

            container.setModel(&model);
            QCOMPARE(container.size(), model.rowCount());
        }

        QCOMPARE(container.size(), 0);
    }

    // This test verifies if `ModelSyncedContainer` can be parametrized with
    // non-copyable type, like std::unique_ptr
    void nonCopyableTypeTest()
    {
        TestModel model({
            { "name", { "A", "B", "C", "D", "E", "F" }}
        });

        ModelSyncedContainer<std::unique_ptr<int>> container;
        container.setModel(&model);
    }
};

QTEST_MAIN(TestModelSyncedContainer)
#include "tst_ModelSyncedContainer.moc"
