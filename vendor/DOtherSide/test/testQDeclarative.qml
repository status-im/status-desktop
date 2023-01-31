import QtQuick 2.3
import MockModule 1.0

Item {
    id: testCase
    objectName: "testCase"

    Component {
        id: mockQObjectComponent

        MockQObject {}
    }

    function testMockQObject(testObject) {
        if (!testObject)
            return false

        if (testObject.name !== "foo")
            return false

        var nameChangedEmitted = false
        testObject.nameChanged.connect(function(name){nameChangedEmitted = name === "bar"});
        testObject.name = "bar"
        return nameChangedEmitted && testObject.name === "bar"
    }


    function testQmlRegisterType() {
        var testObject = mockQObjectComponent.createObject(testCase, {"name":"foo"})
        var result = testMockQObject(testObject)
        if (testObject)
            testObject.destroy()
        return result
    }

    function testQmlRegisterSingletonType() {
        var testObject = MockQObjectSingleton
        MockQObjectSingleton.name = "foo"
        return testMockQObject(testObject)
    }
}
