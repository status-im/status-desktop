import QtQuick

QtObject {
    property string name: ""
    property string errorMessage: qsTr("invalid input")
    property var validatorObj

    property var validate: function (value) {
        return true
    }
}
