#include <QSignalSpy>
#include <QTest>

#include <QJsonArray>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>

#include <memory>
#include <string>

#include <StatusQ/submodelproxymodel.h>

#include <TestHelpers/listmodelwrapper.h>
#include <TestHelpers/modelsignalsspy.h>
#include <TestHelpers/modeltestutils.h>

class TestSubmodelProxyModel: public QObject
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
                property var count: submodel.count
            }
        )";

        delegate.setData(delegateData, QUrl());

        SubmodelProxyModel model;

        auto source = R"([
            { balances: [ { balance: 4 } ], name: "name 1" },
            { balances: [ { balance: 4 }, {balance: 43} ], name: "name 2" },
            { balances: [], name: "name 3" }
        ])";

        ListModelWrapper sourceModel(engine, source);

        QSignalSpy sourceModelChangedSpy(
                    &model, &SubmodelProxyModel::sourceModelChanged);
        QSignalSpy delegateChangedSpy(
                    &model, &SubmodelProxyModel::delegateModelChanged);
        QSignalSpy submodelRoleNameChangedSpy(
                    &model, &SubmodelProxyModel::submodelRoleNameChanged);

        model.setSourceModel(sourceModel);
        model.setDelegateModel(&delegate);
        model.setSubmodelRoleName(QStringLiteral("balances"));

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(delegateChangedSpy.count(), 1);
        QCOMPARE(submodelRoleNameChangedSpy.count(), 1);

        QCOMPARE(model.sourceModel(), sourceModel);
        QCOMPARE(model.delegateModel(), &delegate);
        QCOMPARE(model.submodelRoleName(), QStringLiteral("balances"));

        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.data(model.index(0, 0), sourceModel.role("name")), "name 1");
        QVERIFY(model.data(model.index(0, 0),
                           sourceModel.role("balances")).isValid());

        auto object = model.data(model.index(0, 0),
                                 sourceModel.role("balances")).value<QObject*>();
        QVERIFY(object);

        auto context = QQmlEngine::contextForObject(object);

        QVERIFY(context->contextProperty("submodel").value<QObject*>() != nullptr);
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
                property var count: submodel.count
            }
        )";

        delegate.setData(delegateData, QUrl());

        SubmodelProxyModel model;

        auto source = R"([
            { balances: [ { balance: 4 } ], name: "name 1" }
        ])";

        ListModelWrapper sourceModel(engine, source);
        model.setSourceModel(sourceModel);
        model.setDelegateModel(&delegate);
        model.setSubmodelRoleName(QStringLiteral("balances"));

        QCOMPARE(model.rowCount(), 1);

        QVariant balances1 = model.data(model.index(0, 0),
                                       sourceModel.role("balances"));
        QVERIFY(balances1.isValid());

        QVariant balances2 = model.data(model.index(0, 0),
                                       sourceModel.role("balances"));
        QVERIFY(balances2.isValid());

        // SubmodelProxyModel may create proxy objects on demand, then first
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

    void usingNonObjectSubmodelRoleTest() {
        QQmlEngine engine;
        QQmlComponent delegate(&engine);

        auto delegateData = R"(
            import QtQml 2.15
            QtObject {
                property var count: submodel.count
            }
        )";

        delegate.setData(delegateData, QUrl());

        SubmodelProxyModel model;

        auto source = R"([
            { balances: 1, name: "name 1" },
            { balances: 2, name: "name 2" },
            { balances: 3, name: "name 3" }
        ])";

        ListModelWrapper sourceModel(engine, source);

        QTest::ignoreMessage(QtWarningMsg,
                             "Submodel must be a QObject-based type!");

        model.setSourceModel(sourceModel);
        model.setDelegateModel(&delegate);
        model.setSubmodelRoleName(QStringLiteral("balances"));

        QCOMPARE(model.rowCount(), 3);

        QVERIFY(model.data(model.index(0, 0),
                           sourceModel.role("balances")).isValid());
    }

    void deletingDelegateTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml 2.15

            QtObject {
                property var sub: submodel
            }
        )"), QUrl());

        SubmodelProxyModel model;
        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "balances", 11 }, { "name", "name 1" }},
            QJsonObject {{ "balances", 12 }, { "name", "name 2" }},
            QJsonObject {{ "balances", 123}, { "name", "name 3" }}
        });

        model.setSourceModel(sourceModel);
        model.setDelegateModel(delegate.get());
        model.setSubmodelRoleName(QStringLiteral("balances"));

        QSignalSpy delegateModelChangedSpy(
                    &model, &SubmodelProxyModel::delegateModelChanged);
        QSignalSpy dataChangedSpy(
                    &model, &SubmodelProxyModel::dataChanged);

        delegate.reset();

        QCOMPARE(delegateModelChangedSpy.count(), 0);
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
                property var sub: submodel
            }
        )"), QUrl());

        SubmodelProxyModel model;

        auto sourceModel = std::make_unique<ListModelWrapper>(engine,
            QJsonArray {
                QJsonObject {{ "balances", 11 }, { "name", "name 1" }},
                QJsonObject {{ "balances", 12 }, { "name", "name 2" }},
                QJsonObject {{ "balances", 123}, { "name", "name 3" }}
            }
        );

        model.setSourceModel(sourceModel->model());
        model.setDelegateModel(&delegate);
        model.setSubmodelRoleName(QStringLiteral("balances"));

        sourceModel.reset();

        QCOMPARE(model.rowCount(), 0);

        QTest::ignoreMessage(QtWarningMsg, QRegularExpression(".*"));
        QCOMPARE(model.data(model.index(0, 0), 0), {});
    }

    void settingUndefinedSubmodelRoleNameTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml 2.15

            QtObject {
                property var sub: submodel
            }
        )"), QUrl());

        SubmodelProxyModel model;
        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "balances", 11 }, { "name", "name 1" }},
            QJsonObject {{ "balances", 12 }, { "name", "name 2" }},
            QJsonObject {{ "balances", 123}, { "name", "name 3" }}
        });

        model.setSourceModel(sourceModel);
        model.setDelegateModel(delegate.get());

        QTest::ignoreMessage(QtWarningMsg, "Submodel role not found!");

        model.setSubmodelRoleName(QStringLiteral("undefined"));

        QCOMPARE(model.rowCount(), 3);
    }

    void addingNewRoleToTopLevelModelTest() {
        QQmlEngine engine;
        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                id: delegateRoot

                property var sub: submodel

                property int extraValue: submodel.rowCount()
                readonly property alias extraValueRole: delegateRoot.extraValue
            }
        )"), QUrl());

        SubmodelProxyModel model;

        ListModelWrapper sourceModel(engine, R"([
            { "balances": [], "name": "name 1" },
            { "balances": [ { balance: 1 } ], "name": "name 2" },
            { "balances": [], "name": "name 3" }
        ])");

        model.setSourceModel(sourceModel);
        model.setDelegateModel(delegate.get());

        model.setSubmodelRoleName(QStringLiteral("balances"));

        ListModelWrapper expected(engine, R"([
            { "balances": [], "name": "name 1", "extraValue": 0 },
            { "balances": [], "name": "name 2", "extraValue": 1 },
            { "balances": [], "name": "name 3", "extraValue": 0 }
        ])");

        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);
        QVERIFY(isSame(&model, expected));

        ModelSignalsSpy signalsSpy(&model);

        QVariant wrapperVariant = model.data(model.index(0, 0),
                                             roleForName(roles, "balances"));
        QObject* wrapper = wrapperVariant.value<QObject*>();
        QVERIFY(wrapper != nullptr);
        wrapper->setProperty("extraValue", 42);

        ListModelWrapper expected2(engine, R"([
            { "balances": [], "name": "name 1", "extraValue": 42 },
            { "balances": [], "name": "name 2", "extraValue": 1 },
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
                property int extraValueRole: 0
            }
        )"), QUrl());

        ListModelWrapper sourceModel(engine, R"([
            { "balances": [], "name": "name 1" }
        ])");

        SubmodelProxyModel model;
        model.setSourceModel(sourceModel);
        model.setDelegateModel(delegate.get());
        model.setSubmodelRoleName(QStringLiteral("balances"));

        QCOMPARE(model.rowCount(), 1);

        auto roles = model.roleNames();
        QCOMPARE(roles.size(), 3);

        ModelSignalsSpy signalsSpy(&model);

        QVariant wrapperVariant = model.data(model.index(0, 0),
                                             roleForName(roles, "balances"));
        QObject* wrapper = wrapperVariant.value<QObject*>();
        QVERIFY(wrapper != nullptr);

        // dataChanged signal emission is scheduled to event loop, not called
        // immediately. In the meantime the source may be cleared and then no
        // dataChanged event should be emited.
        wrapper->setProperty("extraValueRole", 42);

        sourceModel.remove(0);

        QCOMPARE(signalsSpy.count(), 2);
        QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);

        QTest::qWait(100);
        QCOMPARE(signalsSpy.count(), 2);
    }

    void modelResetWhenRoleChangedTest() {
        QQmlEngine engine;
        auto delegateWithRole = std::make_unique<QQmlComponent>(&engine);

        delegateWithRole->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                property int extraValueRole: 0
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

        // 1. set source, 2. set delegate model, 3. set submodel role name
        {
            SubmodelProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setDelegateModel(delegateWithRole.get());

            QCOMPARE(signalsSpy.count(), 4);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 2);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 2);
            QCOMPARE(model.roleNames().count(), 3);

            model.setSubmodelRoleName(QStringLiteral("balances"));

            QCOMPARE(signalsSpy.count(), 5);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 2);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 2);
            QCOMPARE(model.roleNames().count(), 3);
        }

        // 1. set delegate model, 2. set source, 3. set submodel role name
        {
            SubmodelProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setDelegateModel(delegateWithRole.get());

            QCOMPARE(signalsSpy.count(), 0);
            QCOMPARE(model.roleNames().count(), 0);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 3);

            model.setSubmodelRoleName(QStringLiteral("balances"));

            QCOMPARE(signalsSpy.count(), 3);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 3);
        }

        // 1. set submodel role name, 2. set delegate model, 3. set source
        {
            SubmodelProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setSubmodelRoleName(QStringLiteral("balances"));
            model.setDelegateModel(delegateWithRole.get());

            QCOMPARE(signalsSpy.count(), 0);
            QCOMPARE(model.roleNames().count(), 0);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 3);
        }

        // 1. set source, 2. set delegate model (no extra roles),
        // 3. set submodel role name
        {
            SubmodelProxyModel model;

            ModelSignalsSpy signalsSpy(&model);

            model.setSourceModel(sourceModel);

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setDelegateModel(delegateNoRole.get());

            QCOMPARE(signalsSpy.count(), 2);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);

            model.setSubmodelRoleName(QStringLiteral("balances"));

            QCOMPARE(signalsSpy.count(), 3);
            QCOMPARE(signalsSpy.dataChangedSpy.count(), 1);
            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);
            QCOMPARE(model.roleNames().count(), 2);
        }
    }

    // SubmodelProxyModel instantiates delegate model in order to inspect
    // extra roles. This instantiation must be deferred until model is,
    // available. Otherwise it may lead to accessing uninitialized external
    // data within a delegate instance.
    void deferredDelegateInstantiationTest() {
        QQmlEngine engine;

        QObject controlObject;
        engine.rootContext()->setContextProperty("control", &controlObject);

        auto delegate = std::make_unique<QQmlComponent>(&engine);

        delegate->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15
            import QtQml 2.15

            ListModel {
                property int extraValueRole: 0

                Component.onCompleted: control.objectName = "instantiated"
            }
        )"), QUrl());

        ListModelWrapper sourceModel(engine, R"([
            { "balances": [], "name": "name 1" }
        ])");

        {
            SubmodelProxyModel model;
            model.setSourceModel(sourceModel);
            QCOMPARE(controlObject.objectName(), "");

            model.setDelegateModel(delegate.get());
            QCOMPARE(controlObject.objectName(), "instantiated");
        }

        controlObject.setObjectName("");

        {
            SubmodelProxyModel model;
            model.setDelegateModel(delegate.get());
            QCOMPARE(controlObject.objectName(), "");

            model.setSourceModel(sourceModel);
            QCOMPARE(controlObject.objectName(), "instantiated");
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

        SubmodelProxyModel model;
        model.setSourceModel(&identity);
        model.setDelegateModel(delegate.get());
        model.setSubmodelRoleName(QStringLiteral("balances"));

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
                property int extraValueRole: 0
            }
        )"), QUrl());

        ListModelWrapper sourceModel(engine, R"([])");

        SubmodelProxyModel model;
        model.setSourceModel(sourceModel);
        model.setDelegateModel(delegate.get());
        model.setSubmodelRoleName(QStringLiteral("balances"));

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

    void multipleProxiesTest() {
        QQmlEngine engine;
        auto delegate1 = std::make_unique<QQmlComponent>(&engine);

        delegate1->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                readonly property int myProp: 42
            }
        )"), QUrl());

        auto delegate2 = std::make_unique<QQmlComponent>(&engine);

        delegate2->setData(QByteArrayLiteral(R"(
            import QtQml.Models 2.15

            ListModel {
                readonly property int myProp: 11
            }
        )"), QUrl());

        ListModelWrapper sourceModel(engine, R"([
            { "balances": [], "name": "name 1" },
            { "balances": [], "name": "name 2" },
            { "balances": [], "name": "name 3" }
        ])");

        SubmodelProxyModel model1;
        model1.setSourceModel(sourceModel);
        model1.setDelegateModel(delegate1.get());
        model1.setSubmodelRoleName(QStringLiteral("balances"));

        SubmodelProxyModel model2;
        model2.setSourceModel(sourceModel);
        model2.setDelegateModel(delegate2.get());
        model2.setSubmodelRoleName(QStringLiteral("balances"));

        auto roles = model1.roleNames();
        QCOMPARE(roles.size(), 2);

        QVariant wrapperVariant1 = model1.data(model1.index(0, 0),
                                             roleForName(roles, "balances"));
        QObject* wrapper1 = wrapperVariant1.value<QObject*>();
        QCOMPARE(wrapper1->property("myProp"), 42);

        QVariant wrapperVariant2 = model2.data(model2.index(0, 0),
                                             roleForName(roles, "balances"));
        QObject* wrapper2 = wrapperVariant2.value<QObject*>();
        QCOMPARE(wrapper2->property("myProp"), 11);
    }
};

QTEST_MAIN(TestSubmodelProxyModel)
#include "tst_SubmodelProxyModel.moc"
