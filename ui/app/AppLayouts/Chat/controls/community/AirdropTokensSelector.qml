import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

StatusFlowSelector {
    id: root

    property alias model: repeater.model
    readonly property alias count: repeater.count

    signal itemClicked(int index, var mouse, var item)

    placeholderText: qsTr("Example: 1 SOCK")
    placeholderItem.visible: repeater.count === 0

    title: qsTr("What")
    icon: Style.svg("token")

    QtObject {
        id: d

        readonly property int commonMargin: 6
        readonly property int iconSize: 28
    }

    Repeater {
        id: repeater

        Control {
            id: delegateRoot

            component Icon: StatusRoundedImage {
                implicitWidth: d.iconSize
                implicitHeight: d.iconSize

                image.mipmap: true
            }

            component Text: StatusBaseText {
                Layout.fillWidth: true

                font.weight: Font.Medium
                color: model.valid ? Theme.palette.primaryColor1
                                   : Theme.palette.dangerColor1
                elide: Text.ElideRight
            }

            implicitHeight: root.placeholderItemHeight
            leftPadding: (root.placeholderItemHeight - d.iconSize) / 2
            rightPadding: d.commonMargin * 2

            background: Rectangle {
                color: model.valid ? Theme.palette.primaryColor3
                                   : Theme.palette.dangerColor3
                radius: root.placeholderItemHeight / 2

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.itemClicked(model.index, mouse, delegateRoot)
                }
            }

            contentItem: RowLayout {
                spacing: d.commonMargin

                Icon {
                    image.source: model.tokenImage
                }

                Text {
                    text: qsTr("%1 on", "It means that a given token is deployed 'on' a given network, e.g. '2 MCT on Ethereum'. The name of the network is preceded by an icon, so it is not part of this phrase.")
                    .arg(model.tokenText)
                }

                Icon {
                    image.source: model.networkImage
                }

                Text {
                    text: model.networkText
                }
            }
        }
    }
}
