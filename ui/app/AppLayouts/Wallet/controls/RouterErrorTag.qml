import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Control {
    id: root

    property alias errorTitle: errorTitle.text
    property alias buttonText: addBalanceButton.text
    property alias errorDetails: errorDetails.text
    property alias icon: errorIcon.icon
    property bool expandable

    signal buttonClicked()

    padding: Theme.halfPadding
    leftPadding: 12

    background: Rectangle {
        radius: 8
        color: Theme.palette.dangerColor3
        border.width: 1
        border.color: Theme.palette.dangerColor2
    }

    contentItem: ColumnLayout {
        RowLayout {
            spacing: Theme.halfPadding
            StatusIcon {
                id: errorIcon

                objectName: "errorIcon"

                Layout.alignment: Qt.AlignVCenter

                icon: "warning"
                color: Theme.palette.dangerColor1
            }
            StatusBaseText {
                id: errorTitle

                objectName: "errorTitle"

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                color: Theme.palette.dangerColor1
                font.pixelSize: Theme.additionalTextSize
            }
            StatusButton {
                id: addBalanceButton

                objectName: "addBalanceButton"

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                size: StatusBaseButton.Size.Small
                type: StatusBaseButton.Type.Danger
                normalColor: Theme.palette.dangerColor1
                hoverColor: Theme.palette.hoverColor(normalColor)
                textColor: Theme.palette.indirectColor1

                onClicked: root.buttonClicked()

                visible: !root.expandable && !!text
            }
            StatusButton {
                id: expandButton

                objectName: "expandButton"

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                checkable: true
                size: StatusBaseButton.Size.Small
                normalColor: Theme.palette.transparent
                hoverColor: Theme.palette.transparent
                textColor: Theme.palette.dangerColor1
                textHoverColor: Theme.palette.hoverColor(textColor)
                font.pixelSize: Theme.tertiaryTextFontSize
                font.weight: Font.Normal
                text: checked ? qsTr("- Hide details") : qsTr("+ Show details")

                visible: root.expandable
            }
        }
        StatusBaseText {
            id: errorDetails

            objectName: "errorDetails"

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: errorIcon.width + Theme.halfPadding

            color: Theme.palette.dangerColor1
            font.pixelSize: Theme.additionalTextSize
            elide: Text.ElideRight

            visible: root.expandable ? expandButton.checked : !!text
        }
    }
}
