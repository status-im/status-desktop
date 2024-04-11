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

class TestSubmodelProxyModel: public QObject
{
    Q_OBJECT

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

        QCOMPARE(delegateModelChangedSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 1);

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

    void settingUndefinedSubmodelRoleNameText() {
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
};

QTEST_MAIN(TestSubmodelProxyModel)
#include "tst_SubmodelProxyModel.moc"
