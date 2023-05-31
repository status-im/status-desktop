import QtQuick 2.15
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

/*!
   \qmltype StatusTabButton
   \inherits TabButton
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief StatusTabButton is used in conjunction with a StatusTabBar

   It's customized from Qt's \l{https://doc.qt.io/qt-6/qml-qtquick-controls2-tabbutton.html}{TabButton}, adding:
    - transparent background
    - theme-styled text
    - styled underscore for active state
    - `StatusBadge` to the right from the text

   An alias `badge` property is added to control the `StatusBadge` behaviour and content.
*/

TabButton {
    id: root

    readonly property alias badge: statusBadge

    leftPadding: 12
    rightPadding: 12

    background: Item {
        HoverHandler {
            target: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
            enabled: root.enabled
        }
    }

    contentItem: Item {
        implicitWidth: contentItemGrid.implicitWidth
        implicitHeight: contentItemGrid.implicitHeight + 15

        enabled: root.enabled

        RowLayout {
            id: contentItemGrid

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            spacing: 0

            StatusBaseText {
                Layout.fillWidth: true
                elide: Qt.ElideRight
                font.weight: Font.Medium
                font.pixelSize: 15
                color: root.checked || root.hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
                text: root.text
            }

            StatusBadge {
                id: statusBadge
                Layout.leftMargin: 10
                visible: value > 0
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.enabled && (root.checked || root.hovered)
            implicitWidth: 24
            implicitHeight: 2
            radius: 4
            color: root.checked ? Theme.palette.primaryColor1 : Theme.palette.primaryColor2
        }
    }
}
