import QtQuick 2.15
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

Control {
    id: root

    // https://bugreports.qt.io/browse/QTBUG-84269
    /*required*/ property bool isOwner

    property bool showTag: false
    property int size: PrivilegedTokenArtworkPanel.Size.Small

    property alias artwork: image.source
    property alias color: icon.color

    QtObject {
        id: d

        readonly property int imageSize: ({
                                              [PrivilegedTokenArtworkPanel.Size.Small]: 80,
                                              [PrivilegedTokenArtworkPanel.Size.Medium]: 109,
                                              [PrivilegedTokenArtworkPanel.Size.Large]: 186
                                          }[size])

        readonly property int bgSize: ({
                                           [PrivilegedTokenArtworkPanel.Size.Small]: 120,
                                           [PrivilegedTokenArtworkPanel.Size.Medium]: 164,
                                           [PrivilegedTokenArtworkPanel.Size.Large]: 280
                                       }[size])

        readonly property int iconSize: ({
                                             [PrivilegedTokenArtworkPanel.Size.Small]: 14,
                                             [PrivilegedTokenArtworkPanel.Size.Medium]: 24,
                                             [PrivilegedTokenArtworkPanel.Size.Large]: 38
                                         }[size])

        readonly property int iconMargins: ({
                                                [PrivilegedTokenArtworkPanel.Size.Small]: 8,
                                                [PrivilegedTokenArtworkPanel.Size.Medium]: 10,
                                                [PrivilegedTokenArtworkPanel.Size.Large]: 16
                                            }[size])
    }

    enum Size {
        Small,
        Medium,
        Large
    }

    implicitWidth: d.bgSize
    implicitHeight: implicitWidth

    background: Rectangle {
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
        radius: 8
        border.color: Theme.palette.baseColor2
    }

    contentItem: Item {
        StatusTagItem {
            visible: root.showTag
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: -height/2
            height: 20
            text: qsTr("Included")
            font.pixelSize: 11
            font.bold: true
            isReadonly: true
            background: Rectangle {
                color: Theme.palette.primaryColor1
                radius: 38
            }
        }

        Image {
            id: image

            anchors.centerIn: parent
            width: d.imageSize
            height: width
            fillMode: Image.PreserveAspectFit
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: image.width
                    height: width
                    radius: width / 2
                }
            }
        }

        StatusIcon {
            id: icon

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: d.iconMargins
            width: d.iconSize
            height: width
            icon: root.isOwner ? "crown" : "token-sale"
        }
    }
}
