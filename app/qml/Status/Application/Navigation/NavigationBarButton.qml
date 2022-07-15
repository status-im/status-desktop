import QtQuick
import QtQuick.Controls

/// The control must be squared. User must set the \c width only, height will follow.
Item {
    required property string name
    property alias selected: iconButton.checked
    property ButtonGroup mutuallyExclusiveGroup: null

    implicitWidth: iconButton.implicitWidth
    implicitHeight: iconButton.implicitWidth
    height: width

    Button {
        id: iconButton

        anchors.fill: parent

        text: name.length ? name.charAt(0) : ""

        flat: true

        checkable: true
        hoverEnabled: true

        autoExclusive: true
        ButtonGroup.group: mutuallyExclusiveGroup

        background: Rectangle {
            radius: width/2
            border.width: 1

            color: "#4360DF"
            opacity: iconButton.checked ? 0.1 : iconButton.hovered ? 0.05 : 0
        }
    }
}
