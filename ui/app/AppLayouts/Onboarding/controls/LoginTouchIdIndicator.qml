import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

StatusIcon {
    id: root

    property bool success
    property bool error

    signal clicked()

    icon: "touch-id"
    color: root.success ? Theme.palette.successColor1
                        : root.error ? Theme.palette.dangerColor1
                                     : hhandler.hovered ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
    HoverHandler {
        id: hhandler
        cursorShape: hovered ? Qt.PointingHandCursor : undefined
    }
    TapHandler {
        onSingleTapped: root.clicked()
    }
    StatusToolTip {
        text: root.success ? qsTr("Biometrics successful")
                           : root.error ? qsTr("Biometrics failed")
                                        : qsTr("Request biometrics prompt again")
        visible: hhandler.hovered
    }
}
