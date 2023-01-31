import QtQuick 2.3

QtObject {
    id: testCase
    objectName: "testCase"

    function testObjectName() {
        return testObject && testObject.objectName === "testObject"
    }

    function testPropertyReadAndWrite() {
        if (!testObject)
            return false
        if (testObject.name !== "foo")
            return false
        testObject.name = "bar"
        if (testObject.name !== "bar")
            return false
        return true
    }

    function testSignalEmittion() {
        if (!testObject)
            return false
        if (testObject.name !== "foo")
            return false
        var result = false
        testObject.nameChanged.connect(function(name){ result = name === "bar" })
        testObject.name = "bar"
        return result
    }

    function testArrayProperty() {
        if (!testObject)
            return false
        var values = testObject.arrayProperty
        if (values[0] != 10 || values[1] != 5.3 || values[2] != false)
            return false
        testObject.arrayProperty = [404, 6.3, true]
        return values[0] != 404 || values[1] != 6.3 || values[2] != true
    }
}
