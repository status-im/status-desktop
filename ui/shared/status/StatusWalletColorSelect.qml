import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../imports"
import "../../shared"
import "../../shared/status"

Item {
    id: control
    property string selectedColor
    property string label: qsTr("Account color")
    property var model
    height: childrenRect.height

    StyledText {
        id: label
        text: control.label
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 13
        height: 18
    }

    RowLayout {
        id: colors
        spacing: 6
        anchors.top: label.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.left: parent.left
        anchors.right: parent.right
        Repeater {
            model: control.model
            Item {
                height: colorBtn.height
                width: colorBtn.width
                StatusWalletColorButton {
                    id: colorBtn
                    icon.color: modelData
                    selected: control.selectedColor.toUpperCase() == modelData.toUpperCase()
                    onClicked: {
                        control.selectedColor = modelData.toUpperCase()
                    }
                }
            }
        }
    }
}

