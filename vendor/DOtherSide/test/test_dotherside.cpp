// std
#include <tuple>
#include <iostream>
#include <memory>
// Qt
#include <QDebug>
#include <QTest>
#include <QSignalSpy>
#include <QTimer>
#include <QGuiApplication>
#include <QQuickWindow>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQmlContext>
#include <QtQuickTest/QtQuickTest>

// DOtherSide
#include <DOtherSide/DOtherSide.h>
#include <DOtherSide/DosQObject.h>
#include <DOtherSide/DosQMetaObject.h>
#include <DOtherSide/DosQObject.h>
#include <DOtherSide/DosQAbstractItemModel.h>

#include "MockQObject.h"
#include "MockQAbstractItemModel.h"

using namespace std;
using namespace DOS;

template<typename Test>
bool ExecuteTest(int argc, char *argv[])
{
    Test test;
    return QTest::qExec(&test, argc, argv) == 0;
}

template<typename Test>
bool ExecuteGuiTest(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    Test test;
    return QTest::qExec(&test, argc, argv) == 0;
}

/*
 * Test QGuiApplication
 */
class TestQGuiApplication : public QObject
{
    Q_OBJECT

private slots:
    void testExecution()
    {
        bool quit = false;
        dos_qguiapplication_create();
        QTimer::singleShot(100, [&quit]() {
            quit = true;
            dos_qguiapplication_quit();
        });
        dos_qguiapplication_exec();
        QVERIFY(quit);
        dos_qguiapplication_delete();
    }
};

/*
 * Test QVariant
 */
class TestQVariant : public QObject
{
    Q_OBJECT

private slots:
    void testCreate()
    {
        VoidPointer data(dos_qvariant_create(), &dos_qvariant_delete);
        Q_ASSERT(data.get());
        QCOMPARE(dos_qvariant_isnull(data.get()), true);
    }

    void testInt()
    {
        VoidPointer data(dos_qvariant_create_int(10), &dos_qvariant_delete);
        Q_ASSERT(data.get());
        QCOMPARE(dos_qvariant_isnull(data.get()), false);
        int value = dos_qvariant_toInt(data.get());
        QCOMPARE(value, 10);
        dos_qvariant_setInt(data.get(), 20);
        value = dos_qvariant_toInt(data.get());
        QCOMPARE(value, 20);
    }

    void testBool()
    {
        VoidPointer data(dos_qvariant_create_bool(false), &dos_qvariant_delete);
        Q_ASSERT(data.get());
        QCOMPARE(dos_qvariant_isnull(data.get()), false);
        bool value = dos_qvariant_toBool(data.get());
        QCOMPARE(value, false);
        dos_qvariant_setBool(data.get(), true);
        value = dos_qvariant_toBool(data.get());
        QCOMPARE(value, true);
    }

    void testFloat()
    {
        VoidPointer data(dos_qvariant_create_float(float(5.5)), &dos_qvariant_delete);
        Q_ASSERT(data.get());
        QCOMPARE(dos_qvariant_isnull(data.get()), false);
        float value = dos_qvariant_toFloat(data.get());
        QCOMPARE(value, float(5.5));
        dos_qvariant_setFloat(data.get(), float(10.3));
        value = dos_qvariant_toFloat(data.get());
        QCOMPARE(value, float(10.3));

    }

    void testDouble()
    {
        VoidPointer data(dos_qvariant_create_double(double(5.5)), &dos_qvariant_delete);
        Q_ASSERT(data.get());
        QCOMPARE(dos_qvariant_isnull(data.get()), false);
        double value = dos_qvariant_toDouble(data.get());
        QCOMPARE(value, double(5.5));
        dos_qvariant_setDouble(data.get(), double(10.3));
        value = dos_qvariant_toDouble(data.get());
        QCOMPARE(value, double(10.3));
    }

    void testString()
    {
        VoidPointer data(dos_qvariant_create_string("Foo"), &dos_qvariant_delete);
        Q_ASSERT(data.get());
        QCOMPARE(dos_qvariant_isnull(data.get()), false);
        char *value = dos_qvariant_toString(data.get());
        std::string copy (value);
        dos_chararray_delete(value);
        QCOMPARE(copy, std::string("Foo"));
        dos_qvariant_setString(data.get(), "Bar");
        value = dos_qvariant_toString(data.get());
        copy = std::string(value);
        dos_chararray_delete(value);
        QCOMPARE(copy, std::string("Bar"));
    }

    void testQObject()
    {
        unique_ptr<MockQObject> testObject(new MockQObject());
        testObject->setObjectName("testObject");
        testObject->setName("foo");

        VoidPointer data(dos_qvariant_create_qobject(testObject->data()), &dos_qvariant_delete);
        auto value = dos_qvariant_toQObject(data.get());
        QVERIFY(value == testObject->data());
        dos_qvariant_setQObject(data.get(), nullptr);
        value = dos_qvariant_toQObject(data.get());
        QVERIFY(value == nullptr);
    }

    void testQVariant()
    {
        QVariant original("foo");
        QVERIFY(original.type() == QVariant::String);
        VoidPointer copyPointer(dos_qvariant_create_qvariant(&original), &dos_qvariant_delete);
        QVariant* copy = static_cast<QVariant*>(copyPointer.get());
        QCOMPARE(copy->type(), original.type());
        QCOMPARE(copy->toString().toStdString(), original.toString().toStdString());
    }

    void testArray()
    {
        std::vector<DosQVariant *> data ({
            dos_qvariant_create_int(10),
            dos_qvariant_create_double(4.3),
            dos_qvariant_create_bool(false),
            dos_qvariant_create_string("FooBar")
        });

        VoidPointer variant (dos_qvariant_create_array(data.size(), &data[0]), &dos_qvariant_delete);

        DosQVariantArray *array = dos_qvariant_toArray(variant.get());
        QVERIFY(array);
        QCOMPARE(int(data.size()), array->size);
        QCOMPARE(dos_qvariant_toInt(array->data[0]), int(10));
        QCOMPARE(dos_qvariant_toDouble(array->data[1]), double(4.3));
        QCOMPARE(dos_qvariant_toBool(array->data[2]), false);
        dos_qvariantarray_delete(array);

        std::for_each(data.begin(), data.end(), &dos_qvariant_delete);
    }
};

/*
 * Test QUrl
 */
class TestQUrl : public QObject
{
    Q_OBJECT

private slots:
    void testCreate()
    {
        const string testUrl("http://www.qt.io");
        VoidPointer url(dos_qurl_create(testUrl.c_str(), QUrl::StrictMode), &dos_qurl_delete);
        QVERIFY(url.get());
        QVERIFY(dos_qurl_isValid(url.get()));
        CharPointer str (dos_qurl_to_string(url.get()), &dos_chararray_delete);
        QCOMPARE(std::string(str.get()), testUrl);
    }
};

/*
 * Test QQmlApplicationEngine
 */
class TestQQmlApplicationEngine : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        m_engine = nullptr;
    }

    void cleanupTestCase()
    {
        QVERIFY(m_engine == nullptr);
    }

    void init()
    {
        QVERIFY(m_engine == nullptr);
        m_engine = dos_qqmlapplicationengine_create();
        QVERIFY(m_engine != nullptr);
    }

    void cleanup()
    {
        dos_qqmlapplicationengine_delete(m_engine);
        m_engine = nullptr;
    }

    void testCreateAndDelete()
    {
        // Implicit by invoking init and cleanup
    }

    void testLoadUrl()
    {
        void *url = dos_qurl_create("qrc:///main.qml", QUrl::TolerantMode);
        QVERIFY(url != nullptr);
        dos_qqmlapplicationengine_load_url(m_engine, url);
        QCOMPARE(engine()->rootObjects().size(), 1);
        QCOMPARE(engine()->rootObjects().front()->objectName(), QString::fromLocal8Bit("testWindow"));
        QVERIFY(engine()->rootObjects().front()->isWindowType());
        dos_qurl_delete(url);
    }

    void testLoadData()
    {
        dos_qqmlapplicationengine_load_data(m_engine, "import QtQuick 2.3; import QtQuick.Controls 1.2; ApplicationWindow { objectName: \"testWindow\"}");
        QCOMPARE(engine()->rootObjects().size(), 1);
        QCOMPARE(engine()->rootObjects().front()->objectName(), QString::fromLocal8Bit("testWindow"));
        QVERIFY(engine()->rootObjects().front()->isWindowType());
    }

private:
    QQmlApplicationEngine *engine()
    {
        return static_cast<QQmlApplicationEngine *>(m_engine);
    }

    void *m_engine;
};

/*
 * Test QQmlContext
 */
class TestQQmlContext : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        m_engine = nullptr;
        m_context = nullptr;
    }

    void cleanupTestCase()
    {
        QVERIFY(m_engine == nullptr);
        QVERIFY(m_context == nullptr);
    }

    void init()
    {
        m_engine = dos_qqmlapplicationengine_create();
        m_context = dos_qqmlapplicationengine_context(m_engine);
        QVERIFY(m_engine != nullptr);
        QVERIFY(m_context != nullptr);
    }

    void cleanup()
    {
        m_context = nullptr;
        dos_qqmlapplicationengine_delete(m_engine);
        m_engine = nullptr;
    }

    void testCreateAndDelete()
    {
        // Implicit by invoking init and cleanup
    }

    void testSetContextProperty()
    {
        QVariant testData("Test Message");
        dos_qqmlcontext_setcontextproperty(m_context, "testData", &testData);
        engine()->loadData("import QtQuick 2.3; Text { objectName: \"label\"; text: testData } ");
        QObject *label = engine()->rootObjects().first();
        QVERIFY(label != nullptr);
        QCOMPARE(label->objectName(), QString::fromLocal8Bit("label"));
        QCOMPARE(label->property("text").toString(), testData.toString());
    }

private:
    QQmlApplicationEngine *engine()
    {
        return static_cast<QQmlApplicationEngine *>(m_engine);
    }
    QQmlContext *context()
    {
        return static_cast<QQmlContext *>(m_context);
    }

    void *m_engine;
    void *m_context;
};


/*
 * Test QObject
 */
class TestQObject : public QObject
{
    Q_OBJECT

private slots:
    void init()
    {
        testObject.reset(new MockQObject());
        testObject->setObjectName("testObject");
        testObject->setName("foo");

        engine.reset(new QQmlApplicationEngine());
        engine->rootContext()->setContextProperty("testObject", QVariant::fromValue<QObject *>(static_cast<QObject *>(testObject->data())));
        engine->load(QUrl("qrc:///testQObject.qml"));
    }

    void cleanup()
    {
        engine.reset();
        testObject.reset();
    }

    void testObjectName()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testObjectName", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testPropertyReadAndWrite()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testPropertyReadAndWrite", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testPropertyGetSet() {
        MockQObject testobject;
        QObject *data = static_cast<QObject *>(testobject.data());
        data->setProperty("name", "foo");
        {
            VoidPointer valuePtr(dos_qobject_property(data, "name"), &dos_qvariant_delete);
            auto value = *static_cast<QVariant *>(valuePtr.get());
            QVERIFY(value.type() == QVariant::String);
            QVERIFY(value.toString() == "foo");
        }
        QVariant bar("bar");
        dos_qobject_setProperty(data, "name", &bar);

        {
            VoidPointer valuePtr(dos_qobject_property(data, "name"), &dos_qvariant_delete);
            auto value = *static_cast<QVariant *>(valuePtr.get());
            QVERIFY(value.type() == QVariant::String);
            QVERIFY(value.toString() == "bar");
        }
    }

    void testSignalEmittion()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testSignalEmittion", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testArrayProperty()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testArrayProperty", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

private:
    QString value;
    unique_ptr<MockQObject> testObject;
    unique_ptr<QQmlApplicationEngine> engine;
};

/*
 * Test QAbstractItemModel
 */
class TestQAbstractItemModel : public QObject
{
    Q_OBJECT

private slots:
    void init()
    {
        testObject.reset(new MockQAbstractItemModel());
        testObject->setObjectName("testObject");
        testObject->setName("foo");

        engine.reset(new QQmlApplicationEngine());
        engine->rootContext()->setContextProperty("testObject", QVariant::fromValue<QObject *>(static_cast<QObject *>(testObject->data())));
        engine->load(QUrl("qrc:///testQAbstractItemModel.qml"));
    }

    void cleanup()
    {
        engine.reset();
        testObject.reset();
    }

    void testObjectName()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testObjectName", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testPropertyReadAndWrite()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testPropertyReadAndWrite", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testSignalEmittion()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testSignalEmittion", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testRowCount()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testRowCount", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testColumnCount()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testColumnCount", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testData()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testData", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testSetData()
    {
        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testSetData", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }


private:
    QString value;
    unique_ptr<MockQAbstractItemModel> testObject;
    unique_ptr<QQmlApplicationEngine> engine;
};

/*
 * Test QDeclarative
 */
class TestQDeclarativeIntegration : public QObject
{
    Q_OBJECT

private slots:
    void testQmlRegisterType()
    {
        ::QmlRegisterType registerType;
        registerType.major = 1;
        registerType.minor = 0;
        registerType.uri = "MockModule";
        registerType.qml = "MockQObject";
        registerType.staticMetaObject = MockQObject::staticMetaObject();
        registerType.createDObject = &mockQObjectCreator;
        registerType.deleteDObject = &mockQObjectDeleter;
        dos_qdeclarative_qmlregistertype(&registerType);

        auto engine = make_unique<QQmlApplicationEngine>();
        engine->load(QUrl("qrc:///testQDeclarative.qml"));

        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testQmlRegisterType", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

    void testQmlRegisterSingletonType()
    {
        ::QmlRegisterType registerType;
        registerType.major = 1;
        registerType.minor = 0;
        registerType.uri = "MockModule";
        registerType.qml = "MockQObjectSingleton";
        registerType.staticMetaObject = MockQObject::staticMetaObject();
        registerType.createDObject = &mockQObjectCreator;
        registerType.deleteDObject = &mockQObjectDeleter;
        dos_qdeclarative_qmlregistersingletontype(&registerType);

        auto engine = make_unique<QQmlApplicationEngine>();
        engine->load(QUrl("qrc:///testQDeclarative.qml"));

        QObject *testCase = engine->rootObjects().first();
        QVERIFY(testCase);
        QVariant result;
        QVERIFY(QMetaObject::invokeMethod(testCase, "testQmlRegisterSingletonType", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.type() == QVariant::Bool);
        QVERIFY(result.toBool());
    }

private:
    static void mockQObjectCreator(int typeId, void *wrapper, void **mockQObjectPtr, void **dosQObject)
    {
        VoidPointer data(wrapper, &emptyVoidDeleter);
        auto mockQObject = new MockQObject();
        mockQObject->swapData(data);
        *dosQObject = data.release();
        *mockQObjectPtr = mockQObject;
    }

    static void mockQObjectDeleter(int typeId, void *mockQObject)
    {
        auto temp = static_cast<MockQObject *>(mockQObject);
        delete temp;
    }

    static void emptyVoidDeleter(void *) {}
};


/*
 * Test QModelIndex
 */
class TestQModelIndex : public QObject
{
    Q_OBJECT

private slots:
    void testCreate()
    {
        VoidPointer index (dos_qmodelindex_create(), &dos_qmodelindex_delete);
        QVERIFY(index.get());
        QVERIFY(!dos_qmodelindex_isValid(index.get()));
    }

    void testRow()
    {

        VoidPointer index (dos_qmodelindex_create(), &dos_qmodelindex_delete);
        QVERIFY(index.get());
        QVERIFY(!dos_qmodelindex_isValid(index.get()));
        QCOMPARE(dos_qmodelindex_row(index.get()), -1);
    }

    void testColumn()
    {

        VoidPointer index (dos_qmodelindex_create(), &dos_qmodelindex_delete);
        QVERIFY(index.get());
        QVERIFY(!dos_qmodelindex_isValid(index.get()));
        QCOMPARE(dos_qmodelindex_column(index.get()), -1);
    }

    void testParent()
    {

        VoidPointer index (dos_qmodelindex_create(), &dos_qmodelindex_delete);
        QVERIFY(index.get());
        QVERIFY(!dos_qmodelindex_isValid(index.get()));
        VoidPointer parentIndex (dos_qmodelindex_parent(index.get()), &dos_qmodelindex_delete);
        QVERIFY(parentIndex.get());
        QVERIFY(!dos_qmodelindex_isValid(parentIndex.get()));
    }

    void testChild()
    {
        VoidPointer index (dos_qmodelindex_create(), &dos_qmodelindex_delete);
        QVERIFY(index.get());
        QVERIFY(!dos_qmodelindex_isValid(index.get()));
        VoidPointer childIndex (dos_qmodelindex_child(index.get(), 0, 0), &dos_qmodelindex_delete);
        QVERIFY(childIndex.get());
        QVERIFY(!dos_qmodelindex_isValid(childIndex.get()));
    }

    void testSibling()
    {
        VoidPointer index (dos_qmodelindex_create(), &dos_qmodelindex_delete);
        QVERIFY(index.get());
        QVERIFY(!dos_qmodelindex_isValid(index.get()));
        VoidPointer siblingIndex (dos_qmodelindex_sibling(index.get(), 0, 0), &dos_qmodelindex_delete);
        QVERIFY(siblingIndex.get());
        QVERIFY(!dos_qmodelindex_isValid(siblingIndex.get()));
    }

    void testData()
    {
        VoidPointer index (dos_qmodelindex_create(), &dos_qmodelindex_delete);
        QVERIFY(index.get());
        QVERIFY(!dos_qmodelindex_isValid(index.get()));
        VoidPointer data(dos_qmodelindex_data(index.get(), Qt::DisplayRole), &dos_qvariant_delete);
        QVERIFY(data.get());
        QVERIFY(dos_qvariant_isnull(data.get()));
    }
};

/*
 * Test QQuickView
 */
class TestQQuickView : public QObject
{
    Q_OBJECT

private slots:
    void testCreate()
    {
        VoidPointer view(dos_qquickview_create(), &dos_qquickview_delete);
        QVERIFY(view.get());
    }

    void testSourceAndSetSource()
    {
        std::string testUrl = "qrc:/testQQuickView.qml";
        VoidPointer view(dos_qquickview_create(), &dos_qquickview_delete);
        VoidPointer url(dos_qurl_create(testUrl.c_str(), QUrl::StrictMode), &dos_qurl_delete);
        dos_qquickview_set_source_url(view.get(), url.get());
        CharPointer tempUrl(dos_qquickview_source(view.get()), &dos_chararray_delete);
        QCOMPARE(std::string(tempUrl.get()), testUrl);
        dos_qquickview_show(view.get());
    }
};

int main(int argc, char *argv[])
{
    using namespace DOS;

    bool success = true;
    success &= ExecuteTest<TestQGuiApplication>(argc, argv);
    success &= ExecuteTest<TestQVariant>(argc, argv);
    success &= ExecuteTest<TestQUrl>(argc, argv);
    success &= ExecuteTest<TestQModelIndex>(argc, argv);
    success &= ExecuteGuiTest<TestQQmlApplicationEngine>(argc, argv);
    success &= ExecuteGuiTest<TestQQmlContext>(argc, argv);
    success &= ExecuteGuiTest<TestQObject>(argc, argv);
    success &= ExecuteGuiTest<TestQAbstractItemModel>(argc, argv);
    success &= ExecuteGuiTest<TestQDeclarativeIntegration>(argc, argv);
    success &= ExecuteGuiTest<TestQQuickView>(argc, argv);
    return success ? 0 : 1;
}

#include "test_dotherside.moc"
