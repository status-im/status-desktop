import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../imports"
import "../../shared"
import "../../shared/status"

Item {
    id: control
    property string selectedColor
    //% "Account color"
    property string label: qsTrId("account-color")
    property var model: Style.current.accountColors
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
            StatusWalletColorButton {
                id: colorBtn
                icon.color: modelData
                selected: {
                    const upperCaseColor = control.selectedColor.toUpperCase()
                    const upperCaseModelDataColor = modelData.toString().toUpperCase()
                    if (upperCaseColor === upperCaseModelDataColor) {
                        return true
                    }
                    // Check the colors in the other theme
                    const currentColor = Utils.getCurrentThemeAccountColor(upperCaseColor)
                    if (!currentColor) {
                        return false
                    }

                    return currentColor === upperCaseModelDataColor
                }
                onClicked: {
                    control.selectedColor = modelData.toUpperCase()
                }
            }
        }
    }
}

