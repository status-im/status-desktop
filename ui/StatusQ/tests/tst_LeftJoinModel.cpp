#include <QAbstractItemModelTester>
#include <QSignalSpy>
#include <QTest>

#include <memory>

#include <StatusQ/leftjoinmodel.h>

#include <TestHelpers/persistentindexestester.h>
#include <TestHelpers/testmodel.h>

class TestLeftJoinModel: public QObject
{
    Q_OBJECT

private slots:

    void emptyModelTest() {
        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
    }

    void initializationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        model.setRightModel(&rightModel);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        model.setJoinRole("communityId");

        QCOMPARE(model.rowCount(), 2);

        QHash<int, QByteArray> roles{{0, "title" }, {1, "communityId"}, {2, "name"}};
        QCOMPARE(model.roleNames(), roles);
    }

    void collidingRolesTest()
    {
        TestModel leftModel({
           { "name", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        model.setRightModel(&rightModel);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        QTest::ignoreMessage(QtWarningMsg,
                             "Source models contain conflicting model names: "
                             "\"name\"!");

        model.setJoinRole("communityId");

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
    }

    void duplicatedRolesTest()
    {
        {
            TestModel leftModel({
               { "name", { "Token 1", "Token 2" }},
               { "name", { "Token 1", "Token 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            TestModel rightModel({
               { "title", { "Community 1", "Community 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            LeftJoinModel model;
            QAbstractItemModelTester tester(&model);

            model.setLeftModel(&leftModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            model.setRightModel(&rightModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            QTest::ignoreMessage(QtWarningMsg,
                                 "Each of the source models must have unique "
                                 "role names!");

            model.setJoinRole("communityId");

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
        {
            TestModel leftModel({
               { "name", { "Token 1", "Token 2" }},
               { "communityId", { "community_1", "community_2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            TestModel rightModel({
               { "title", { "Community 1", "Community 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            LeftJoinModel model;
            QAbstractItemModelTester tester(&model);

            model.setLeftModel(&leftModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            model.setRightModel(&rightModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            QTest::ignoreMessage(QtWarningMsg,
                                 "Each of the source models must have unique "
                                 "role names!");

            model.setJoinRole("communityId");

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
        {
            TestModel leftModel({
               { "name", { "Token 1", "Token 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            TestModel rightModel({
               { "title", { "Community 1", "Community 2" }},
               { "title", { "Community 1", "Community 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            LeftJoinModel model;
            QAbstractItemModelTester tester(&model);

            model.setLeftModel(&leftModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            model.setRightModel(&rightModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            QTest::ignoreMessage(QtWarningMsg,
                                 "Each of the source models must have unique "
                                 "role names!");

            model.setJoinRole("communityId");

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
    }

    void noJoinRoleTest()
    {
        {
            TestModel leftModel({
               { "title", { "Token 1", "Token 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            TestModel rightModel({
               { "name", { "Community 1", "Community 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            LeftJoinModel model;
            QAbstractItemModelTester tester(&model);

            model.setLeftModel(&leftModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            model.setRightModel(&rightModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            QTest::ignoreMessage(QtWarningMsg,
                                 "Both left and right models have to contain "
                                 "join role someRole!");

            model.setJoinRole("someRole");

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
        {
            TestModel leftModel({
               { "title", { "Token 1", "Token 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            TestModel rightModel({
               { "name", { "Community 1", "Community 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            LeftJoinModel model;
            QAbstractItemModelTester tester(&model);

            model.setLeftModel(&leftModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            model.setRightModel(&rightModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            QTest::ignoreMessage(QtWarningMsg,
                                 "Both left and right models have to contain "
                                 "join role title!");

            model.setJoinRole("title");

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
        {
            TestModel leftModel({
               { "title", { "Token 1", "Token 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            TestModel rightModel({
               { "name", { "Community 1", "Community 2" }},
               { "communityId", { "community_1", "community_2" }}
            });

            LeftJoinModel model;
            QAbstractItemModelTester tester(&model);

            model.setLeftModel(&leftModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            model.setRightModel(&rightModel);

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});

            QTest::ignoreMessage(QtWarningMsg,
                                 "Both left and right models have to contain "
                                 "join role name!");

            model.setJoinRole("name");

            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
    }

    void basicAccesTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "color", { "red", "blue" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        QCOMPARE(model.data(model.index(0, 0), 3), QString("red"));
        QCOMPARE(model.data(model.index(1, 0), 3), QString("blue"));
    }

    void changesPropagationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }},
           { "color", { "red", "green" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        {
            QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

            rightModel.update(0, 0, "Community 1 Updated");
            QCOMPARE(dataChangedSpy.count(), 1);

            QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
            QCOMPARE(dataChangedSpy.first().at(1), model.index(model.rowCount() - 1, 0));
            QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), {2});

            QCOMPARE(model.rowCount(), 2);
            QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
            QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
            QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
            QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
            QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1 Updated"));
            QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        }
        {
            QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

            leftModel.update(1, 0, "Token 2 Updated");
            QCOMPARE(dataChangedSpy.count(), 1);

            QCOMPARE(dataChangedSpy.first().at(0), model.index(1, 0));
            QCOMPARE(dataChangedSpy.first().at(1), model.index(1, 0));
            QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), {0});

            QCOMPARE(model.rowCount(), 2);
            QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
            QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2 Updated"));
            QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
            QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
            QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1 Updated"));
            QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        }
    }

    // TODO: cover also move
    void insertRemovePropagationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }},
           { "color", { "red", "green" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        QSignalSpy rowsInsertedSpy(&model, &LeftJoinModel::rowsInserted);
        QSignalSpy rowsRemovedSpy(&model, &LeftJoinModel::rowsRemoved);

        leftModel.insert(1, {"Token 1_1", "community_2"});

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 1_1"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community 2"));

        leftModel.remove(1);

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));

        QCOMPARE(rowsInsertedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.first().at(0), QModelIndex{});
        QCOMPARE(rowsInsertedSpy.first().at(1), 1);
        QCOMPARE(rowsInsertedSpy.first().at(2), 1);

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.first().at(0), QModelIndex{});
        QCOMPARE(rowsRemovedSpy.first().at(1), 1);
        QCOMPARE(rowsRemovedSpy.first().at(2), 1);
    }

    void layoutChangePropagationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }},
           { "color", { "red", "green" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        // register types to avoid warnings regarding signal params
        qRegisterMetaType<QList<QPersistentModelIndex>>();
        qRegisterMetaType<QAbstractItemModel::LayoutChangeHint>();

        QSignalSpy layoutAboutToBeChangedSpy(
                    &model, &LeftJoinModel::layoutAboutToBeChanged);
        QSignalSpy layoutChangedSpy(&model, &LeftJoinModel::layoutChanged);
        QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

        PersistentIndexesTester indexesTester(&model);
        leftModel.invert();

        QCOMPARE(layoutAboutToBeChangedSpy.count(), 1);
        QCOMPARE(layoutChangedSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 0);

        QVERIFY(indexesTester.compare());

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 2"));

        rightModel.invert();

        QCOMPARE(layoutAboutToBeChangedSpy.count(), 1);
        QCOMPARE(layoutChangedSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 0);

        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 2"));
    }


    void rightModelJoinRoleChangesPropagationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

        rightModel.update(1, 1, "community_3");
        QCOMPARE(dataChangedSpy.count(), 1);

        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(model.rowCount() - 1, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), {2});

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), {});
    }

    void rightModelRemovalPropagationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

        rightModel.remove(1);
        QCOMPARE(dataChangedSpy.count(), 1);

        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(model.rowCount() - 1, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), {2});

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), {});
    }

    void rightModelAdditionPropagationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_3" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

        rightModel.insert(2, {"Community 3", "community_3"});
        QCOMPARE(dataChangedSpy.count(), 1);

        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(model.rowCount() - 1, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), {2});

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_3"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community 3"));
    }

    void leftModelJoinRoleChangesPropagationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);
        model.setJoinRole("communityId");

        QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

        leftModel.update(1, 1, "community_1");
        QCOMPARE(dataChangedSpy.count(), 1);

        QCOMPARE(dataChangedSpy.first().at(0), model.index(1, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(1, 0));

        auto changedRoles = dataChangedSpy.first().at(2).value<QVector<int>>();
        QVERIFY(changedRoles.contains(1));
        QVERIFY(changedRoles.contains(2));

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community 1"));
    }

    void modelsDeletedBeforeInitializationTest()
    {
        auto leftModel = std::make_unique<TestModel>(
            QList<QPair<QString, QVariantList>>{
                { "title", { "Token 1", "Token 2", "Token 3"}},
                { "communityId", { "community_1", "community_2", "community_1" }}
            });

        auto rightModel = std::make_unique<TestModel>(
            QList<QPair<QString, QVariantList>>{
                { "name", { "Community 1", "Community 2" }},
                { "communityId", { "community_1", "community_2" }}
            });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        QSignalSpy modelResetSpy(&model, &LeftJoinModel::modelReset);

        model.setLeftModel(leftModel.get());
        model.setRightModel(rightModel.get());

        leftModel.reset();
        rightModel.reset();

        model.setJoinRole("communityId");

        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.data(model.index(0, 0), 0), {});
        QCOMPARE(model.data(model.index(0, 0), 2), {});

        TestModel newLeftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel newRightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        model.setLeftModel(&newLeftModel);
        model.setRightModel(&newRightModel);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community 1"));

        QCOMPARE(modelResetSpy.count(), 1);
    }

    void modelsDeletedAfterInitializationTest()
    {
        auto leftModel = std::make_unique<TestModel>(
                    QList<QPair<QString, QVariantList>>{
                        { "title", { "Token 1", "Token 2", "Token 3"}},
                        { "communityId", { "community_1", "community_2", "community_1" }}
                    });

        auto rightModel = std::make_unique<TestModel>(
                    QList<QPair<QString, QVariantList>>{
                        { "name", { "Community 1", "Community 2" }},
                        { "communityId", { "community_1", "community_2" }}
                    });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        QSignalSpy modelResetSpy(&model, &LeftJoinModel::modelReset);

        model.setLeftModel(leftModel.get());
        model.setRightModel(rightModel.get());

        model.setJoinRole("communityId");

        QCOMPARE(modelResetSpy.count(), 1);

        leftModel.reset();
        rightModel.reset();

        QHash<int, QByteArray> roles{{0, "title" }, {1, "communityId"}, {2, "name"}};
        QCOMPARE(model.roleNames(), roles);
        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.data(model.index(0, 0), 0), {});
        QCOMPARE(model.data(model.index(0, 0), 2), {});

        TestModel newLeftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel newRightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        model.setLeftModel(&newLeftModel);

        QCOMPARE(modelResetSpy.count(), 2);
        QCOMPARE(model.rowCount(), 0);

        model.setRightModel(&newRightModel);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community 1"));

        QCOMPARE(modelResetSpy.count(), 3);
    }

    void rightModelDeletedAfterInitializationTest()
    {
        auto leftModel = std::make_unique<TestModel>(
                    QList<QPair<QString, QVariantList>>{
                        { "title", { "Token 1", "Token 2", "Token 3"}},
                        { "communityId", { "community_1", "community_2", "community_1" }}
                    });

        auto rightModel = std::make_unique<TestModel>(
                    QList<QPair<QString, QVariantList>>{
                        { "name", { "Community 1", "Community 2" }},
                        { "communityId", { "community_1", "community_2" }}
                    });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(leftModel.get());
        model.setRightModel(rightModel.get());

        model.setJoinRole("communityId");

        rightModel.reset();

        QHash<int, QByteArray> roles{{0, "title" }, {1, "communityId"}, {2, "name"}};
        QCOMPARE(model.roleNames(), roles);
        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(0, 0), 2), {});

        TestModel newLeftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel newRightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        model.setRightModel(&newRightModel);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community 1"));
    }

    void rightModelChangedWithSameRolesAfterInitializationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);

        model.setJoinRole("communityId");

        TestModel newRightModel({
           { "name", { "Community A", "Community B" }},
           { "communityId", { "community_1", "community_2" }}
        });

        QSignalSpy modelResetSpy(&model, &LeftJoinModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

        model.setRightModel(&newRightModel);

        QHash<int, QByteArray> roles{{0, "title" }, {1, "communityId"}, {2, "name"}};
        QCOMPARE(model.roleNames(), roles);
        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community A"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community B"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community A"));

        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 1);

        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(model.rowCount() - 1, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), {2});
    }

    void rightModelChangedWithDifferentRolesAfterInitializationTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);

        model.setJoinRole("communityId");

        TestModel newRightModel({
           { "communityId", { "community_1", "community_2" }},
           { "name", { "Community A", "Community B" }}
        });

        QSignalSpy modelResetSpy(&model, &LeftJoinModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &LeftJoinModel::dataChanged);

        model.setRightModel(&newRightModel);

        QHash<int, QByteArray> roles{{0, "title" }, {1, "communityId"}, {3, "name"}};
        QCOMPARE(model.roleNames(), roles);
        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(0, 0), 3), QString("Community A"));
        QCOMPARE(model.data(model.index(1, 0), 3), QString("Community B"));
        QCOMPARE(model.data(model.index(2, 0), 3), QString("Community A"));

        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 0);
    }

    void invalidRolesToJoinTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }},
           { "other", { "other_1", "other_1" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        QTest::ignoreMessage(
                    QtWarningMsg,
                    "Role to join notExisting not found in the right model!");

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);

        model.setRolesToJoin({ "name", "notExisting" });
        model.setJoinRole("communityId");

        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.rowCount(), 0);
    }

    void rolesToJoinTest()
    {
        TestModel leftModel({
           { "title", { "Token 1", "Token 2", "Token 3"}},
           { "communityId", { "community_1", "community_2", "community_1" }}
        });

        TestModel rightModel({
           { "name", { "Community 1", "Community 2" }},
           { "communityId", { "community_1", "community_2" }},
           { "other", { "other_1", "other_1" }}
        });

        LeftJoinModel model;
        QAbstractItemModelTester tester(&model);

        model.setLeftModel(&leftModel);
        model.setRightModel(&rightModel);

        model.setRolesToJoin({ "name" });
        model.setJoinRole("communityId");

        QHash<int, QByteArray> roles{{0, "title" }, {1, "communityId"}, {2, "name"}};

        QCOMPARE(model.roleNames(), roles);
        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QString("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QString("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QString("Token 3"));
        QCOMPARE(model.data(model.index(0, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QString("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QString("community_1"));
        QCOMPARE(model.data(model.index(0, 0), 2), QString("Community 1"));
        QCOMPARE(model.data(model.index(1, 0), 2), QString("Community 2"));
        QCOMPARE(model.data(model.index(2, 0), 2), QString("Community 1"));
    }
};

QTEST_MAIN(TestLeftJoinModel)
#include "tst_LeftJoinModel.moc"
