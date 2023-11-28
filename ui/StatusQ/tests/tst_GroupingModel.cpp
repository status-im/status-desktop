#include <QIdentityProxyModel>
#include <QJsonArray>
#include <QJsonObject>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QTest>

#include <memory>
#include <set>
#include <string>

#include <StatusQ/groupingmodel.h>
#include <StatusQ/snapshotmodel.h>


#include <TestHelpers/listmodelwrapper.h>
#include <TestHelpers/modelsignalsspy.h>
#include <TestHelpers/modeltestutils.h>


class TestGroupingModel: public QObject
{
    Q_OBJECT

    int roleForName(const QHash<int, QByteArray>& roles, const QByteArray& name) const
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
            { "name": "C", "subname": "c3" },
            { "name": "C", "subname": "c4" },
            { "name": "D", "subname": "d1" },
            { "name": "D", "subname": "d2" },
            { "name": "D", "subname": "d3" },
            { "name": "E", "subname": "e1" },
            { "name": "E", "subname": "e2" }
        ])");

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" },
                    { "name": "C", "subname": "c2" },
                    { "name": "C", "subname": "c3" },
                    { "name": "C", "subname": "c4" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" },
                    { "name": "D", "subname": "d2" },
                    { "name": "D", "subname": "d3" }
                ]
            },
            {
                "name": "E", "subname": "e1",
                "submodel": [
                    { "name": "E", "subname": "e1" },
                    { "name": "E", "subname": "e2" }
                ]
            }
        ])");

        {
            GroupingModel model;
            model.setGroupingRoleName("name");
            model.setSourceModel(sourceModel);

            QVERIFY(isSame(model, *expected.model()));
        }

        {
            GroupingModel model;
            model.setSourceModel(sourceModel);
            model.setGroupingRoleName("name");

            QVERIFY(isSame(model, *expected.model()));
        }

        {
            GroupingModel model;
            model.setSourceModel(sourceModel);
            model.setGroupingRoleName("name_");

            QCOMPARE(model.rowCount(), 0);
            model.setGroupingRoleName("name");

            QVERIFY(isSame(model, *expected.model()));
        }
    }

    void sourceDataChangeTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, R"([
            { "name": "A", "subname": "a1" }, // 0 0
            { "name": "A", "subname": "a2" }, //   1
            { "name": "B", "subname": "b1" }, // 1 2
            { "name": "C", "subname": "c1" }, // 2 3
            { "name": "C", "subname": "c2" }, //   4
            { "name": "C", "subname": "c3" }, //   5
            { "name": "C", "subname": "c4" }, //   6
            { "name": "D", "subname": "d1" }, // 3 7
            { "name": "D", "subname": "d2" }, //   8
            { "name": "D", "subname": "d3" }, //   9
            { "name": "E", "subname": "e1" }, // 4 10
            { "name": "E", "subname": "e2" }  //   11
        ])");

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" },
                    { "name": "C", "subname": "c2" },
                    { "name": "C", "subname": "c3" },
                    { "name": "C", "subname": "c4" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" },
                    { "name": "D", "subname": "d2" },
                    { "name": "D", "subname": "d3" }
                ]
            },
            {
                "name": "E", "subname": "e1",
                "submodel": [
                    { "name": "E", "subname": "e1" },
                    { "name": "E", "subname": "e2" }
                ]
            }
        ])");

        GroupingModel model;
        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        auto roles = model.roleNames();
        auto nameRole = roleForName(roles, "name");
        auto subnameRole = roleForName(roles, "subname");
        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();
        auto submodel4 = model.data(model.index(3, 0), submodelRole).value<QAbstractItemModel*>();
        auto submodel5 = model.data(model.index(4, 0), submodelRole).value<QAbstractItemModel*>();

        {
            ModelSignalsSpy signalsSpy(&model);
            ModelSignalsSpy submodel1Spy(submodel1);
            ModelSignalsSpy submodel2Spy(submodel2);
            ModelSignalsSpy submodel3Spy(submodel3);
            ModelSignalsSpy submodel4Spy(submodel4);
            ModelSignalsSpy submodel5Spy(submodel5);

            emit sourceModel.model()->dataChanged(sourceModel.model()->index(0, 0),
                                                  sourceModel.model()->index(0, 0));

            QCOMPARE(signalsSpy.count(), 1);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
            QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(0), model.index(0, 0));
            QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(1), model.index(0, 0));

            QSet<int> expectedRoles{nameRole, subnameRole};
            auto roles = signalsSpy.dataChangedSpy.at(0).at(2).value<QVector<int>>();
            QSet<int> rolesSet(roles.cbegin(), roles.cend());

            QCOMPARE(rolesSet, expectedRoles);

            QCOMPARE(submodel1Spy.count(), 1);
            QCOMPARE(submodel1Spy.dataChangedSpy.count(), 1);
            QCOMPARE(submodel1Spy.dataChangedSpy.at(0).at(0), submodel1->index(0, 0));
            QCOMPARE(submodel1Spy.dataChangedSpy.at(0).at(1), submodel1->index(0, 0));
            QCOMPARE(submodel2Spy.count(), 0);
            QCOMPARE(submodel3Spy.count(), 0);
            QCOMPARE(submodel4Spy.count(), 0);
            QCOMPARE(submodel5Spy.count(), 0);
        }
        {
            ModelSignalsSpy signalsSpy(&model);
            ModelSignalsSpy submodel1Spy(submodel1);
            ModelSignalsSpy submodel2Spy(submodel2);
            ModelSignalsSpy submodel3Spy(submodel3);
            ModelSignalsSpy submodel4Spy(submodel4);
            ModelSignalsSpy submodel5Spy(submodel5);

            emit sourceModel.model()->dataChanged(sourceModel.model()->index(4, 0),
                                                  sourceModel.model()->index(7, 0),
                                                  { subnameRole });

            QCOMPARE(signalsSpy.count(), 1);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
            QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(0), model.index(3, 0));
            QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(1), model.index(3, 0));

            QVector<int> expectedRoles{subnameRole};
            auto roles = signalsSpy.dataChangedSpy.at(0).at(2).value<QVector<int>>();

            QCOMPARE(roles, expectedRoles);

            QCOMPARE(submodel1Spy.count(), 0);
            QCOMPARE(submodel2Spy.count(), 0);
            QCOMPARE(submodel3Spy.count(), 1);
            QCOMPARE(submodel3Spy.dataChangedSpy.count(), 1);
            QCOMPARE(submodel3Spy.dataChangedSpy.at(0).at(0), submodel3->index(1, 0));
            QCOMPARE(submodel3Spy.dataChangedSpy.at(0).at(1), submodel3->index(3, 0));

            roles = submodel3Spy.dataChangedSpy.at(0).at(2).value<QVector<int>>();
            QCOMPARE(roles, expectedRoles);

            QCOMPARE(submodel4Spy.count(), 1);
            QCOMPARE(submodel4Spy.dataChangedSpy.count(), 1);
            QCOMPARE(submodel4Spy.dataChangedSpy.at(0).at(0), submodel4->index(0, 0));
            QCOMPARE(submodel4Spy.dataChangedSpy.at(0).at(1), submodel4->index(0, 0));

            roles = submodel4Spy.dataChangedSpy.at(0).at(2).value<QVector<int>>();
            QCOMPARE(roles, expectedRoles);

            QCOMPARE(submodel5Spy.count(), 0);
        }
        {
            ModelSignalsSpy signalsSpy(&model);
            ModelSignalsSpy submodel1Spy(submodel1);
            ModelSignalsSpy submodel2Spy(submodel2);
            ModelSignalsSpy submodel3Spy(submodel3);
            ModelSignalsSpy submodel4Spy(submodel4);
            ModelSignalsSpy submodel5Spy(submodel5);

            emit sourceModel.model()->dataChanged(sourceModel.model()->index(4, 0),
                                                  sourceModel.model()->index(6, 0));

            QCOMPARE(signalsSpy.count(), 0);
            QCOMPARE(submodel1Spy.count(), 0);
            QCOMPARE(submodel2Spy.count(), 0);
            QCOMPARE(submodel3Spy.count(), 1);
            QCOMPARE(submodel3Spy.dataChangedSpy.count(), 1);
            QCOMPARE(submodel3Spy.dataChangedSpy.at(0).at(0), submodel3->index(1, 0));
            QCOMPARE(submodel3Spy.dataChangedSpy.at(0).at(1), submodel3->index(3, 0));
            QVERIFY(submodel3Spy.dataChangedSpy.at(0).at(2).value<QVector<int>>().isEmpty());

            QCOMPARE(submodel4Spy.count(), 0);
            QCOMPARE(submodel5Spy.count(), 0);
        }
        {
            ModelSignalsSpy signalsSpy(&model);
            ModelSignalsSpy submodel1Spy(submodel1);
            ModelSignalsSpy submodel2Spy(submodel2);
            ModelSignalsSpy submodel3Spy(submodel3);
            ModelSignalsSpy submodel4Spy(submodel4);
            ModelSignalsSpy submodel5Spy(submodel5);

            emit sourceModel.model()->dataChanged(sourceModel.model()->index(2, 0),
                                                  sourceModel.model()->index(7, 0),
                                                  { subnameRole });

            QCOMPARE(signalsSpy.count(), 1);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
            QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(0), model.index(1, 0));
            QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(1), model.index(3, 0));

            QVector<int> expectedRoles{subnameRole};
            auto roles = signalsSpy.dataChangedSpy.at(0).at(2).value<QVector<int>>();

            QCOMPARE(roles, expectedRoles);

            QCOMPARE(submodel1Spy.count(), 0);
            QCOMPARE(submodel2Spy.count(), 1);
            QCOMPARE(submodel2Spy.dataChangedSpy.count(), 1);
            QCOMPARE(submodel2Spy.dataChangedSpy.at(0).at(0), submodel2->index(0, 0));
            QCOMPARE(submodel2Spy.dataChangedSpy.at(0).at(1), submodel2->index(0, 0));

            QCOMPARE(submodel3Spy.count(), 1);
            QCOMPARE(submodel3Spy.dataChangedSpy.count(), 1);
            QCOMPARE(submodel3Spy.dataChangedSpy.at(0).at(0), submodel3->index(0, 0));
            QCOMPARE(submodel3Spy.dataChangedSpy.at(0).at(1), submodel3->index(3, 0));

            QCOMPARE(submodel4Spy.count(), 1);
            QCOMPARE(submodel4Spy.dataChangedSpy.count(), 1);
            QCOMPARE(submodel4Spy.dataChangedSpy.at(0).at(0), submodel4->index(0, 0));
            QCOMPARE(submodel4Spy.dataChangedSpy.at(0).at(1), submodel4->index(0, 0));

            QCOMPARE(submodel5Spy.count(), 0);
        }

        QVERIFY(isSame(model, *expected.model()));
    }

    void setSourceTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel1(engine);
        ListModelWrapper sourceModel2(engine);

        auto contains = [](auto roles, auto name) {
            return std::find(roles.cbegin(), roles.cend(), name) != roles.cend();
        };

        GroupingModel model;
        auto signalsSpy = std::make_unique<ModelSignalsSpy>(&model);

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel1.model()); // set empty source model

        QCOMPARE(signalsSpy->count(), 2);
        QCOMPARE(signalsSpy->modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy->modelResetSpy.count(), 1);

        QCOMPARE(model.rowCount(), 0);

        {
            auto roles = model.roleNames();
            QCOMPARE(roles.size(), 0);
        }

        sourceModel1.append(QJsonArray { // append to empty source model
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }}
        });

        QCOMPARE(signalsSpy->count(), 4);
        QCOMPARE(signalsSpy->rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy->rowsInsertedSpy.count(), 1);
        signalsSpy = std::make_unique<ModelSignalsSpy>(&model);

        QCOMPARE(model.rowCount(), 2);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "subname"));
        }

        model.setSourceModel(sourceModel2); // set empty source model

        QCOMPARE(signalsSpy->count(), 2);
        QCOMPARE(signalsSpy->modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy->modelResetSpy.count(), 1);

        QCOMPARE(model.rowCount(), 0);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 0);
        }

        sourceModel2.append(QJsonArray { // append to empty source model
            QJsonObject {{ "name", "A"}, { "subname_", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname_", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname_", "b1" }}
        });

        QCOMPARE(signalsSpy->count(), 4);
        QCOMPARE(signalsSpy->rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy->rowsInsertedSpy.count(), 1);
        signalsSpy = std::make_unique<ModelSignalsSpy>(&model);

        QCOMPARE(model.rowCount(), 2);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "subname_"));
        }

        model.setSourceModel(nullptr); // set null source model

        QCOMPARE(signalsSpy->count(), 2);
        QCOMPARE(signalsSpy->modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy->modelResetSpy.count(), 1);

        QCOMPARE(model.rowCount(), 0);

        model.setSourceModel(nullptr); // set null source model

        QCOMPARE(signalsSpy->count(), 2);
        signalsSpy = std::make_unique<ModelSignalsSpy>(&model);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 0);
        }

        QCOMPARE(signalsSpy->count(), 0);

        model.setSourceModel(sourceModel2); // set not empty source model

        QCOMPARE(signalsSpy->count(), 2);
        QCOMPARE(signalsSpy->modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy->modelResetSpy.count(), 1);
        signalsSpy = std::make_unique<ModelSignalsSpy>(&model);

        QCOMPARE(model.rowCount(), 2);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "subname_"));
        }

        model.setSourceModel(sourceModel1); // set not empty source model

        QCOMPARE(signalsSpy->count(), 2);
        QCOMPARE(signalsSpy->modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy->modelResetSpy.count(), 1);

        QCOMPARE(model.rowCount(), 2);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "subname"));
        }
    }

    void setSubmodelRoleTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "subnames": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "subnames": [
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "subnames": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        auto contains = [](auto roles, auto name) {
            return std::find(roles.cbegin(), roles.cend(), name) != roles.cend();
        };

        {
            GroupingModel model;
            auto signalsSpy = std::make_unique<ModelSignalsSpy>(&model);

            model.setGroupingRoleName("name");
            model.setSubmodelRoleName("subnames");

            model.setSourceModel(sourceModel.model());

            QCOMPARE(signalsSpy->count(), 2);
            QCOMPARE(signalsSpy->modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy->modelResetSpy.count(), 1);

            QCOMPARE(model.rowCount(), 3);

            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "subname"));
            QVERIFY(contains(roles, "subnames"));

            QVERIFY(isSame(model, *expected.model()));
        }

        {
            GroupingModel model;
            auto signalsSpy = std::make_unique<ModelSignalsSpy>(&model);

            model.setGroupingRoleName("name");
            model.setSourceModel(sourceModel.model());
            model.setSubmodelRoleName("subnames");

            QCOMPARE(signalsSpy->count(), 4);
            QCOMPARE(signalsSpy->modelAboutToBeResetSpy.count(), 2);
            QCOMPARE(signalsSpy->modelResetSpy.count(), 2);

            QCOMPARE(model.rowCount(), 3);

            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "subname"));
            QVERIFY(contains(roles, "subnames"));

            QVERIFY(isSame(model, *expected.model()));
        }
    }

    void preppendToFirstGroupTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a0",
                "submodel": [
                    { "name": "A", "subname": "a0"  },
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(submodel1, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel1, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, expected = expected.model()] {
            QVERIFY(isSame(m, expected));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.insert(0, QJsonObject {
            { "name", "A"}, { "subname", "a0" }
        });

        QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(0), model.index(0));
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(1), model.index(0));
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                 { roleForName(roles, "subname") });

        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 0);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 0);

        QCOMPARE(submodel1Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(1), 0);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(2), 0);

        QCOMPARE(signalsSpy.count(), 1);
        QCOMPARE(submodel1Spy.count(), 2);
        QCOMPARE(submodel2Spy.count(), 0);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(model, *expected.model()));
    }

    void preppendToGroupTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b01",
                "submodel": [
                    { "name": "B", "subname": "b01" },
                    { "name": "B", "subname": "b02" },
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(submodel2, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel2, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, expected = expected.model()] {
            QVERIFY(isSame(m, expected));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.insert(2, QJsonArray {
            QJsonObject {{ "name", "B"}, { "subname", "b01" }},
            QJsonObject {{ "name", "B"}, { "subname", "b02" }}
        });

        QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(0), model.index(1));
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(1), model.index(1));
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                 { roleForName(roles, "subname") });

        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 0);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 1);

        QCOMPARE(submodel2Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(1), 0);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(2), 1);

        QCOMPARE(signalsSpy.count(), 1);
        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 2);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(model, *expected.model()));
    }

    void insertToGroupTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a11" },
                    { "name": "A", "subname": "a12" },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(submodel1, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });

        connect(submodel1, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, expected = expected.model()] {
            QVERIFY(isSame(m, expected));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.insert(1, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a11" }},
            QJsonObject {{ "name", "A"}, { "subname", "a12" }}
        });

        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 2);

        QCOMPARE(submodel1Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(2), 2);

        QCOMPARE(signalsSpy.count(), 0);
        QCOMPARE(submodel1Spy.count(), 2);
        QCOMPARE(submodel2Spy.count(), 0);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(model, *expected.model()));
    }

    void insertToAdjacentGroupsTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  },
                    { "name": "A", "subname": "a3"  },
                    { "name": "A", "subname": "a4"  }
                ]
            },
            {
                "name": "B", "subname": "b01",
                "submodel": [
                    { "name": "B", "subname": "b01" },
                    { "name": "B", "subname": "b02" },
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(submodel1, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel1, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, expected = expected.model()] {
            QVERIFY(isSame(m, expected));
        });
        connect(submodel2, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel2, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, expected = expected.model()] {
            QVERIFY(isSame(*m, *expected));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.insert(2, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a3" }},
            QJsonObject {{ "name", "A"}, { "subname", "a4" }},
            QJsonObject {{ "name", "B"}, { "subname", "b01" }},
            QJsonObject {{ "name", "B"}, { "subname", "b02" }}
        });

        QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(0), model.index(1));
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(1), model.index(1));
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                 { roleForName(roles, "subname") });

        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 2);
        QCOMPARE(submodel1Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 3);

        QCOMPARE(submodel1Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(1), 2);
        QCOMPARE(submodel1Spy.rowsInsertedSpy.at(0).at(2), 3);

        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 0);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 1);

        QCOMPARE(submodel2Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(1), 0);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(2), 1);

        QCOMPARE(signalsSpy.count(), 1);
        QCOMPARE(submodel1Spy.count(), 2);
        QCOMPARE(submodel2Spy.count(), 2);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(model, *expected.model()));
    }

    void insertNewGroupTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" },
                    { "name": "A", "subname": "a2" }
                ]
            },
            {
                "name": "AA", "subname": "aa1",
                "submodel": [
                    { "name": "AA", "subname": "aa1" },
                    { "name": "AA", "subname": "aa2" }
                ]
            },
            {
                "name": "AB", "subname": "ab1",
                "submodel": [
                    { "name": "AB", "subname": "ab1" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(&model, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });

        connect(&model, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, expected = expected.model()] {
            QVERIFY(isSame(m, expected));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.insert(2, QJsonArray {
            QJsonObject {{ "name", "AA"}, { "subname", "aa1" }},
            QJsonObject {{ "name", "AA"}, { "subname", "aa2" }},
            QJsonObject {{ "name", "AB"}, { "subname", "ab1" }}
        });

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(1), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(2), 2);

        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(1), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(2), 2);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 0);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(model, *expected.model()));
    }

    void insertToEmptyModelTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine);

        GroupingModel model;
        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 0);

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" },
                    { "name": "A", "subname": "a2" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            }
        ])");

        QObject context;
        connect(&model, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model] {
            QCOMPARE(m->rowCount(), 0);
        });

        connect(&model, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, expected = expected.model()] {
            QVERIFY(isSame(*m, *expected));
        });

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.append(QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }}
        });

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(1), 0);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(2), 1);

        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(1), 0);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(2), 1);

        QCOMPARE(signalsSpy.count(), 2);
        QVERIFY(isSame(model, *expected.model()));
    }

    void insertNewGroupAndSplitTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            },
            {
                "name": "B", "subname": "b2",
                "submodel": [
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(submodel2, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel2, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.insert(3, QJsonArray {
            QJsonObject {{ "name", "D"}, { "subname", "d1" }}
        });

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(1), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(2), 3);

        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(1), 2);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(2), 3);

        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.at(0).at(1), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.at(0).at(2), 1);

        QCOMPARE(submodel2Spy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsRemovedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsRemovedSpy.at(0).at(1), 1);
        QCOMPARE(submodel2Spy.rowsRemovedSpy.at(0).at(2), 1);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 2);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(model, *expected.model()));
    }

    void insertToGroupAndSplitTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b11" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            },
            {
                "name": "B", "subname": "b12",
                "submodel": [
                    { "name": "B", "subname": "b12" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(submodel2, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel2, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel2, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel2, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.insert(3, QJsonArray {
            QJsonObject {{ "name", "B"}, { "subname", "b11" }},
            QJsonObject {{ "name", "D"}, { "subname", "d1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b12" }}
        });

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(1), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(2), 3);

        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(1), 2);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(2), 3);

        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.at(0).at(1), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.at(0).at(2), 1);

        QCOMPARE(submodel2Spy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsRemovedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsRemovedSpy.at(0).at(1), 1);
        QCOMPARE(submodel2Spy.rowsRemovedSpy.at(0).at(2), 1);

        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel2Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 1);

        QCOMPARE(submodel2Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel2Spy.rowsInsertedSpy.at(0).at(2), 1);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 4);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(model, *expected.model()));
    }

    void insertAtEndTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel.model());

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        auto submodel1 = model.data(model.index(0, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel2 = model.data(model.index(1, 0), submodelRole)
                .value<QAbstractItemModel*>();
        auto submodel3 = model.data(model.index(2, 0), submodelRole)
                .value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b2" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" },
                    { "name": "C", "subname": "c2" },
                    { "name": "C", "subname": "c3" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            },
            {
                "name": "E", "subname": "e1",
                "submodel": [
                    { "name": "E", "subname": "e1" }
                ]
            }
        ])");

        QObject context;
        connect(submodel3, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel3, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(&model, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.append(QJsonArray {
            QJsonObject {{ "name", "C"}, { "subname", "c2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c3" }},
            QJsonObject {{ "name", "D"}, { "subname", "d1" }},
            QJsonObject {{ "name", "E"}, { "subname", "e1" }}
        });

        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(1), 3);
        QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(2), 4);

        QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(1), 3);
        QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(2), 4);

        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 2);

        QCOMPARE(submodel3Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsInsertedSpy.at(0).at(0), InvalidIdx);
        QCOMPARE(submodel3Spy.rowsInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel3Spy.rowsInsertedSpy.at(0).at(2), 2);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 0);
        QCOMPARE(submodel3Spy.count(), 2);

        QVERIFY(isSame(model, *expected.model()));
    }

    void removeFromBeginingTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }}, // to be removed
            QJsonObject {{ "name", "A"}, { "subname", "a2" }}, // to be removed
            QJsonObject {{ "name", "B"}, { "subname", "b1" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c2" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c3" }},
            QJsonObject {{ "name", "D"}, { "subname", "d1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        QCOMPARE(model.rowCount(), 4);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        QPointer<QAbstractItemModel> submodel1
                = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel2
                = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel3
                = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel4
                = model.data(model.index(3, 0), submodelRole).value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "C", "subname": "c3",
                "submodel": [
                    { "name": "C", "subname": "c3" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  },
                    { "name": "A", "subname": "a2"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c3",
                "submodel": [
                    { "name": "C", "subname": "c3" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            }
        ])");

        QVERIFY(isSame(model, snapshot));

        QObject context;
        connect(submodel3, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel3, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);
        ModelSignalsSpy submodel4Spy(submodel4);

        sourceModel.remove(0, 5);
        QCOMPARE(sourceModel.count(), 2);

        QVERIFY(submodel1.isNull());
        QVERIFY(submodel2.isNull());
        QVERIFY(!submodel3.isNull());
        QVERIFY(!submodel4.isNull());

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 0);
        QCOMPARE(submodel3Spy.count(), 2);
        QCOMPARE(submodel3Spy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel4Spy.count(), 0);

        QVERIFY(isSame(&model, expected));
    }

    void removeSingleInTheMiddleTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "B"}, { "subname", "b2" }}, // to be removed
            QJsonObject {{ "name", "B"}, { "subname", "b3" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        QPointer<QAbstractItemModel> submodel1
                = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel2
                = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel3
                = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" },
                    { "name": "B", "subname": "b3" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QVERIFY(isSame(model, snapshot));

        QObject context;
        connect(submodel2, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel2, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);

        sourceModel.remove(2, 1);
        QCOMPARE(model.rowCount(), 3);

        QVERIFY(!submodel1.isNull());
        QVERIFY(!submodel2.isNull());
        QVERIFY(!submodel3.isNull());

        QCOMPARE(signalsSpy.count(), 0);
        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 2);
        QCOMPARE(submodel2Spy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(submodel2Spy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel3Spy.count(), 0);

        QVERIFY(isSame(&model, expected));
    }

    void removeGroupInTheMiddleTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }}, // to be removed
            QJsonObject {{ "name", "B"}, { "subname", "b1" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c2" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c3" }},
            QJsonObject {{ "name", "D"}, { "subname", "d1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        QCOMPARE(model.rowCount(), 4);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        QPointer<QAbstractItemModel> submodel1
                = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel2
                = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel3
                = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel4
                = model.data(model.index(3, 0), submodelRole).value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" }
                ]
            },
            {
                "name": "C", "subname": "c3",
                "submodel": [
                    { "name": "C", "subname": "c3" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate1(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" },
                    { "name": "C", "subname": "c2" },
                    { "name": "C", "subname": "c3" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate2(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1"  }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c3",
                "submodel": [
                    { "name": "C", "subname": "c3" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            }
        ])");

        QVERIFY(isSame(model, snapshot));

        QObject context;
        connect(submodel1, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel1, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate1.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel3, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, e = expectedIntermediate1.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel3, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate2.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, e = expectedIntermediate2.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);
        ModelSignalsSpy submodel4Spy(submodel4);

        sourceModel.remove(1, 4);
        QCOMPARE(sourceModel.count(), 3);

        QVERIFY(!submodel1.isNull());
        QVERIFY(submodel2.isNull());
        QVERIFY(!submodel3.isNull());
        QVERIFY(!submodel4.isNull());

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel1Spy.count(), 2);
        QCOMPARE(submodel1Spy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(submodel1Spy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel2Spy.count(), 0);
        QCOMPARE(submodel3Spy.count(), 2);
        QCOMPARE(submodel3Spy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel4Spy.count(), 0);

        QVERIFY(isSame(&model, expected));
    }

    void removeAllTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c2" }},
            QJsonObject {{ "name", "C"}, { "subname", "c3" }},
            QJsonObject {{ "name", "D"}, { "subname", "d1" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        QCOMPARE(model.rowCount(), 4);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        auto submodelRole = roleForName(roles, "submodel");

        QPointer<QAbstractItemModel> submodel1
                = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel2
                = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel3
                = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel4
                = model.data(model.index(3, 0), submodelRole).value<QAbstractItemModel*>();

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.remove(0, 7);
        QCOMPARE(sourceModel.count(), 0);

        QVERIFY(submodel1.isNull());
        QVERIFY(submodel2.isNull());
        QVERIFY(submodel3.isNull());
        QVERIFY(submodel4.isNull());

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);
    }

    void removeManyAndMergeTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c2" }}, // to be removed
            QJsonObject {{ "name", "D"}, { "subname", "d1" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c3" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c4" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        QCOMPARE(model.rowCount(), 5);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        QPointer<QAbstractItemModel> submodel1
                = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel2
                = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel3
                = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel4
                = model.data(model.index(3, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel5
                = model.data(model.index(4, 0), submodelRole).value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" },
                    { "name": "A", "subname": "a2" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" },
                    { "name": "C", "subname": "c4" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate1(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" },
                    { "name": "A", "subname": "a2" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            },
            {
                "name": "D", "subname": "d1",
                "submodel": [
                    { "name": "D", "subname": "d1" }
                ]
            },
            {
                "name": "C", "subname": "c3",
                "submodel": [
                    { "name": "C", "subname": "c3" },
                    { "name": "C", "subname": "c4" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate2(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" },
                    { "name": "A", "subname": "a2" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" },
                ]
            }
        ])");

        QObject context;
        connect(submodel3, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(submodel3, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate1.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, e = expectedIntermediate1.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(&model, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate2.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel3, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, e = expectedIntermediate2.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel3, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);
        ModelSignalsSpy submodel4Spy(submodel4);
        ModelSignalsSpy submodel5Spy(submodel5);

        sourceModel.remove(4, 3);

        QCOMPARE(model.rowCount(), 3);

        QVERIFY(!submodel1.isNull());
        QVERIFY(!submodel2.isNull());
        QVERIFY(!submodel3.isNull());
        QVERIFY(submodel4.isNull());
        QVERIFY(submodel5.isNull());

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(1), 3);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(2), 4);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);

        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 0);

        QCOMPARE(submodel3Spy.count(), 4);
        QCOMPARE(submodel3Spy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeRemovedSpy.at(0).at(1), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeRemovedSpy.at(0).at(2), 1);
        QCOMPARE(submodel3Spy.rowsRemovedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 1);
        QCOMPARE(submodel3Spy.rowsInsertedSpy.count(), 1);

        QCOMPARE(submodel4Spy.count(), 0);
        QCOMPARE(submodel5Spy.count(), 0);

        QVERIFY(isSame(&model, expected));
    }

    void removeSingleAndMergeTest()
    {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }},
            QJsonObject {{ "name", "D"}, { "subname", "d1" }}, // to be removed
            QJsonObject {{ "name", "C"}, { "subname", "c2" }}
        });

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        QCOMPARE(model.rowCount(), 5);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        SnapshotModel snapshot(model);

        auto submodelRole = roleForName(roles, "submodel");

        QPointer<QAbstractItemModel> submodel1
                = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel2
                = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel3
                = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel4
                = model.data(model.index(3, 0), submodelRole).value<QAbstractItemModel*>();
        QPointer<QAbstractItemModel> submodel5
                = model.data(model.index(4, 0), submodelRole).value<QAbstractItemModel*>();

        ListModelWrapper expected(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" },
                    { "name": "A", "subname": "a2" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" },
                    { "name": "C", "subname": "c2" }
                ]
            }
        ])");

        ListModelWrapper expectedIntermediate(engine, R"([
            {
                "name": "A", "subname": "a1",
                "submodel": [
                    { "name": "A", "subname": "a1" },
                    { "name": "A", "subname": "a2" }
                ]
            },
            {
                "name": "B", "subname": "b1",
                "submodel": [
                    { "name": "B", "subname": "b1" }
                ]
            },
            {
                "name": "C", "subname": "c1",
                "submodel": [
                    { "name": "C", "subname": "c1" }
                ]
            }
        ])");

        QObject context;
        connect(&model, &QAbstractItemModel::rowsAboutToBeRemoved, &context,
                [m = &model, s = &snapshot] {
            QVERIFY(isSame(m, s));
        });
        connect(&model, &QAbstractItemModel::rowsRemoved, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel3, &QAbstractItemModel::rowsAboutToBeInserted, &context,
                [m = &model, e = expectedIntermediate.model()] {
            QVERIFY(isSame(m, e));
        });
        connect(submodel3, &QAbstractItemModel::rowsInserted, &context,
                [m = &model, e = expected.model()] {
            QVERIFY(isSame(m, e));
        });

        ModelSignalsSpy signalsSpy(&model);
        ModelSignalsSpy submodel1Spy(submodel1);
        ModelSignalsSpy submodel2Spy(submodel2);
        ModelSignalsSpy submodel3Spy(submodel3);
        ModelSignalsSpy submodel4Spy(submodel4);
        ModelSignalsSpy submodel5Spy(submodel5);

        sourceModel.remove(4, 1);

        QCOMPARE(model.rowCount(), 3);

        QVERIFY(!submodel1.isNull());
        QVERIFY(!submodel2.isNull());
        QVERIFY(!submodel3.isNull());
        QVERIFY(submodel4.isNull());
        QVERIFY(submodel5.isNull());

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(1), 3);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(2), 4);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);

        QCOMPARE(submodel1Spy.count(), 0);
        QCOMPARE(submodel2Spy.count(), 0);

        QCOMPARE(submodel3Spy.count(), 2);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.at(0).at(1), 1);
        QCOMPARE(submodel3Spy.rowsAboutToBeInsertedSpy.at(0).at(2), 1);
        QCOMPARE(submodel3Spy.rowsInsertedSpy.count(), 1);
        QCOMPARE(submodel4Spy.count(), 0);
        QCOMPARE(submodel5Spy.count(), 0);

        QVERIFY(isSame(&model, expected));
    }

    void submodelsDeletionOnDestructionTest() {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        QPointer<QAbstractItemModel> submodel1, submodel2, submodel3;

        {
            GroupingModel model;

            model.setGroupingRoleName("name");
            model.setSourceModel(sourceModel);

            QCOMPARE(model.rowCount(), 3);

            auto roles = model.roleNames();
            auto submodelRole = roleForName(roles, "submodel");

            submodel1 = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
            submodel2 = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
            submodel3 = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();

            QVERIFY(!submodel1.isNull());
            QVERIFY(!submodel2.isNull());
            QVERIFY(!submodel3.isNull());
        }

        QVERIFY(submodel1.isNull());
        QVERIFY(submodel2.isNull());
        QVERIFY(submodel3.isNull());
    }

    void submodelsDeletionOnResetTest() {
        QQmlEngine engine;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        QPointer<QAbstractItemModel> submodel1, submodel2, submodel3;

        GroupingModel model;

        model.setGroupingRoleName("name");
        model.setSourceModel(sourceModel);

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        auto submodelRole = roleForName(roles, "submodel");

        submodel1 = model.data(model.index(0, 0), submodelRole).value<QAbstractItemModel*>();
        submodel2 = model.data(model.index(1, 0), submodelRole).value<QAbstractItemModel*>();
        submodel3 = model.data(model.index(2, 0), submodelRole).value<QAbstractItemModel*>();

        QVERIFY(!submodel1.isNull());
        QVERIFY(!submodel2.isNull());
        QVERIFY(!submodel3.isNull());

        model.setSourceModel(nullptr);

        QVERIFY(submodel1.isNull());
        QVERIFY(submodel2.isNull());
        QVERIFY(submodel3.isNull());

        QCOMPARE(model.rowCount(), 0);
    }

    void submodelResetTest() {
        QQmlEngine engine;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "subname", "a1" }},
            QJsonObject {{ "name", "A"}, { "subname", "a2" }},
            QJsonObject {{ "name", "B"}, { "subname", "b1" }},
            QJsonObject {{ "name", "C"}, { "subname", "c1" }}
        });

        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "name", "A"}, { "other", "a1" }},
            QJsonObject {{ "name", "A"}, { "other", "a2" }},
            QJsonObject {{ "name", "B"}, { "other", "b1" }},
            QJsonObject {{ "name", "C"}, { "other", "c1" }},
            QJsonObject {{ "name", "C"}, { "other", "c2" }},
            QJsonObject {{ "name", "D"}, { "other", "d1" }}
        });

        auto contains = [](auto roles, auto name) {
            return std::find(roles.cbegin(), roles.cend(), name) != roles.cend();
        };

        QIdentityProxyModel identity;
        identity.setSourceModel(sourceModel1);

        GroupingModel model;
        model.setGroupingRoleName("name");
        model.setSourceModel(&identity);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "subname"));
            QVERIFY(contains(roles, "submodel"));
        }

        QCOMPARE(model.rowCount(), 3);

        ModelSignalsSpy signalsSpy(&model);
        identity.setSourceModel(sourceModel2);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 3);
            QVERIFY(contains(roles, "name"));
            QVERIFY(contains(roles, "other"));
            QVERIFY(contains(roles, "submodel"));
        }

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy.modelResetSpy.count(), 1);

        QCOMPARE(model.rowCount(), 4);

        identity.setSourceModel(nullptr);

        {
            const auto roles = model.roleNames();
            QCOMPARE(roles.size(), 0);
        }

        QCOMPARE(signalsSpy.count(), 4);
        QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 2);
        QCOMPARE(signalsSpy.modelResetSpy.count(), 2);

        QCOMPARE(model.rowCount(), 0);

        model.setSourceModel(nullptr);

        ModelSignalsSpy signalsSpy2(&model);
        identity.setSourceModel(sourceModel2);
        QCOMPARE(signalsSpy2.count(), 0);
    }
};

QTEST_MAIN(TestGroupingModel)
#include "tst_GroupingModel.moc"
