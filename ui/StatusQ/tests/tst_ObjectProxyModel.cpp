#include <QSignalSpy>
#include <QTest>

#include <QJsonArray>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>

#include <memory>
#include <string>

#include <StatusQ/objectproxymodel.h>

#include <TestHelpers/listmodelwrapper.h>
#include <TestHelpers/modelsignalsspy.h>
#include <TestHelpers/modeltestutils.h>

class TestObjectProxyModel: public QObject
{
    Q_OBJECT

    int roleForName(const QHash<int, QByteArray>& roles, const QByteArray& name) const
    {
        auto keys = roles.keys(name);

        if (keys.empty())
            return -1;

        return keys.first();
    }

private slots:
    void basicTest() {
        QQmlEngine engine;
        QQmlComponent delegate(&engine);

        auto delegateData = R"(
            import QtQml 2.15
            QtObject {
                readonly property int count: model.balances.count
                readonly property QtObject proxyObject: this
            }
        )";

        delegate.setData(delegateData, QUrl());

        ObjectProxyModel model;

        auto source = R"([
            { balances: [ { balance: 4 } ], name: "name 1" },
            { balances: [ { balance: 4 }, {balance: 43} ], name: "name 2" },
            { balances: [], name: "name 3" }
        ])";

        ListModelWrapper sourceModel(engine, source);

        QSignalSpy sourceModelChangedSpy(
                    &model, &ObjectProxyModel::sourceModelChanged);
        QSignalSpy delegateChangedSpy(
                    &model, &ObjectProxyModel::delegateChanged);
        QSignalSpy expectedRolesChangedSpy(
                    &model, &ObjectProxyModel::expectedRolesChanged);
        QSignalSpy exposedRolesChangedSpy(
                    &model, &ObjectProxyModel::exposedRolesChanged);

        model.setSourceModel(sourceModel);
        model.setDelegate(&delegate);
        model.setExpectedRoles(QStringList({ QStringLiteral("balances") }));
        model.setExposedRoles({ QStringLiteral("proxyObject"),
                                QStringLiteral("count")});

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(delegateChangedSpy.count(), 1);
        QCOMPARE(expectedRolesChangedSpy.count(), 1);

        QCOMPARE(model.sourceModel(), sourceModel);
        QCOMPARE(model.delegate(), &delegate);
        QCOMPARE(model.expectedRoles(), QStringList({ QStringLiteral("balances") }));
        QCOMPARE(model.exposedRoles(), QStringList({ QStringLiteral("proxyObject"),
                                                     QStringLiteral("count") }));

        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.data(model.index(0, 0), sourceModel.role("name")), "name 1");
        QVERIFY(model.data(model.index(0, 0),
                           sourceModel.role("balances")).isValid());

        auto roles = model.roleNames();

        auto object = model.data(model.index(0, 0),
                                 roleForName(roles, "proxyObject")).value<QObject*>();
        QVERIFY(object);
        QCOMPARE(object->property("count"), 1);
        QCOMPARE(QQmlEngine::objectOwnership(object),
                 QQmlEngine::CppOwnership);
    }

    void submodelTypeTest() {
        QQmlEngine engine;
        QQmlComponent delegate(&engine);

        auto delegateData = R"(
            import QtQml 2.15
            QtObject {
                property var count: model.balances.count
            }
        )";

        delegate.setData(delegateData, QUrl());

        ObjectProxyModel model;

        auto source = R"([
            { balances: [ { balance: 4 } ], name: "name 1" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        model.setSourceModel(sourceModel);
        model.setDelegate(&delegate);
        model.setExpectedRoles({ QStringLiteral("balances") });

        QCOMPARE(model.rowCount(), 1);

        QVariant balances1 = model.data(model.index(0, 0),
                                       sourceModel.role("balances"));
        QVERIFY(balances1.isValid());

        QVariant balances2 = model.data(model.index(0, 0),
                                       sourceModel.role("balances"));
        QVERIFY(balances2.isValid());

        // ObjectProxyModel may create proxy objects on demand, then first
        // call to data(...) returns freshly created object, the next calls
        // related to the same row should return cached object. It's important
        // to have QVariant type identical in both cases. E.g. returning raw
        // pointer in first call and pointer wrapped into QPointer in the next
        // one leads to problems in UI components in some scenarios even if
        // those QVariant types are automatically convertible.
        QCOMPARE(balances2.type(), balances1.type());

        // Check if the same instance is returned.
        QCOMPARE(balances2.value<QObject*>(), balances1.value<QObject*>());
    }

    void signalsDisconnectionTest() {
        struct Model : public QIdentityProxyModel
        {
            using QObject::receivers;
        };

        Model sourceModel1, sourceModel2;
        ObjectProxyModel model;

        auto signal = SIGNAL(dataChanged(const QModelIndex&,
                                         const QModelIndex&,
                                         const QVector<int>));

        model.setSourceModel(&sourceModel1);
        QVERIFY(sourceModel1.receivers(signal) > 0);

        model.setSourceModel(nullptr);
        QVERIFY(sourceModel1.receivers(signal) == 0);

        model.setSourceModel(&sourceModel1);
        QVERIFY(sourceModel1.receivers(signal) > 0);

        model.setSourceModel(&sourceModel2);
        QVERIFY(sourceModel1.receivers(signal) == 0);
    }

    void deletingDelegateTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml 2.15

            QtObject {
                property var sub: model.balances
            }
        )"), QUrl());

        ObjectProxyModel model;
        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "balances", 11 }, { "name", "name 1" }},
            QJsonObject {{ "balances", 12 }, { "name", "name 2" }},
            QJsonObject {{ "balances", 123}, { "name", "name 3" }}
        });

        model.setSourceModel(sourceModel);
        model.setDelegate(delegate.get());
        model.setExpectedRoles({ QStringLiteral("balances") });

        QSignalSpy delegateChangedSpy(&model,
                                      &ObjectProxyModel::delegateChanged);
        QSignalSpy dataChangedSpy(
                    &model, &ObjectProxyModel::dataChanged);

        delegate.reset();

        QCOMPARE(delegateChangedSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 0);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0),
                            sourceModel.role("balances")), 11);
    }

    void deletingSourceModelTest() {
        QQmlEngine engine;
        QQmlComponent delegate(&engine);

        delegate.setData(QByteArrayLiteral(R"(
            import QtQml 2.15

            QtObject {
                property var sub: model.balances
            }
        )"), QUrl());

        ObjectProxyModel model;

        auto sourceModel = std::make_unique<ListModelWrapper>(engine,
            QJsonArray {
                QJsonObject {{ "balances", 11 }, { "name", "name 1" }},
                QJsonObject {{ "balances", 12 }, { "name", "name 2" }},
                QJsonObject {{ "balances", 123}, { "name", "name 3" }}
            }
        );

        model.setSourceModel(sourceModel->model());
        model.setDelegate(&delegate);
        model.setExpectedRoles({ QStringLiteral("balances") });

        sourceModel.reset();

        QCOMPARE(model.rowCount(), 0);

        QTest::ignoreMessage(QtWarningMsg, QRegularExpression(".*"));
        QCOMPARE(model.data(model.index(0, 0), 0), {});
    }

    void settingUndefinedExposedRoleNameTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml 2.15

            QtObject {
                property var sub: model.balances
            }
        )"), QUrl());

        ObjectProxyModel model;
        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "balances", 11 }, { "name", "name 1" }},
            QJsonObject {{ "balances", 12 }, { "name", "name 2" }},
            QJsonObject {{ "balances", 123}, { "name", "name 3" }}
        });

        model.setSourceModel(sourceModel);
        model.setDelegate(delegate.get());

        const auto expRoleName = QStringLiteral("undefined");
        QTest::ignoreMessage(QtWarningMsg,
                             QRegularExpression(QStringLiteral(".*findExpectedRoles*.")));
        QTest::ignoreMessage(QtWarningMsg, QStringLiteral("Expected role \"%1\" not found!").arg(expRoleName).toLatin1());

        model.setExpectedRoles({ expRoleName });

        QCOMPARE(model.rowCount(), 3);
    }

    void addingNewRoleToTopLevelModelTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                property int extraValue: model.balances.count
            }
        )"), QUrl());

        ObjectProxyModel model;

        ListModelWrapper sourceModel(engine, R"([
            { "balances": [], "name": "name 1" },
            { "balances": [ { balance: 1 } ], "name": "name 2" },
            { "balances": [], "name": "name 3" }
        ])");

        model.setSourceModel(sourceModel);
        model.setDelegate(delegate.get());

        model.setExpectedRoles({ QStringLiteral("balances") });
        model.setExposedRoles({ QStringLiteral("extraValue") });

        ListModelWrapper expected(engine, R"([
            { "balances": [], "name": "name 1", "extraValue": 0 },
            { "balances": [{ balance: 1 }], "name": "name 2", "extraValue": 1 },
            { "balances": [], "name": "name 3", "extraValue": 0 }
        ])");

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);
        QVERIFY(isSame(&model, expected));

        ModelSignalsSpy signalsSpy(&model);

        QObject* proxy = model.proxyObject(0);
        proxy->setProperty("extraValue", 42);

        ListModelWrapper expected2(engine, R"([
            { "balances": [], "name": "name 1", "extraValue": 42 },
            { "balances": [{ balance: 1 }], "name": "name 2", "extraValue": 1 },
            { "balances": [], "name": "name 3", "extraValue": 0 }
        ])");

        // dataChanged signal emission is scheduled to event loop, not called
        // immediately
        QCOMPARE(signalsSpy.count(), 0);

        QVERIFY(QTest::qWaitFor([&signalsSpy]() {
           return signalsSpy.count() == 1;
        }));

        QCOMPARE(signalsSpy.count(), 1);
        QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);

        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(0), model.index(0, 0));
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(1),
                 model.index(model.rowCount() - 1, 0));

        QVector<int> expectedChangedRoles = { roleForName(roles, "extraValue") };
        QCOMPARE(signalsSpy.dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                 expectedChangedRoles);

        QVERIFY(isSame(&model, expected2));
    }

    void additionalRoleDataChangedWhenEmptyTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                property int extraValue: 0
            }
        )"), QUrl());

        ListModelWrapper sourceModel(engine, R"([
            { "balances": [], "name": "name 1" }
        ])");

        ObjectProxyModel model;
        model.setSourceModel(sourceModel);
        model.setDelegate(delegate.get());
        model.setExpectedRoles({ QStringLiteral("balances") });
        model.setExposedRoles({ QStringLiteral("extraValue") });

        QCOMPARE(model.rowCount(), 1);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        ModelSignalsSpy signalsSpy(&model);

        QObject* proxy = model.proxyObject(0);

        // dataChanged signal emission is scheduled to event loop, not called
        // immediately. In the meantime the source may be cleared and then no
        // dataChanged event should be emited.
        proxy->setProperty("extraValue", 42);

        sourceModel.remove(0);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);

        QEventLoop().processEvents();
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        QCOMPARE(signalsSpy.count(), 2);
#else
        QCOMPARE(signalsSpy.count(), 3);
        QCOMPARE(signalsSpy.headerDataChangedSpy.count(), 1);
#endif
    }

    void modelResetWhenRoleChangedTest() {
        QQmlEngine engine;
        auto delegateWithRole = std::make_unique<QQmlComponent>(&engine);

        delegateWithRole->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                property int extraValue: 0
            }
        )"), QUrl());

        auto delegateNoRole = std::make_unique<QQmlComponent>(&engine);

        delegateNoRole->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {}
        )"), QUrl());

        ListModelWrapper sourceModel(engine, R"([
            { "balances": [], "name": "name 1" }
        ])");

        // 1. set source
        // 2. set delegate model
        // 3. set expected role names
        // 4. set exposed role names
        {
            ObjectProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setDelegate(delegateWithRole.get());

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setExpectedRoles({ QStringLiteral("balances") });

            QCOMPARE(signalsSpy.count(), 4);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 2);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 2);
            QCOMPARE(model.roleNames().count(), 2);


            model.setExposedRoles({ QStringLiteral("extraValue") });

            QCOMPARE(signalsSpy.count(), 6);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 3);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 3);
            QCOMPARE(model.roleNames().count(), 3);
        }

        // 1. set delegate model
        // 2. set source
        // 3. set submodel role name
        // 4. set exposed role names
        {
            ObjectProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setDelegate(delegateWithRole.get());

            QCOMPARE(signalsSpy.count(), 0);
            QCOMPARE(model.roleNames().count(), 0);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setExpectedRoles({ QStringLiteral("balances") });

            QCOMPARE(signalsSpy.count(), 4);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 2);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 2);
            QCOMPARE(model.roleNames().count(), 2);

            model.setExposedRoles({ QStringLiteral("extraValue") });

            QCOMPARE(signalsSpy.count(), 6);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 3);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 3);
            QCOMPARE(model.roleNames().count(), 3);
        }

        // 1. set submodel role name
        // 1. set expected role name
        // 2. set delegate model
        // 3. set source
        {
            ObjectProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setExpectedRoles({ QStringLiteral("balances") });
            model.setExposedRoles({ QStringLiteral("extraValue") });

            model.setDelegate(delegateWithRole.get());

            QCOMPARE(signalsSpy.count(), 0);
            QCOMPARE(model.roleNames().count(), 0);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 3);
        }

        // 1. set source
        // 2. set delegate model (no extra roles)
        // 3. set submodel role name
        {
            ObjectProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setDelegate(delegateNoRole.get());

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setExpectedRoles({ QStringLiteral("balances") });

            QCOMPARE(signalsSpy.count(), 4);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 2);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 2);
            QCOMPARE(model.roleNames().count(), 2);
        }
    }

    void sourceModelResetTest() {
        class IdentityModel : public QIdentityProxyModel {};

        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                property int extraValueRole: 0
            }
        )"), QUrl());

        ListModelWrapper sourceModel1(engine, R"([
            { "balances": [], "name": "name 1" }
        ])");

        ListModelWrapper sourceModel2(engine, R"([
            { "key": "1", "balances": [], "name": "name 1", "color": "red" }
        ])");

        IdentityModel identity;
        identity.setSourceModel(sourceModel1);

        ObjectProxyModel model;
        model.setSourceModel(&identity);
        model.setDelegate(delegate.get());
        model.setExpectedRoles({ QStringLiteral("balances") });
        model.setExposedRoles({ QStringLiteral("extraValue") });

        QCOMPARE(model.rowCount(), 1);
        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        ModelSignalsSpy signalsSpy(&model);

        identity.setSourceModel(sourceModel2);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
        QCOMPARE(signalsSpy.modelResetSpy.count(), 1);

        QCOMPARE(model.rowCount(), 1);
        roles = model.roleNames();
        QCOMPARE(roles.size(), 5);
    }

    void sourceModelLateRolesInitTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                property int extraValue: 0
            }
        )"), QUrl());

        ListModelWrapper sourceModel(engine, R"([])");

        ObjectProxyModel model;
        model.setSourceModel(sourceModel);
        model.setDelegate(delegate.get());
        model.setExpectedRoles({ QStringLiteral("balances") });
        model.setExposedRoles({ QStringLiteral("extraValue") });

        QCOMPARE(model.rowCount(), 0);
        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 0);

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.append(QJsonArray {
            QJsonObject {{ "name", "D"}, { "balances", "d1" }},
            QJsonObject {{ "name", "D"}, { "balances", "d2" }}
        });

        QCOMPARE(model.rowCount(), 2);
        roles = model.roleNames();
        QCOMPARE(roles.size(), 3);
    }

    void changingSourceModelTest() {
        QQmlEngine engine;
        QQmlComponent delegate(&engine);

        auto delegateData = R"(
            import QtQml 2.15
            QtObject {
                readonly property int count: model.balances.count
            }
        )";

        delegate.setData(delegateData, QUrl());

        ObjectProxyModel model;

        auto source1 = R"([
            { balances: [ { balance: 4 } ], name: "name 1" },
            { balances: [ { balance: 4 }, {balance: 43} ], name: "name 2" }
        ])";

        auto source2 = R"([
            { id: 4, balances: [ { balance: 4 } ], name: "name 1", color: "red" }
        ])";

        ListModelWrapper sourceModel1(engine, source1);
        ListModelWrapper sourceModel2(engine, source2);

        model.setSourceModel(sourceModel1);
        model.setDelegate(&delegate);
        model.setExpectedRoles(QStringList({ QStringLiteral("balances") }));
        model.setExposedRoles({ QStringLiteral("count")});

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.roleNames().size(), 3);

        QSignalSpy sourceModelChangedSpy(
                    &model, &ObjectProxyModel::sourceModelChanged);

        model.setSourceModel(sourceModel2);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(model.roleNames().size(), 5);

        model.setSourceModel(nullptr);

        QCOMPARE(sourceModelChangedSpy.count(), 2);
        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().size(), 0);
    }

    void sourceModelDataChangeTest() {
        QQmlEngine engine;
        QQmlComponent delegate(&engine);

        auto delegateData = R"(
            import QtQml 2.15
            QtObject {
                readonly property int doubledBalance: model.balance * 2
            }
        )";

        delegate.setData(delegateData, QUrl());

        ObjectProxyModel model;

        auto source = R"([
            { balance: 4 },
            { balance: 10 }
        ])";

        ListModelWrapper sourceModel(engine, source);

        model.setSourceModel(sourceModel);
        model.setDelegate(&delegate);

        model.setExpectedRoles(QStringList({ QStringLiteral("balance") }));
        model.setExposedRoles({ QStringLiteral("doubledBalance")});

        ModelSignalsSpy signalsSpy(&model);

        sourceModel.setProperty(0, "balance", 42);
        sourceModel.setProperty(1, "balance", 0);

        {
            ListModelWrapper expected(engine, R"([
                { balance: 42, doubledBalance: 84 },
                { balance: 0, doubledBalance: 0 }
            ])");

            QVERIFY(isSame(&model, expected));
            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 2);
        }

        QEventLoop().processEvents();
        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.dataChangedSpy.count(), 2);

        sourceModel.setProperty(0, "balance", 1);
        sourceModel.setProperty(1, "balance", 2);

        {
            ListModelWrapper expected(engine, R"([
                { balance: 1, doubledBalance: 2 },
                { balance: 2, doubledBalance: 4 }
            ])");

            QVERIFY(isSame(&model, expected));
            QCOMPARE(signalsSpy.count(), 4);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 4);
        }

        QEventLoop().processEvents();
        QCOMPARE(signalsSpy.count(), 5);
        QCOMPARE(signalsSpy.dataChangedSpy.count(), 5);
    }
};

QTEST_MAIN(TestObjectProxyModel)
#include "tst_ObjectProxyModel.moc"
