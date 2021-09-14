import QtQuick 2.13
import StatusQ.Controls 0.1

QtObject {
    id: statusValidator

    property string name: ""
    property string errorMessage: "invalid input"

    property var validate: function (value) {
        return true
    }
}
