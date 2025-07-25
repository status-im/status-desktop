import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Utils
import StatusQ.Core.Theme
import StatusQ.Controls

Item {
    id: control
    property string selectedColor
    property string label: qsTr("Account color")
    property var model
    property bool enabled: true

    height: childrenRect.height
    implicitWidth: 480

    StatusBaseText {
        id: label
        text: control.label
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: Theme.primaryTextFontSize
        color: control.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
    }

    RowLayout {
        id: colors
        spacing: 6
        anchors.top: label.bottom
        anchors.topMargin: 8
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
                    const currentColor = Utils.getThemeAccountColor(upperCaseColor, Theme.palette.userCustomizationColors)
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
