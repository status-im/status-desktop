#include <QSignalSpy>
#include <QTest>

#include <QJsonArray>
#include <QJsonObject>
#include <QQmlEngine>
#include <QSortFilterProxyModel>

#include <StatusQ/movablemodel.h>
#include <StatusQ/snapshotmodel.h>

#include <TestHelpers/listmodelwrapper.h>
#include <TestHelpers/modelsignalsspy.h>
#include <TestHelpers/modeltestutils.h>
#include <TestHelpers/persistentindexestester.h>

class TestMovableModel : public QObject
{
    Q_OBJECT

    int roleForName(const QHash<int, QByteArray>& roles,
                    const QByteArray& name) const
    {
        auto keys = roles.keys(name);

        if (keys.empty())
            return -1;

        return keys.first();
    }

    static constexpr QModelIndex InvalidIdx{};

private slots:
    void initializationTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);

        QCOMPARE(model.synced(), true);
        QVERIFY(isSame(&model, sourceModel));
    }

    void desyncOrderTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);

        QSignalSpy syncedChangedSpy(&model, &MovableModel::syncedChanged);
        model.desyncOrder();

        QCOMPARE(syncedChangedSpy.count(), 1);
        QCOMPARE(model.synced(), false);
        QVERIFY(isSame(&model, sourceModel));

        model.setSourceModel(nullptr);
        QCOMPARE(syncedChangedSpy.count(), 2);
        QCOMPARE(model.synced(), true);
        QCOMPARE(model.rowCount(), 0);
    }

    void moveDownTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        ListModelWrapper sourceModelCopy(engine, source);

        MovableModel model;
        model.setSourceModel(sourceModel);
        model.desyncOrder();

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy referenceSignalsSpy(sourceModelCopy);

        model.move(0, 2, 2);
        sourceModelCopy.move(0, 2, 2);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(referenceSignalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsMovedSpy.count(), 1);

        QCOMPARE(signalsSpy.rowsAboutToBeMovedSpy.first(),
                 referenceSignalsSpy.rowsAboutToBeMovedSpy.first());
        QCOMPARE(signalsSpy.rowsMovedSpy.first(),
                 referenceSignalsSpy.rowsMovedSpy.first());

        ListModelWrapper expected(engine, R"([
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        QVERIFY(isSame(sourceModelCopy, expected));
        QVERIFY(isSame(&model, expected));
        QVERIFY(isSame(&model, sourceModelCopy));
    }

    void moveUpTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        ListModelWrapper sourceModelCopy(engine, source);

        MovableModel model;
        model.setSourceModel(sourceModel);
        model.desyncOrder();

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy referenceSignalsSpy(sourceModelCopy);

        model.move(3, 1, 2);
        sourceModelCopy.move(3, 1, 2);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(referenceSignalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsMovedSpy.count(), 1);

        QCOMPARE(signalsSpy.rowsAboutToBeMovedSpy.first(),
                 referenceSignalsSpy.rowsAboutToBeMovedSpy.first());
        QCOMPARE(signalsSpy.rowsMovedSpy.first(),
                 referenceSignalsSpy.rowsMovedSpy.first());

        ListModelWrapper expected(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c3" }
        ])");

        QVERIFY(isSame(sourceModelCopy, expected));
        QVERIFY(isSame(&model, expected));
        QVERIFY(isSame(&model, sourceModelCopy));
    }

    void moveToEndTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        ListModelWrapper sourceModelCopy(engine, source);

        MovableModel model;
        model.setSourceModel(sourceModel);
        model.desyncOrder();

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy referenceSignalsSpy(sourceModelCopy);

        model.move(1, 4, 2);
        sourceModelCopy.move(1, 4, 2);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(referenceSignalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsMovedSpy.count(), 1);

        ListModelWrapper expected(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" }
        ])");

        QVERIFY(isSame(sourceModelCopy, expected));
        QVERIFY(isSame(&model, expected));
        QVERIFY(isSame(&model, sourceModelCopy));
    }

    void moveToBeginningTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        ListModelWrapper sourceModelCopy(engine, source);

        MovableModel model;
        model.setSourceModel(sourceModel);
        model.desyncOrder();

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy referenceSignalsSpy(sourceModelCopy);

        model.move(3, 0, 3);
        sourceModelCopy.move(3, 0, 3);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(referenceSignalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(referenceSignalsSpy.rowsMovedSpy.count(), 1);

        ListModelWrapper expected(engine, R"([
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" },
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" }
        ])");

        QVERIFY(isSame(sourceModelCopy, expected));
        QVERIFY(isSame(&model, expected));
        QVERIFY(isSame(&model, sourceModelCopy));
    }

    void sortingTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        ListModelWrapper sourceModelCopy(engine, source);

        QSortFilterProxyModel sfpm;
        sfpm.setSourceModel(sourceModel);

        MovableModel model;
        model.setSourceModel(&sfpm);
        model.desyncOrder();

        model.move(2, 1);
        sourceModelCopy.move(2, 1);

        ModelSignalsSpy signalsSpy(&model);
        PersistentIndexesTester indexesTester(&model);

        sfpm.setSortRole(1);
        sfpm.sort(0, Qt::DescendingOrder);

        ListModelWrapper expectedSorted(engine, R"([
            { "name": "C", "subname": "c3" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c1" },
            { "name": "B", "subname": "b1" },
            { "name": "A", "subname": "a2" },
            { "name": "A", "subname": "a1" }
        ])");

        QCOMPARE(signalsSpy.count(), 0);

        QCOMPARE(sfpm.roleNames().value(1), "subname");
        QVERIFY(isSame(&sfpm, expectedSorted));
        QVERIFY(isSame(&model, sourceModelCopy));
        QVERIFY(indexesTester.compare());
    }

    void insertionTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);
        model.desyncOrder();
        model.move(4, 1);

        SnapshotModel snapshot(model);

        QObject context;
        connect(&model, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.insert(3, QJsonArray {
            QJsonObject {{ "name", "D"}, { "subname", "d1" }},
            QJsonObject {{ "name", "D"}, { "subname", "d2" }}
        });

        ListModelWrapper expected(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "C", "subname": "c2" },
            { "name": "A", "subname": "a2" },
            { "name": "D", "subname": "d1" },
            { "name": "D", "subname": "d2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c3" }
        ])");

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.first().at(0), QModelIndex{});
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.first().at(1), 3);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.first().at(2), 4);

        QCOMPARE(signalsSpy.rowsInsertedSpy.first().at(0), QModelIndex{});
        QCOMPARE(signalsSpy.rowsInsertedSpy.first().at(1), 3);
        QCOMPARE(signalsSpy.rowsInsertedSpy.first().at(2), 4);

        QVERIFY(isSame(&model, expected));
    }

    void removalTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);
        model.move(3, 0, 3);

        ListModelWrapper expectedIntermediate(engine, R"([
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" },
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" }
        ])");

        QVERIFY(isSame(&model, expectedIntermediate));

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.remove(1, 4);

        ListModelWrapper expected(engine, R"([
            { "name": "C", "subname": "c3" },
            { "name": "A", "subname": "a1" }
        ])");

        QVERIFY(isSame(&model, expected));

        QCOMPARE(signalsSpy.count(), 4);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 2);

        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(1), 4);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(2), 5);

        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(1).at(0), QModelIndex{});
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(1).at(1), 0);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(1).at(2), 1);

        QCOMPARE(signalsSpy.rowsRemovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(signalsSpy.rowsRemovedSpy.at(0).at(1), 4);
        QCOMPARE(signalsSpy.rowsRemovedSpy.at(0).at(2), 5);

        QCOMPARE(signalsSpy.rowsRemovedSpy.at(1).at(0), QModelIndex{});
        QCOMPARE(signalsSpy.rowsRemovedSpy.at(1).at(1), 0);
        QCOMPARE(signalsSpy.rowsRemovedSpy.at(1).at(2), 1);
    }

    void dataChangeWhenSyncedTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.setProperty(1, "subname", "a2_");

        ListModelWrapper expected(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2_" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        auto subnameRole = roleForName(model.roleNames(), "subname");

        QCOMPARE(signalsSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.first().at(0).toModelIndex(), model.index(1));
        QCOMPARE(signalsSpy.dataChangedSpy.first().at(1), model.index(1));
        QCOMPARE(signalsSpy.dataChangedSpy.first().at(2).value<QVector<int>>(),
                 {subnameRole});

        QVERIFY(isSame(&model, expected));
    }

    void dataChangeWhenDesyncedTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);
        model.desyncOrder();

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.setProperty(1, "subname", "a2_");

        ListModelWrapper expected(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2_" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        auto subnameRole = roleForName(model.roleNames(), "subname");

        QCOMPARE(signalsSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.first().at(0), model.index(0));
        QCOMPARE(signalsSpy.dataChangedSpy.first().at(1), model.index(model.rowCount() - 1));
        QCOMPARE(signalsSpy.dataChangedSpy.first().at(2).value<QVector<int>>(),
                 {subnameRole});

        QVERIFY(isSame(&model, expected));
    }

    void orderTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);

        QVector<int> expectedOrder = {0, 1, 2, 3, 4, 5};
        QCOMPARE(model.order(), expectedOrder);

        sourceModel.move(0, 1);
        QCOMPARE(model.order(), expectedOrder);

        sourceModel.move(0, 1); // restore original source order
        model.move(0, 1);
        expectedOrder = {1, 0, 2, 3, 4, 5};
        QCOMPARE(model.order(), expectedOrder);

        sourceModel.move(0, 1);
        expectedOrder = {0, 1, 2, 3, 4, 5};
        QCOMPARE(model.order(), expectedOrder);

        sourceModel.move(0, 1); // restore original source order
        model.move(0, 1);
        expectedOrder = {0, 1, 2, 3, 4, 5};
        QCOMPARE(model.order(), expectedOrder);

        model.move(1, 3, 2);
        expectedOrder = {0, 3, 4, 1, 2, 5};
        QCOMPARE(model.order(), expectedOrder);

        sourceModel.remove(4);
        expectedOrder = {0, 3, 1, 2, 4};
        QCOMPARE(model.order(), expectedOrder);
    }

    void invalidMoveTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])");

        MovableModel model;
        model.setSourceModel(sourceModel);

        {
            QTest::ignoreMessage(QtWarningMsg,
                                 "MovableModel: move: out of range");
            model.move(2, -1);
        }
        {
            QTest::ignoreMessage(QtWarningMsg,
                                 "MovableModel: move: out of range");
            model.move(-2, 1);
        }
        {
            QTest::ignoreMessage(QtWarningMsg,
                                 "MovableModel: move: out of range");
            model.move(5, 0, 2);
        }
        {
            QTest::ignoreMessage(QtWarningMsg,
                                 "MovableModel: move: out of range");
            model.move(0, 5, 2);
        }

        // QTest::failOnWarning(QRegularExpression(".?")); // Qt 6.3
        sourceModel.move(0, 0, 2);
    }

    void resetSourceTest() {
        QQmlEngine engine;

        auto source1 = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        auto source2 = R"([
            { "name_": "A", "subname_": "a1" },
            { "name_": "A", "subname_": "a2" }
        ])";

        ListModelWrapper sourceModel1(engine, source1);
        ListModelWrapper sourceModel2(engine, source2);

        MovableModel model;
        model.setSourceModel(sourceModel1);
        model.desyncOrder();

        QCOMPARE(model.synced(), false);

        ModelSignalsSpy signalsSpy(&model);
        QSignalSpy syncedChangedSpy(&model, &MovableModel::syncedChanged);

        model.setSourceModel(sourceModel2);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy.modelResetSpy.count(), 1);


        QCOMPARE(syncedChangedSpy.count(), 1);
        QCOMPARE(model.synced(), true);
        QCOMPARE(model.rowCount(), 2);

        QVERIFY(isSame(&model, sourceModel2));
    }

    void syncOrderTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        MovableModel model;

        {
            ModelSignalsSpy signalsSpy(&model);
            model.syncOrder();
            QCOMPARE(signalsSpy.count(), 0);
        }

        {
            ModelSignalsSpy signalsSpy(&model);
            model.setSourceModel(sourceModel);
            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
        }

        {
            ModelSignalsSpy signalsSpy(&model);
            model.syncOrder();
            QCOMPARE(signalsSpy.count(), 0); //already synced
        }

        PersistentIndexesTester indexesTester(&model);

        model.desyncOrder();
        sourceModel.move(0, 2, 2);

        QVERIFY(isNotSame(&model, sourceModel));

        ModelSignalsSpy signalsSpy(&model);
        QSignalSpy syncedChangedSpy(&model, &MovableModel::syncedChanged);

        model.syncOrder();

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.layoutAboutToBeChangedSpy.count(), 1);
        QCOMPARE(signalsSpy.layoutChangedSpy.count(), 1);

        QCOMPARE(syncedChangedSpy.count(), 1);
        QCOMPARE(model.synced(), true);

        QVERIFY(isSame(&model, sourceModel));
        QVERIFY(indexesTester.compare());
    }

    void sortingSyncedTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);

        QSortFilterProxyModel sfpm;
        sfpm.setSourceModel(sourceModel);

        MovableModel model;
        model.setSourceModel(&sfpm);

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy signalsSpySfpm(&sfpm);

        PersistentIndexesTester indexesTester(&model);

        sfpm.setSortRole(1);
        sfpm.sort(0, Qt::DescendingOrder);

        ListModelWrapper expectedSorted(engine, R"([
            { "name": "C", "subname": "c3" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c1" },
            { "name": "B", "subname": "b1" },
            { "name": "A", "subname": "a2" },
            { "name": "A", "subname": "a1" }
        ])");

        QVERIFY(isSame(&sfpm, expectedSorted));

        QCOMPARE(model.synced(), true);
        QCOMPARE(signalsSpy.count(), signalsSpySfpm.count());
        QVERIFY(indexesTester.compare());
    }
    
    void sourceModelResetTest()
    {
        QQmlEngine engine;

        auto source = R"([
            { "name": "A", "subname": "a1" },
            { "name": "A", "subname": "a2" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "C", "subname": "c2" },
            { "name": "C", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel(engine, source);

        QSortFilterProxyModel sfpm;
        sfpm.setSourceModel(sourceModel);

        MovableModel model;
        model.setSourceModel(&sfpm);

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy signalsSpySfpm(&sfpm);

        PersistentIndexesTester indexesTester(&model);

        sfpm.setSortRole(1);
        sfpm.sort(0, Qt::DescendingOrder);

        model.move(0, 1);

        auto source2 = R"([
            { "name": "E", "subname": "a1" },
            { "name": "F", "subname": "a2" },
            { "name": "F", "subname": "b1" },
            { "name": "G", "subname": "c1" },
            { "name": "H", "subname": "c2" },
            { "name": "H", "subname": "c3" }
        ])";

        ListModelWrapper sourceModel2(engine, source2);
        sfpm.setSourceModel(sourceModel2);
        sfpm.setFilterRole(0);
        sfpm.setFilterFixedString("H");

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(1), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(2), 5);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);
    }
};

QTEST_MAIN(TestMovableModel)
#include "tst_MovableModel.moc"
