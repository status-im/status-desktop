import QtQuick.Layouts 1.14
import QtQuick 2.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

ColumnLayout {
    id: root

    signal operatorSelected(int operator)

    spacing: 8

    Repeater {
        model: [
            {
                icon: "add",
                text: qsTr("And..."),
                operator: OperatorsUtils.Operators.And
            },
            {
                icon: "condition-Or",
                text: qsTr("Or..."),
                operator: OperatorsUtils.Operators.Or
            }
        ]

        delegate: StatusPickerButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            horizontalPadding: 12
            spacing: 10
            bgColor: Theme.palette.primaryColor3
            contentColor: Theme.palette.primaryColor1
            asset.name: Style.svg(modelData.icon)
            asset.isImage: true
            asset.height: 12
            asset.width: 12
            text: modelData.text
            font.pixelSize: 13

            onClicked: root.operatorSelected(modelData.operator)
        }
    }
}
