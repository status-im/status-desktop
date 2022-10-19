import QtQuick 2.14
import QtQuick.Controls 2.14

GroupBox {
    title: "compilation errors"

    property var errors // QQmlError

    ScrollView {
        id: scrollView

        anchors.fill: parent
        visible: !!loader.errors
        clip: true

        TextEdit {
            id: errorsTextEdit

            width: scrollView.width
            font.family: "courier"
            selectByMouse: true
            readOnly: true

            text: !!errors ? JSON.stringify(errors.qmlErrors, null, 2) : ""
        }
    }
}
