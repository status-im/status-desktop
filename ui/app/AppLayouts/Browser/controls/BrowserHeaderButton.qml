import QtQuick

import StatusQ.Core.Theme
import StatusQ.Controls

StatusFlatRoundButton {
    id: root

    property bool incognitoMode: false

    // as per design
    implicitWidth: 40
    implicitHeight: 40

    type: StatusFlatRoundButton.Type.Tertiary
    icon.color: root.incognitoMode ?
                    Theme.palette.privacyColors.tertiary:
                    hovered ? Theme.palette.primaryColor1:
                              Theme.palette.baseColor1
    icon.disabledColor: root.incognitoMode ?
                            Theme.palette.privacyColors.tertiaryOpaque:
                            Theme.palette.baseColor2
    backgroundHoverColor: root.incognitoMode ?
                              Theme.palette.privacyColors.secondary:
                              Theme.palette.baseColor2
    sensor.acceptedButtons: Qt.LeftButton | Qt.RightButton
}
