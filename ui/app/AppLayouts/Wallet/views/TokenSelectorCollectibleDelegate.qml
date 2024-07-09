import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ItemDelegate {
    id: root

    required property string name
    required property string balance
    required property url image

    property bool goDeeperIconVisible: true
    property bool interactive: true

    spacing: Style.current.halfPadding
    horizontalPadding: Style.current.padding
    verticalPadding: 4

    opacity: interactive ? 1 : 0.3

    implicitWidth: ListView.view.width
    implicitHeight: 60

    icon.width: 32
    icon.height: 32
    icon.source: root.image

    enabled: interactive

    background: Rectangle {
        radius: Style.current.radius
        color: (root.interactive && root.hovered) || root.highlighted
               ? Theme.palette.statusListItem.highlightColor
               : "transparent"

        HoverHandler {
            cursorShape: root.interactive ? Qt.PointingHandCursor : undefined
        }
    }

    contentItem: RowLayout {
        spacing: root.spacing

        // asset icon
        StatusRoundedImage {
            Layout.preferredWidth: root.icon.width
            Layout.preferredHeight: root.icon.height
            image.source: root.icon.source
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            // name, symbol, total balance
            RowLayout {
                Layout.fillWidth: true
                spacing: root.spacing

                StatusBaseText {
                    id: nameText

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    text: root.name
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter

                    text: root.balance
                    visible: root.balance !== ""
                    color: Theme.palette.baseColor1
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                StatusIcon {
                    Layout.alignment: Qt.AlignVCenter

                    icon: "tiny/chevron-right"
                    visible: root.goDeeperIconVisible
                    color: Theme.palette.baseColor1
                    width: 16
                    height: 16
                }
            }
        }
    }
}
