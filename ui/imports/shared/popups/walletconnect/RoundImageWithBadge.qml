import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Item {
    id: root

    property url imageUrl: ""
    property url badgeIcon: ""
    property real badgeSize: 0
    property real badgeMargin: 0

    readonly property bool iconLoaded: !mainImage.isError && !mainImage.isLoading && mainImage.image.source !== ""

    implicitWidth: mainImage.implicitWidth
    implicitHeight: mainImage.implicitHeight

    Item {
        id: imageContainer

        width: parent.width
        height: width

        StatusRoundedImage {
            id: mainImage

            width: parent.width
            height: width
            visible: !isError && !isLoading && root.imageUrl != ""
            image.source: root.imageUrl
        }

        Loader {
            anchors.fill: mainImage
            active: !mainImage.visible
            sourceComponent: StatusRoundedComponent {
                id: imageWrapper
                color: Theme.palette.primaryColor3
                StatusIcon {
                    anchors.fill: imageWrapper
                    anchors.margins: imageWrapper.width / 4.5
                    color: Theme.palette.primaryColor1
                    icon: "dapp"
                }
            }
        }

        layer.enabled: badge.visible
        layer.effect: OpacityMask {
            id: mask
            invert: true

            maskSource: Item {
                width: mask.width
                height: mask.height

                Rectangle {
                    x: badge.x - badgeMargin
                    y: badge.y - badgeMargin

                    width: badge.width + badgeMargin * 2
                    height: badge.width + badgeMargin * 2
                    radius: width / 2
                }
            }
        }
    }

    StatusRoundedImage {
        id: badge
        width: root.badgeSize
        height: width
        visible: image.source != "" && !isLoading && !isError
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        image.source: root.badgeIcon
    }
}
