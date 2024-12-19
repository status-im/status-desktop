import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

/*!
   \qmltype StatusTabButton
   \inherits TabButton
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief StatusTabButton is used in conjunction with a StatusTabBar

   It's customized from Qt's \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-tabbutton.html}{TabButton}, adding:
    - transparent background
    - theme-styled text
    - styled underscore for active state
    - `StatusBadge` to the right from the text

   An alias `badge` property is added to control the `StatusBadge` behaviour and content.
*/

TabButton {
    id: root

    readonly property alias badge: statusBadge

    horizontalPadding: 0

    background: null

    font.family: Theme.baseFont.name
    font.weight: Font.Medium
    font.pixelSize: Theme.primaryTextFontSize

    opacity: enabled ? 1 : Theme.disabledOpacity

    spacing: Theme.smallPadding

    contentItem: ColumnLayout {
        spacing: root.spacing
        RowLayout {
            Layout.fillWidth: true
            spacing: root.spacing

            StatusBaseText {
                Layout.fillWidth: true
                elide: Qt.ElideRight
                font: root.font
                color: !enabled ? Theme.palette.baseColor1 : root.checked || root.hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
                Behavior on color {ColorAnimation {duration: Theme.AnimationDuration.Fast}}
                text: root.text
            }

            StatusBadge {
                id: statusBadge
                visible: value > 0
            }
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            Layout.preferredWidth: 24
            Layout.preferredHeight: 2
            opacity: root.checked || root.hovered ? 1 : 0
            Behavior on opacity {OpacityAnimator {duration: Theme.AnimationDuration.Fast}}
            radius: 4
            color: root.checked ? Theme.palette.primaryColor1 : Theme.palette.primaryColor2
            Behavior on color {ColorAnimation {duration: Theme.AnimationDuration.Fast}}
        }
    }

    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
    }
}
