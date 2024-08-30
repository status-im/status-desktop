import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

RowLayout {
    id: root

    property string textRole: "text"
    property string valueRole: "value"

    property alias model: repeater.model
    property var value: null

    spacing: 8

    signal buttonClicked()

    Repeater {
        id: repeater

        objectName: "buttonsRepeater"

        delegate: StatusButton {
            readonly property var value: model[root.valueRole]

            Layout.minimumWidth: 100
            Layout.fillWidth: true

            type: checked ? StatusBaseButton.Type.Primary
                          : StatusBaseButton.Type.Normal

            checkable: true
            checked: value === root.value
            text: model[root.textRole]

            onClicked: {
                root.value = value
                root.buttonClicked()
            }
        }
    }
}
