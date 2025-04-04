#include "StatusQ/modelentry.h"
#include "StatusQ/snapshotmodel.h"

#include "TestHelpers/listmodelwrapper.h"
#include "TestHelpers/modelsignalsspy.h"
#include "TestHelpers/testmodel.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QMetaObject>
#include <QObject>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QTest>

class TestModelEntry : public QObject
{
    Q_OBJECT
    ModelEntry* testObject;
    QMetaProperty sourceModelProperty;
    QMetaProperty keyProperty;
    QMetaProperty valueProperty;
    QMetaProperty rolesProperty;
    QMetaProperty modelItemProperty;
    QMetaProperty availableProperty;
    QMetaProperty rowProperty;
    QMetaProperty cacheOnRemovalProperty;
    QMetaProperty itemRemovedFromCacheProperty;

private slots:
    void init()
    {
        testObject = new ModelEntry();

        auto getProperty = [obj = this->testObject](const char *name) {
            return obj->metaObject()->property(obj->metaObject()->indexOfProperty(name));
        };

        sourceModelProperty = getProperty("sourceModel");
        keyProperty = getProperty("key");
        valueProperty = getProperty("value");
        modelItemProperty = getProperty("item");
        rolesProperty = getProperty("roles");
        availableProperty = getProperty("available");
        rowProperty = getProperty("row");
        cacheOnRemovalProperty = getProperty("cacheOnRemoval");
        itemRemovedFromCacheProperty = getProperty("itemRemovedFromModel");
    }

    void cleanup()
    {
        delete testObject;
        testObject = nullptr;
    }

    void initializationTest()
    {
        // testing default values and properties
        QCOMPARE(testObject->sourceModel(), nullptr);
        QCOMPARE(sourceModelProperty.isValid(), true);
        QCOMPARE(sourceModelProperty.isRequired(), true);
        QCOMPARE(sourceModelProperty.isWritable(), true);
        QCOMPARE(sourceModelProperty.hasNotifySignal(), true);
        QCOMPARE(sourceModelProperty.read(testObject), QVariant::fromValue<QAbstractItemModel*>(nullptr));

        QCOMPARE(testObject->roles(), {});
        QCOMPARE(rolesProperty.isValid(), true);
        QCOMPARE(rolesProperty.isWritable(), false);
        QCOMPARE(rolesProperty.hasNotifySignal(), true);
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());

        QVERIFY(testObject->item() != nullptr);
        QCOMPARE(modelItemProperty.isValid(), true);
        QCOMPARE(modelItemProperty.isWritable(), false);
        QCOMPARE(modelItemProperty.hasNotifySignal(), true);
        QCOMPARE(modelItemProperty.read(testObject), QVariant::fromValue<QQmlPropertyMap*>(testObject->item()));

        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.isValid(), true);
        QCOMPARE(availableProperty.isWritable(), false);
        QCOMPARE(availableProperty.hasNotifySignal(), true);
        QCOMPARE(availableProperty.read(testObject), false);

        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.isValid(), true);
        QCOMPARE(rowProperty.isWritable(), false);
        QCOMPARE(rowProperty.hasNotifySignal(), true);
        QCOMPARE(rowProperty.read(testObject), -1);

        // testing property setters
        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // testing source model property
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);
        QCOMPARE(testObject->sourceModel(), static_cast<QAbstractItemModel*>(sourceModel.model()));
        QCOMPARE(sourceModelProperty.read(testObject), QVariant::fromValue<QAbstractItemModel*>(sourceModel.model()));

        // testing filter property
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);
        QCOMPARE(testObject->key(), "key");
        QCOMPARE(keyProperty.read(testObject), "key");
        QCOMPARE(testObject->value(), 1);
        QCOMPARE(valueProperty.read(testObject), 1);

        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);

        QStringList expectedRoles{"key", "color"};
        auto roles = testObject->roles();
        auto rolesVariant = rolesProperty.read(testObject);

        QCOMPARE(roles, rolesVariant);
        QVERIFY(roles.size() == 2);
        QCOMPARE(roles.contains("key"), true);
        QCOMPARE(roles.contains("color"), true);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");
        QCOMPARE(modelItemProperty.read(testObject), QVariant::fromValue<QQmlPropertyMap*>(testObject->item()));
    }

    void reversePropertyInitializationTest()
    {
        // setting the filter and then the source model
        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // write the filter first
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 0);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        QCOMPARE(testObject->key(), "key");
        QCOMPARE(keyProperty.read(testObject), "key");
        QCOMPARE(testObject->value(), 1);
        QCOMPARE(valueProperty.read(testObject), 1);
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->roles(), {});
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());
        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.read(testObject), -1);

        // write the source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->sourceModel(), static_cast<QAbstractItemModel*>(sourceModel.model()));
        QCOMPARE(sourceModelProperty.read(testObject), QVariant::fromValue<QAbstractItemModel*>(sourceModel.model()));
        QCOMPARE(testObject->key(), "key");
        QCOMPARE(keyProperty.read(testObject), "key");
        QCOMPARE(testObject->value(), 1);
        QCOMPARE(valueProperty.read(testObject), 1);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);

        // testing the output properties
        auto roles = testObject->roles();
        auto rolesVariant = rolesProperty.read(testObject);

        QCOMPARE(roles, rolesVariant);
        QVERIFY(roles.size() == 2);
        QCOMPARE(roles.contains("key"), true);
        QCOMPARE(roles.contains("color"), true);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");
        QCOMPARE(modelItemProperty.read(testObject), QVariant::fromValue<QQmlPropertyMap*>(testObject->item()));

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
    }

    // testing source model change
    // test cases:
    // 1. source model is changed to a new model with the same roles. The item should be updated with the new model's data.
    // 2. source model is changed to a new model with the same roles, but not containing the data. The item should be invalidated.
    // 3. source model is changed to a new model with different roles. The item should be invalidated.
    // 4. source model is changed to a new model with different roles, but contains the right key and value. The item
    // should be updated with the new model's data.
    // 5. source model is changed to empty model. The item should be cleared.
    // 6. source model is changed to the same model. The item should not be updated.
    void sourceChangedAfterMatchTest_data()
    {
        QJsonArray initialSource{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}};

        QJsonArray similarSourceWithMatch{QJsonObject{{"key", 1}, {"color", "green"}},
                                          QJsonObject{{"key", 3}, {"color", "yellow"}}};

        QJsonArray similarSourceNoMatch{QJsonObject{{"key", 3}, {"color", "green"}},
                                        QJsonObject{{"key", 4}, {"color", "yellow"}}};

        QJsonArray differentRolesSource{QJsonObject{{"other_key", 1}, {"other_color", "red"}},
                                        QJsonObject{{"other_key", 2}, {"other_color", "blue"}}};

        QJsonArray sameKeyDifferentRolesWithMatch{
            QJsonObject{{"key", 1}, {"other_color", "red"}},
            QJsonObject{{"key", 2}, {"other_color", "blue"}},
            QJsonObject{{"key", 3}, {"other_color", "green"}},
        };

        QTest::addColumn<QJsonArray>("initialSource");
        QTest::addColumn<QJsonArray>("secondSource");
        QTest::addColumn<int>("matchingKey");
        QTest::addColumn<int>("matchingRowInSecondSource");
        QTest::addColumn<bool>("expectedAvailable");
        QTest::addColumn<bool>("expectedItemChange");

        QTest::newRow("1. source model is changed to a new model with the same roles. The item should be updated with "
                      "the new model's data.")
            << initialSource << similarSourceWithMatch << 1 << 0 << true << false;

        QTest::newRow("2. source model is changed to a new model with the same roles, but not containing the data. The "
                      "item should be invalidated.")
            << initialSource << similarSourceNoMatch << -1 << -1 << false << true;

        QTest::newRow("3. source model is changed to a new model with different roles. The item should be invalidated.")
            << initialSource << differentRolesSource << -1 << -1 << false << true;

        QTest::newRow("4. source model is changed to a new model with different roles, but contains the right key and "
                      "value. The item should be updated with the new model's data.")
            << initialSource << sameKeyDifferentRolesWithMatch << 1 << 0 << true << true;

        QTest::newRow("5. source model is changed to empty model. The item should be cleared.")
            << initialSource << QJsonArray{} << -1 << -1 << false << true;

        QTest::newRow("6. source model is changed to the same model. The item should not be updated.")
            << initialSource << initialSource << 1 << 0 << true << false;
    }

    void sourceChangedAfterMatchTest()
    {
        QFETCH(QJsonArray, initialSource);
        QFETCH(QJsonArray, secondSource);
        QFETCH(int, matchingKey);
        QFETCH(int, matchingRowInSecondSource);

        QFETCH(bool, expectedAvailable);
        QFETCH(bool, expectedItemChange);

        QQmlEngine engine;
        ListModelWrapper initialSourceModel(engine, initialSource);
        ListModelWrapper secondSourceModel(engine, secondSource);

        auto initialRoles = initialSourceModel.model()->roleNames().values();
        auto secondSourceRoles = secondSourceModel.model()->roleNames().values();

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(
            sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(initialSourceModel.model())),
            true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        QCOMPARE(testObject->roles(), {});
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());

        // setting the filter -> initial setup matches the first row
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);

        for(const auto& role : initialRoles)
            QCOMPARE(testObject->roles().contains(role), true);

        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);

        QCOMPARE(testObject->item()->value(initialRoles[0]),
                 initialSource.at(0).toObject().value(initialRoles[0]).toVariant());
        QCOMPARE(testObject->item()->value(initialRoles[1]),
                 initialSource.at(0).toObject().value(initialRoles[1]).toVariant());

        QCOMPARE(valueProperty.write(testObject, matchingKey), true);

        QCOMPARE(
            sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(secondSourceModel.model())),
            true);

        QCOMPARE(sourceModelChangedSpy.count(), 2);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), matchingKey == 1 ? 1 : 2);
        QCOMPARE(itemChangedSpy.count(), expectedItemChange ? 2 : 1);
        QCOMPARE(availableChangedSpy.count(), expectedAvailable ? 1 : 2);

        if(expectedAvailable)
        {
            for(const auto& role : secondSourceRoles)
                QCOMPARE(testObject->roles().contains(role), true);

            QCOMPARE(testObject->item()->value(secondSourceRoles[0]),
                     secondSource.at(0).toObject().value(secondSourceRoles[0]).toVariant());
            QCOMPARE(testObject->item()->value(secondSourceRoles[1]),
                     secondSource.at(0).toObject().value(secondSourceRoles[1]).toVariant());
        }

        QCOMPARE(testObject->available(), expectedAvailable);
        QCOMPARE(availableProperty.read(testObject), expectedAvailable);

        QCOMPARE(testObject->row(), matchingRowInSecondSource);
        QCOMPARE(rowProperty.read(testObject), matchingRowInSecondSource);
    }

    void filterChangedTest()
    {
        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->key(), "key");
        QCOMPARE(keyProperty.read(testObject), "key");
        QCOMPARE(testObject->value(), 1);
        QCOMPARE(valueProperty.read(testObject), 1);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());
        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);

        // changing the filter
        QCOMPARE(keyProperty.write(testObject, "color"), true);
        QCOMPARE(valueProperty.write(testObject, "blue"), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 2);
        QCOMPARE(itemChangedSpy.count(), 3);
        QCOMPARE(availableChangedSpy.count(), 3);
        QCOMPARE(rolesChangedSpy.count(), 3);
        QCOMPARE(rowChangedSpy.count(), 3);

        QCOMPARE(testObject->key(), "color");
        QCOMPARE(keyProperty.read(testObject), "color");
        QCOMPARE(testObject->value(), "blue");
        QCOMPARE(valueProperty.read(testObject), "blue");
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());
        QCOMPARE(testObject->row(), 1);
        QCOMPARE(rowProperty.read(testObject), 1);

        // Changing the filter to non-matching filter -> the item should be invalidated
        QCOMPARE(keyProperty.write(testObject, "other_key"), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 3);
        QCOMPARE(valueChangedSpy.count(), 2);
        QCOMPARE(itemChangedSpy.count(), 4);
        QCOMPARE(availableChangedSpy.count(), 4);
        QCOMPARE(rolesChangedSpy.count(), 4);
        QCOMPARE(rowChangedSpy.count(), 4);

        QCOMPARE(testObject->key(), "other_key");
        QCOMPARE(keyProperty.read(testObject), "other_key");
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->roles(), {});
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());
        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.read(testObject), -1);
    }

    void rolesChangedTest()
    {
        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->key(), "key");
        QCOMPARE(keyProperty.read(testObject), "key");
        QCOMPARE(testObject->value(), 1);
        QCOMPARE(valueProperty.read(testObject), 1);

        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());
        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");
        QCOMPARE(testObject->roles().size(), 2);

        // changing the other roles, except for the key
        ListModelWrapper secondsourceModel(
            engine,
            QJsonArray{QJsonObject{{"key", 1}, {"other_color", "red"}, {"other_role", 1}},
                       QJsonObject{{"key", 2}, {"other_color", "blue"}, {"other_role", 2}}});
        QCOMPARE(
            sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(secondsourceModel.model())),
            true);

        QCOMPARE(sourceModelChangedSpy.count(), 2);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(rolesChangedSpy.count(), 2);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->roles().size(), 3);
        QCOMPARE(testObject->roles().contains("key"), true);
        QCOMPARE(testObject->roles().contains("other_color"), true);
        QCOMPARE(testObject->roles().contains("other_role"), true);
        QCOMPARE(rolesProperty.read(testObject), testObject->roles());

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("other_color"), "red");
        QCOMPARE(testObject->item()->value("other_role"), 1);

        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);

        // changing the roles including the key
        ListModelWrapper thirdsourceModel(
            engine,
            QJsonArray{QJsonObject{{"other_key", 1}, {"other_color", "red"}, {"other_role", 1}},
                       QJsonObject{{"other_key", 2}, {"other_color", "blue"}, {"other_role", 2}}});

        QCOMPARE(
            sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(thirdsourceModel.model())),
            true);

        QCOMPARE(sourceModelChangedSpy.count(), 3);
        QCOMPARE(itemChangedSpy.count(), 3);
        QCOMPARE(rolesChangedSpy.count(), 3);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 2);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(testObject->roles().size(), 0);
        QCOMPARE(testObject->row(), -1);

        //try to access previous roles
        QCOMPARE(testObject->item()->value("key"), {});
        QCOMPARE(testObject->item()->value("other_color"), {});
        QCOMPARE(testObject->item()->value("other_role"), {});

        //Update the filter to have a match
        QCOMPARE(keyProperty.write(testObject, "other_key"), true);

        QCOMPARE(itemChangedSpy.count(), 4);
        QCOMPARE(rolesChangedSpy.count(), 4);
        QCOMPARE(sourceModelChangedSpy.count(), 3);
        QCOMPARE(rowChangedSpy.count(), 3);
        QCOMPARE(availableChangedSpy.count(), 3);
        QCOMPARE(keyChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 1);

        QCOMPARE(testObject->roles().size(), 3);
        QCOMPARE(testObject->roles().contains("other_key"), true);
        QCOMPARE(testObject->roles().contains("other_color"), true);
        QCOMPARE(testObject->roles().contains("other_role"), true);

        QCOMPARE(testObject->item()->value("other_key"), 1);
        QCOMPARE(testObject->item()->value("other_color"), "red");
        QCOMPARE(testObject->item()->value("other_role"), 1);

        QCOMPARE(testObject->item(), modelItemProperty.read(testObject).value<QQmlPropertyMap*>());

        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);

        // update filter and the item is not found
        QCOMPARE(valueProperty.write(testObject, 5), true);

        QCOMPARE(itemChangedSpy.count(), 5);
        QCOMPARE(rolesChangedSpy.count(), 5);
        QCOMPARE(sourceModelChangedSpy.count(), 3);
        QCOMPARE(rowChangedSpy.count(), 4);
        QCOMPARE(availableChangedSpy.count(), 4);
        QCOMPARE(keyChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 2);

        QCOMPARE(testObject->roles().size(), 0);
        QCOMPARE(testObject->row(), -1);

        //try to access previous roles
        QCOMPARE(testObject->item()->value("other_key"), {});
        QCOMPARE(testObject->item()->value("other_color"), {});
        QCOMPARE(testObject->item()->value("other_role"), {});

        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
    }

    void rowChangedTest()
    {
        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        // changing the row -> key = 1 to key = 3 => item is not found
        sourceModel.set(0, QJsonObject{{"key", 3}, {"color", "green"}});

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 2);
        QCOMPARE(rolesChangedSpy.count(), 2);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.read(testObject), -1);
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->roles().size(), 0);

        QCOMPARE(testObject->item()->value("key"), {});

        // changing the row to key = 1 => item is found
        sourceModel.set(0, QJsonObject{{"key", 1}, {"color", "red"}});
        QCOMPARE(testObject->row(), 0);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 3);
        QCOMPARE(availableChangedSpy.count(), 3);
        QCOMPARE(rolesChangedSpy.count(), 3);
        QCOMPARE(rowChangedSpy.count(), 3);

        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);
        QCOMPARE(testObject->item()->value("key"), 1);
    }

    void sourceModelResetTest()
    {
        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        // changing the source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(nullptr)), true);

        QCOMPARE(sourceModelChangedSpy.count(), 2);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 2);
        QCOMPARE(rolesChangedSpy.count(), 2);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.read(testObject), -1);
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->roles().size(), 0);

        QCOMPARE(testObject->item()->value("key"), {});
    }

    void sourceModelRowsInsertedTest()
    {
        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}}, QJsonObject{{"key", 2}, {"color", "blue"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        // inserting a new row -> nothing should change
        sourceModel.insert(0, QJsonObject{{"key", 3}, {"color", "green"}});

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        // update the filter to invalidate the item and then insert a new row that's a match
        QCOMPARE(valueProperty.write(testObject, 4), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 2);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 2);
        QCOMPARE(rolesChangedSpy.count(), 2);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.read(testObject), -1);
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->roles().size(), 0);

        QCOMPARE(testObject->item()->value("key"), {});

        sourceModel.insert(0, QJsonObject{{"key", 4}, {"color", "yellow"}});
        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 4);
        QCOMPARE(testObject->item()->value("color"), "yellow");

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 2);
        QCOMPARE(itemChangedSpy.count(), 3);
        QCOMPARE(availableChangedSpy.count(), 3);
        QCOMPARE(rolesChangedSpy.count(), 3);
        QCOMPARE(rowChangedSpy.count(), 3);
    }

    void sourceModelRowsRemovedTest()
    {
        QQmlEngine engine;
        ListModelWrapper sourceModel(engine,
                                     QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}},
                                                QJsonObject{{"key", 2}, {"color", "blue"}},
                                                QJsonObject{{"key", 3}, {"color", "green"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);

        // removing a row that is not a match -> nothing should change
        sourceModel.remove(1);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        // remove the matching row
        sourceModel.remove(0);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 2);
        QCOMPARE(rolesChangedSpy.count(), 2);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.read(testObject), -1);
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->roles().size(), 0);

        QCOMPARE(testObject->item()->value("key"), {});
    }

    void sourceModelDataChangedTest()
    {
        QQmlEngine engine;
        ListModelWrapper sourceModel(engine,
                                     QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}},
                                                QJsonObject{{"key", 2}, {"color", "blue"}},
                                                QJsonObject{{"key", 3}, {"color", "green"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        // update the matching row with new data -> no API signals expected; Only the item should be updated
        QSignalSpy itemValueChangedSpy(testObject->item(), &QQmlPropertyMap::valueChanged);
        sourceModel.setProperty(0, "color", "yellow");

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);
        QCOMPARE(itemValueChangedSpy.count(), 1);
        QCOMPARE(itemValueChangedSpy.at(0).at(0).toString(), "color");
        QCOMPARE(itemValueChangedSpy.at(0).at(1).toString(), "yellow");

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "yellow");
    }

    void sourceModelLayoutChangedTest()
    {
        TestModel sourceModel({{"key", {1, 2, 3}}, {"color", {"red", "blue", "green"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel)), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        // update the layout -> only the row should change
        sourceModel.invert();

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(testObject->row(), 2);
        QCOMPARE(rowProperty.read(testObject), 2);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");
    }

    void cacheOnSourceRemovalTest()
    {
        QScopedPointer qObject1 {new QObject()};
        qObject1->setProperty("key", 1);
        qObject1->setProperty("color", "red");

        QScopedPointer qObject2 {new QObject()};
        qObject2->setProperty("key", 2);
        qObject2->setProperty("color", "blue");

        QScopedPointer qObject3 {new QObject()};
        qObject3->setProperty("key", 3);
        qObject3->setProperty("color", "green");

        QScopedPointer subModel1 {new TestModel({{"key", {1}}, {"color", {"red"}}})};
        QScopedPointer subModel2 {new TestModel({{"key", {2}}, {"color", {"blue"}}})};
        QScopedPointer subModel3 {new TestModel({{"key", {3}}, {"color", {"green"}}})};

        TestModel sourceModel(
            {{"key", {1, 2, 3}},
             {"color", {"red", "blue", "green"}},
             {"item", {QVariant::fromValue(qObject1.data()),
                       QVariant::fromValue(qObject2.data()),
                       QVariant::fromValue(qObject3.data())}},
             {"subModel",
              {QVariant::fromValue(subModel1.data()),
               QVariant::fromValue(subModel2.data()),
               QVariant::fromValue(subModel3.data())}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel)), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 4);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");
        QCOMPARE(testObject->item()->value("item"), QVariant::fromValue(qObject1.data()));

        QSignalSpy cacheOnRemovalChangedSpy(testObject, &ModelEntry::cacheOnRemovalChanged);
        QSignalSpy itemRemovedFromModelSpy(testObject, &ModelEntry::itemRemovedFromModelChanged);

        QCOMPARE(cacheOnRemovalProperty.read(testObject), false);
        QCOMPARE(cacheOnRemovalProperty.write(testObject, true), true);
        QCOMPARE(cacheOnRemovalProperty.read(testObject), true);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), false);
        QCOMPARE(cacheOnRemovalChangedSpy.count(), 1);
        QCOMPARE(itemRemovedFromModelSpy.count(), 0);

        // remove the item in the source model -> the item should still be valid
        sourceModel.remove(0);
        qObject1.reset();
        subModel1.reset();

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(cacheOnRemovalChangedSpy.count(), 1);
        QCOMPARE(itemRemovedFromModelSpy.count(), 1);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), true);
        QCOMPARE(testObject->row(), -1);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");
        QCOMPARE(testObject->item()->value("item").toMap().value("key"), 1);
        QCOMPARE(testObject->item()->value("item").toMap().value("color"), "red");

        auto cachedSubModel = testObject->item()->value("subModel").value<QAbstractItemModel*>();
        QVERIFY(cachedSubModel != nullptr);
        QCOMPARE(cachedSubModel->data(cachedSubModel->index(0, 0), cachedSubModel->roleNames().key("key")), 1);
        QCOMPARE(cachedSubModel->data(cachedSubModel->index(0, 0), cachedSubModel->roleNames().key("color")), "red");

        // change filter to match an existing row
        QCOMPARE(valueProperty.write(testObject, 2), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 2);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowChangedSpy.count(), 3);

        QCOMPARE(cacheOnRemovalChangedSpy.count(), 1);
        QCOMPARE(itemRemovedFromModelSpy.count(), 2);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), false);
        QCOMPARE(testObject->row(), 0);

        QCOMPARE(testObject->item()->value("key"), 2);
        QCOMPARE(testObject->item()->value("color"), "blue");

        // disable cache on removal and delete the row -> the item should be invalidated
        sourceModel.remove(0);
        QCOMPARE(itemRemovedFromModelSpy.count(), 3);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), true);

        QCOMPARE(cacheOnRemovalProperty.write(testObject, false), true);
        QCOMPARE(cacheOnRemovalProperty.read(testObject), false);

        QCOMPARE(cacheOnRemovalChangedSpy.count(), 2);
        QCOMPARE(itemRemovedFromModelSpy.count(), 4);
        QCOMPARE(availableChangedSpy.count(), 2);

        QCOMPARE(testObject->available(), false);
        QCOMPARE(testObject->itemRemovedFromModel(), false);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), false);

        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->item()->value("key"), {});
        QCOMPARE(testObject->item()->value("color"), {});
    }

    void cachedItemOnModelReset()
    {
        auto qObject1 = new QObject(this);
        qObject1->setProperty("key", 1);
        qObject1->setProperty("color", "red");

        auto qObject2 = new QObject(this);
        qObject2->setProperty("key", 2);
        qObject2->setProperty("color", "blue");

        auto qObject3 = new QObject(this);
        qObject3->setProperty("key", 3);
        qObject3->setProperty("color", "green");

        auto subModel1 = new TestModel({{"key", {1}}, {"color", {"red"}}});
        auto subModel2 = new TestModel({{"key", {2}}, {"color", {"blue"}}});
        auto subModel3 = new TestModel({{"key", {3}}, {"color", {"green"}}});

        TestModel sourceModel(
            {{"key", {1, 2, 3}},
             {"color", {"red", "blue", "green"}},
             {"item", {QVariant::fromValue(qObject1), QVariant::fromValue(qObject2), QVariant::fromValue(qObject3)}},
             {"subModel",
              {QVariant::fromValue(subModel1), QVariant::fromValue(subModel2), QVariant::fromValue(subModel3)}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel)), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        // setting the cache on removal flag
        QCOMPARE(cacheOnRemovalProperty.write(testObject, true), true);

        TestModel sourceModel2(
            {{"key", {4, 2, 3}},
             {"color", {"red", "blue", "green"}},
             {"item", {QVariant::fromValue(qObject1), QVariant::fromValue(qObject2), QVariant::fromValue(qObject3)}},
             {"subModel",
              {QVariant::fromValue(subModel1), QVariant::fromValue(subModel2), QVariant::fromValue(subModel3)}}});

        // set another model without a matching row
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel2)), true);

        QCOMPARE(sourceModelChangedSpy.count(), 2);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 2);

        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->itemRemovedFromModel(), false);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), false);
        QCOMPARE(testObject->item()->value("key"), {});
        QCOMPARE(testObject->item()->value("color"), {});

        // match a row
        QCOMPARE(valueProperty.write(testObject, 2), true);
        // delete the row
        sourceModel2.remove(1);

        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->itemRemovedFromModel(), true);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), true);
        QCOMPARE(testObject->item()->value("key"), 2);
        QCOMPARE(testObject->item()->value("color"), "blue");

        // insert the row back
        sourceModel2.insert(1, {2, "red", QVariant::fromValue(qObject2), QVariant::fromValue(subModel2)});

        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->itemRemovedFromModel(), false);
        QCOMPARE(itemRemovedFromCacheProperty.read(testObject), false);
        QCOMPARE(testObject->item()->value("key"), 2);
        QCOMPARE(testObject->item()->value("color"), "red");
    }

    void keyValueFilterTest()
    {
        TestModel sourceModel({{"key", {1, 2, 3}}, {"color", {"red", "blue", "green"}}});

        QSignalSpy sourceModelChangedSpy(testObject, &ModelEntry::sourceModelChanged);
        QSignalSpy keyChangedSpy(testObject, &ModelEntry::keyChanged);
        QSignalSpy valueChangedSpy(testObject, &ModelEntry::valueChanged);
        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);
        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        QSignalSpy rolesChangedSpy(testObject, &ModelEntry::rolesChanged);
        QSignalSpy rowChangedSpy(testObject, &ModelEntry::rowChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel)), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 0);
        QCOMPARE(valueChangedSpy.count(), 0);
        QCOMPARE(itemChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QCOMPARE(rolesChangedSpy.count(), 0);
        QCOMPARE(rowChangedSpy.count(), 0);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, {"key"}), true);
        QCOMPARE(valueProperty.write(testObject, QVariant::fromValue(1)), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(rolesChangedSpy.count(), 1);
        QCOMPARE(rowChangedSpy.count(), 1);

        QCOMPARE(testObject->row(), 0);
        QCOMPARE(rowProperty.read(testObject), 0);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        QCOMPARE(testObject->key(), "key");
        QCOMPARE(testObject->value(), 1);

        // update the key -> the item should be invalidated
        QCOMPARE(keyProperty.write(testObject, "color"), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 2);
        QCOMPARE(rolesChangedSpy.count(), 2);
        QCOMPARE(rowChangedSpy.count(), 2);

        QCOMPARE(testObject->row(), -1);
        QCOMPARE(rowProperty.read(testObject), -1);
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);
        QCOMPARE(testObject->roles().size(), 0);

        QCOMPARE(testObject->item()->value("key"), {});
        QCOMPARE(testObject->item()->value("color"), {});

        QCOMPARE(valueProperty.write(testObject, "blue"), true);

        QCOMPARE(sourceModelChangedSpy.count(), 1);
        QCOMPARE(keyChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 2);
        QCOMPARE(itemChangedSpy.count(), 3);
        QCOMPARE(availableChangedSpy.count(), 3);
        QCOMPARE(rolesChangedSpy.count(), 3);
        QCOMPARE(rowChangedSpy.count(), 3);

        QCOMPARE(testObject->row(), 1);
        QCOMPARE(rowProperty.read(testObject), 1);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);
        QCOMPARE(testObject->roles().size(), 2);
    }

    void signalOrderTest()
    {
        TestModel sourceModel({{"key", {1, 2, 3}}, {"color", {"red", "blue", "green"}}});

        QSignalSpy availableChangedSpy(testObject, &ModelEntry::availableChanged);
        auto availableChangeConnection = connect(testObject, &ModelEntry::availableChanged, this, [this]() {
            // when the available signal is emmitted, the item should still be valid
            // inital state -> available = false
            // setting the source model -> available = true. In this case the item should be valid before available is emmitted
            // setting the filter -> available = false. In this case the item should be invalidated after available is set to false
            QCOMPARE(testObject->item()->isEmpty(), false);
            QCOMPARE(testObject->roles().size(), 2);
            QVERIFY(testObject->item()->value("key") != QVariant{});
            if(testObject->available())
                QCOMPARE(testObject->row(), 0);
            else
                QCOMPARE(testObject->row(), -1);
        });

        auto itemChangedConnection = connect(testObject, &ModelEntry::itemChanged, this, [this]() {
            // roles should be available after the item is changed
            QCOMPARE(testObject->roles().size(), 0);
            QVERIFY(testObject->item()->value("key") != QVariant{});
        });

        auto rolesChangedConnection = connect(testObject, &ModelEntry::rolesChanged, this, [this]() {
            // the item should be afailable when the roles are set
            QCOMPARE(testObject->roles().size(), 2);
            QVERIFY(testObject->item()->value("key") != QVariant{});
        });

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel)), true);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);
        
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(testObject->available(), true);
        QCOMPARE(availableProperty.read(testObject), true);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        disconnect(itemChangedConnection);
        disconnect(rolesChangedConnection);

        itemChangedConnection = connect(testObject, &ModelEntry::itemChanged, this, [this]() {
            // roles should be invalidated before the item is invalidated
            QCOMPARE(rolesProperty.read(testObject).toStringList().size(), 0);
            QVERIFY(modelItemProperty.read(testObject) != QVariant{});
        });

        rolesChangedConnection = connect(testObject, &ModelEntry::rolesChanged, this, [this]() {
            // the item should be invalid when the roles are invalid
            QCOMPARE(testObject->roles().size(), 0);
            QVERIFY(testObject->item()->value("key") == QVariant{});
        });

        QCOMPARE(keyProperty.write(testObject, "color"), true);

        QCOMPARE(availableChangedSpy.count(), 2);
        QCOMPARE(testObject->available(), false);
        QCOMPARE(availableProperty.read(testObject), false);

        QCOMPARE(testObject->item()->value("key"), {});
        QCOMPARE(testObject->item()->value("color"), {});
    }

    void itemSignalsTest()
    {
        // Testing the signals of the item object
        // Expected:
        // 1. changes in model role values produce valueChanged signals only for the roles that changed
        // 2. changes in the model role used for filtering should produce itemChanged signals and no valueChanged signals

        QQmlEngine engine;
        ListModelWrapper sourceModel(
            engine, QJsonArray{QJsonObject{{"key", 1}, {"color", "red"}, {"size", "small"}}, QJsonObject{{"key", 2}, {"color", "blue"}, {"size", "medium"}}});

        QSignalSpy itemChangedSpy(testObject, &ModelEntry::itemChanged);

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(sourceModel.model())),
                 true);
        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(itemChangedSpy.count(), 1);

        QSignalSpy valueChangedSpy(testObject->item(), &QQmlPropertyMap::valueChanged);

        // change the value of the item
        sourceModel.setProperty(0, "color", "yellow");
        QCOMPARE(valueChangedSpy.count(), 1);
        QCOMPARE(valueChangedSpy.at(0).at(0).toString(), "color");
        QCOMPARE(valueChangedSpy.at(0).at(1).toString(), "yellow");

        sourceModel.setProperty(0, "size", "large");
        QCOMPARE(valueChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.at(1).at(0).toString(), "size");
        QCOMPARE(valueChangedSpy.at(1).at(1).toString(), "large");

        // change the filter to the second item
        QCOMPARE(valueProperty.write(testObject, 2), true);
        QCOMPARE(itemChangedSpy.count(), 2);
        QCOMPARE(valueChangedSpy.count(), 2);
    }

    void itemObjectCleanupTest()
    {
        TestModel sourceModel1({{"key", {1, 2, 3}}, {"color", {"red", "blue", "green"}}});
        TestModel sourceModel2({{"key", {1, 2, 3}}, {"other_color", {"red", "blue", "green"}}});

        // setting the initial source model
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel1)), true);

        // setting the filter
        QCOMPARE(keyProperty.write(testObject, "key"), true);
        QCOMPARE(valueProperty.write(testObject, 1), true);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), "red");

        auto itemObj = testObject->item();
        QSignalSpy deletedSpy(itemObj, &QObject::destroyed);

        // set another source model with different roles
        QCOMPARE(sourceModelProperty.write(testObject, QVariant::fromValue<QAbstractItemModel*>(&sourceModel2)), true);

        QCOMPARE(testObject->item()->value("key"), 1);
        QCOMPARE(testObject->item()->value("color"), {});
        QCOMPARE(testObject->item()->value("other_color"), "red");

        // the item object should be destroyed
        QCOMPARE(deletedSpy.count(), 1);
    }
};

QTEST_MAIN(TestModelEntry)
#include "tst_ModelEntry.moc"
