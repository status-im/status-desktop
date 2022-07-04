import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Onboarding
import Status.Controls.Navigation

/*! Template to guide the onboarding layout
 */
Item {
    id: root

    property bool backAvailable: true

    /// All done in the current page
    signal pageDone()
    signal goBack()

    Button {
        id: backButton
        text: "<"

        anchors {
            left: parent.left
            margins: 16
            bottom: parent.bottom
        }

        visible: root.backAvailable
        flat: true
        background: Rectangle {
            height: width
            radius: width/2
            color: "#4360DF"
            opacity: parent.hovered ? parent.pressed ? 1 : 0.5 : 0.1
        }

        onClicked: root.goBack()
    }
}
