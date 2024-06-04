#include "StatusQ/snapshotobject.h"

#include <QSignalSpy>
#include <QTest>

#include <QQmlListProperty>
#include <QQmlPropertyMap>
#include <QStandardItemModel>
#include <QScopedPointer>

#include <QDebug>

class SimpleObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool boolProperty MEMBER m_boolProperty)
    Q_PROPERTY(int intProperty MEMBER m_intProperty)
    Q_PROPERTY(QString stringProperty MEMBER m_stringProperty)
    Q_PROPERTY(QVariant variantProperty MEMBER m_variantProperty)
public:
    SimpleObject(bool boolProperty = true,
                 int intProperty = 5,
                 const QString& stringProperty = "string",
                 const QVariant& variantProperty = "variant",
                 QObject* parent = nullptr)
        : QObject(parent)
        , m_boolProperty(boolProperty)
        , m_intProperty(intProperty)
        , m_stringProperty(stringProperty)
        , m_variantProperty(variantProperty)
    { }
    bool m_boolProperty;
    int m_intProperty;
    QString m_stringProperty;
    QVariant m_variantProperty;
};

class QObjectTest : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool boolProperty MEMBER m_boolProperty)
    Q_PROPERTY(int intProperty MEMBER m_intProperty)
    Q_PROPERTY(QString stringProperty MEMBER m_stringProperty)
    Q_PROPERTY(QVariant variantProperty MEMBER m_variantProperty)
    Q_PROPERTY(QVariantList variantListProperty MEMBER m_variantListProperty)
    Q_PROPERTY(QVariantMap variantMapProperty MEMBER m_variantMapProperty)
    Q_PROPERTY(QObject* objectProperty MEMBER m_objectProperty)
    Q_PROPERTY(QStandardItemModel* standardItemModel MEMBER m_standardItemModel)

public:
    bool m_boolProperty{true};
    int m_intProperty{5};
    QString m_stringProperty{"string"};
    QVariant m_variantProperty{"variant"};
    QVariantList m_variantListProperty{"variant1", "variant2"};
    QVariantMap m_variantMapProperty{{"key1", "value1"}, {"key2", "value2"}};
    QObject* m_objectProperty{new SimpleObject(true, 45, "stringVal", "variantVal", this)};
    QStandardItemModel* m_standardItemModel = nullptr;
};

class SnapshotObjectTest : public QObject
{
    Q_OBJECT

private slots:
    void snapshotQObjectTest()
    {
        QScopedPointer<SnapshotObject> snapshotObject {new SnapshotObject()};

        QSignalSpy snapshotChangedSpy(snapshotObject.data(), &SnapshotObject::snapshotChanged);
        QSignalSpy availableChangedSpy(snapshotObject.data(), &SnapshotObject::availableChanged);

        QVERIFY(snapshotObject->snapshot().isNull());
        QVERIFY(!snapshotObject->available());

        // grabSnapshot(nullptr) should clear the snapshot and set available to false
        snapshotObject->grabSnapshot(nullptr);

        QCOMPARE(snapshotChangedSpy.count(), 0);
        QCOMPARE(availableChangedSpy.count(), 0);
        QVERIFY(snapshotObject->snapshot().isNull());
        QVERIFY(!snapshotObject->available());

        {
            // grabSnapshot(new SimpleObject) should set the snapshot and set available to true
            QScopedPointer<SimpleObject> testObject {new SimpleObject(true, 45, "stringVal", "variantVal")};
            const auto snapshotObjPtr = snapshotObject.data();
            auto connection = connect(snapshotObjPtr, &SnapshotObject::availableChanged, [snapshotObjPtr]() {
                // the snapshot object must change after the available property
                QVERIFY(snapshotObjPtr->snapshot().isValid());
            });
            snapshotObject->grabSnapshot(testObject.data());

            QCOMPARE(snapshotChangedSpy.count(), 1);
            QCOMPARE(availableChangedSpy.count(), 1);
            QCOMPARE(snapshotObject->snapshot().toMap()["boolProperty"].toBool(), true);
            QCOMPARE(snapshotObject->snapshot().toMap()["intProperty"].toInt(), 45);
            QCOMPARE(snapshotObject->snapshot().toMap()["stringProperty"].toString(), "stringVal");
            QCOMPARE(snapshotObject->snapshot().toMap()["variantProperty"].toString(), "variantVal");

            QVERIFY(snapshotObject->available());

            disconnect(connection);
            // delete the test object and check that the snapshot is still available
        }

        QCOMPARE(snapshotChangedSpy.count(), 1);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(snapshotObject->snapshot().toMap()["boolProperty"].toBool(), true);
        QCOMPARE(snapshotObject->snapshot().toMap()["intProperty"].toInt(), 45);
        QCOMPARE(snapshotObject->snapshot().toMap()["stringProperty"].toString(), "stringVal");
        QCOMPARE(snapshotObject->snapshot().toMap()["variantProperty"].toString(), "variantVal");

        QVERIFY(snapshotObject->available());

        {
            // grabshapshot(new QObjectTest) should set the snapshot and set available to true
            auto snapshotObjPtr = snapshotObject.data();
            auto connection = connect(snapshotObject.data(), &SnapshotObject::availableChanged, [snapshotObjPtr]() {
                // the snapshot object must change after the available property
                QVERIFY(snapshotObjPtr->snapshot().isValid());
            });
            QScopedPointer<QObjectTest> testObject {new QObjectTest()};
            testObject->m_standardItemModel = new QStandardItemModel(this);
            testObject->m_standardItemModel->insertRow(0, new QStandardItem("item1"));
            testObject->m_standardItemModel->insertRow(1, new QStandardItem("item2"));

            snapshotObject->grabSnapshot(testObject.data());
            disconnect(connection);

            // the testObject and the model is destroyed here
        }

        QCOMPARE(snapshotChangedSpy.count(), 2);
        QCOMPARE(availableChangedSpy.count(), 1);
        QCOMPARE(snapshotObject->snapshot().toMap()["boolProperty"].toBool(), true);
        QCOMPARE(snapshotObject->snapshot().toMap()["intProperty"].toInt(), 5);
        QCOMPARE(snapshotObject->snapshot().toMap()["stringProperty"].toString(), "string");
        QCOMPARE(snapshotObject->snapshot().toMap()["variantProperty"].toString(), "variant");
        QCOMPARE(snapshotObject->snapshot().toMap()["variantListProperty"].toList().size(), 2);
        QCOMPARE(snapshotObject->snapshot().toMap()["variantListProperty"].toList().at(0).toString(), "variant1");
        QCOMPARE(snapshotObject->snapshot().toMap()["variantListProperty"].toList().at(1).toString(), "variant2");
        QCOMPARE(snapshotObject->snapshot().toMap()["variantMapProperty"].toMap().size(), 2);
        QCOMPARE(snapshotObject->snapshot().toMap()["variantMapProperty"].toMap()["key1"].toString(), "value1");
        QCOMPARE(snapshotObject->snapshot().toMap()["variantMapProperty"].toMap()["key2"].toString(), "value2");
        QCOMPARE(snapshotObject->snapshot().toMap()["objectProperty"].toMap()["boolProperty"].toBool(), true);
        QCOMPARE(snapshotObject->snapshot().toMap()["objectProperty"].toMap()["intProperty"].toInt(), 45);
        QCOMPARE(snapshotObject->snapshot().toMap()["objectProperty"].toMap()["stringProperty"].toString(),
                 "stringVal");
        QCOMPARE(snapshotObject->snapshot().toMap()["objectProperty"].toMap()["variantProperty"].toString(),
                 "variantVal");

        auto standardItemModel = snapshotObject->snapshot().toMap()["standardItemModel"].value<QAbstractItemModel*>();
        QSignalSpy modelDestroyedSpy(standardItemModel, &QObject::destroyed);

        QCOMPARE(standardItemModel->rowCount(), 2);
        QCOMPARE(standardItemModel->data(standardItemModel->index(0, 0)), "item1");
        QCOMPARE(standardItemModel->data(standardItemModel->index(1, 0)).toString(), "item2");

        QVERIFY(snapshotObject->available());

        snapshotObject->grabSnapshot(nullptr);

        QCOMPARE(snapshotChangedSpy.count(), 3);
        QCOMPARE(availableChangedSpy.count(), 2);
        QVERIFY(snapshotObject->snapshot().isNull());
        QVERIFY(!snapshotObject->available());
        // check if the memory is released after grabbing another snapshot
        QTRY_COMPARE(modelDestroyedSpy.count(), 1);
    }

    void snapshotModelTest()
    {
        QScopedPointer<SnapshotObject> snapshotObject {new SnapshotObject()};

        {
            QScopedPointer<QStandardItemModel> model {new QStandardItemModel()};
            model->insertRow(0, new QStandardItem("item1"));
            model->insertRow(1, new QStandardItem("item2"));

            snapshotObject->grabSnapshot(model.data());
        }

        auto snapshot = snapshotObject->snapshot();
        auto snapshotModel = snapshot.value<QAbstractItemModel*>();

        QSignalSpy modelDestroyedSpy(snapshotModel, &QObject::destroyed);

        QVERIFY(snapshotModel);
        QCOMPARE(snapshotModel->rowCount(), 2);
        QCOMPARE(snapshotModel->data(snapshotModel->index(0, 0)).toString(), "item1");
        QCOMPARE(snapshotModel->data(snapshotModel->index(1, 0)).toString(), "item2");
        QVERIFY(snapshotObject->available());

        snapshotObject->grabSnapshot(nullptr);
        QTRY_COMPARE(modelDestroyedSpy.count(), 1);
    }
};

QTEST_MAIN(SnapshotObjectTest)
#include "tst_SnapshotObject.moc"
