import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

StatusPasswordInput {
    id: root

    required property bool isBiometricsLogin
    required property bool biometricsSuccessful
    required property bool biometricsFailed

    signal biometricsRequested()

    rightPadding: iconsLayout.width + iconsLayout.anchors.rightMargin
    placeholderText: qsTr("Password")
    echoMode: d.showPassword ? TextInput.Normal : TextInput.Password

    QtObject {
        id: d
        property bool showPassword
    }

    RowLayout {
        id: iconsLayout
        anchors.right: parent.right
        anchors.rightMargin: Theme.halfPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.halfPadding

        StatusIcon {
            id: showPasswordButton
            visible: root.text !== ""
            icon: d.showPassword ? "hide" : "show"
            color: hhandler.hovered ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            HoverHandler {
                id: hhandler
                cursorShape: hovered ? Qt.PointingHandCursor : undefined
            }
            TapHandler {
                onSingleTapped: d.showPassword = !d.showPassword
            }
            StatusToolTip {
                text: d.showPassword ? qsTr("Hide password") : qsTr("Reveal password")
                visible: hhandler.hovered
            }
        }
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 28
            color: Theme.palette.directColor7
            visible: showPasswordButton.visible && touchIdIndicator.visible
        }
        LoginTouchIdIndicator {
            id: touchIdIndicator
            visible: root.isBiometricsLogin
            success: root.biometricsSuccessful
            error: root.biometricsFailed
            onClicked: root.biometricsRequested()
        }
    }
}
