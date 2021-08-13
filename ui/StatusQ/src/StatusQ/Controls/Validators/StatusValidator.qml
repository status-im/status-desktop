import QtQuick 2.13

QtObject {
    id: statusValidator

    property string name: ""

    property var validate: function (value) {
        return true
    }
}
