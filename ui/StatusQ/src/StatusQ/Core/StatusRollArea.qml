import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property alias content: contentLoader.sourceComponent
    property color arrowsGradientColor: Theme.palette.statusAppLayout.backgroundColor

    implicitHeight: contentLoader.height

    StatusScrollView {
        id: roll

        anchors.fill: parent
        padding: 0
        contentWidth: contentLoader.width

        StatusScrollBar.horizontal.policy: StatusScrollBar.AlwaysOff

        Loader {
            id: contentLoader
        }
    }

    StatusNavigationButton {
        anchors.left: parent.left
        height: parent.height
        visible: roll.flickable.contentX > 0
        gradientColor: root.arrowsGradientColor

        onClicked: roll.flickable.flick(roll.width, 0)
    }

    StatusNavigationButton {
        anchors.right: parent.right
        height: parent.height
        visible: roll.flickable.contentX + roll.width < roll.contentWidth
        gradientColor: root.arrowsGradientColor
        navigateForward: true

        onClicked: roll.flickable.flick(-roll.width, 0)
    }
}
