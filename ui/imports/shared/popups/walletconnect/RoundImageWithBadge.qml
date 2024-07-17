import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Item {
    id: root

    property url imageUrl: ""
    property string badgeIcon: "walletconnect"
    property string fallbackIcon: "dapp"

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
            }        }

        layer.enabled: true
        layer.effect: OpacityMask {
            id: mask
            invert: true

            maskSource: Item {
                width: mask.width + 2
                height: mask.height + 2

                Rectangle {
                    x: badge.x + 1
                    y: badge.y + 1

                    width: badge.width + 2
                    height: badge.width + 2
                    radius: badge.width / 2
                }
            }
        }
    }

    StatusRoundIcon {
        id: badge
        width: root.width / 3.6
        height: width
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        asset.name: root.badgeIcon
        asset.color: "transparent"
        asset.width: width
        asset.height: height
        asset.bgWidth: width
        asset.bgHeight: height
    }
}
