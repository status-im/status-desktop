import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Loader {
    id: root

    property string name: ""
    property int dZ: 100

    // Badge color properties must be set if badgeItem.visible = true
    property alias badge: statusBadge

    property StatusAssetSettings asset: StatusAssetSettings {
        width: 40
        height: 40
        bgRadius: bgWidth / 2
        // onColorChanged: console.log("StatusSmartIdenticon asset color:", color)

        property StatusAssetSettings iconAsset: StatusAssetSettings {
        }
    }

    property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: root.asset.ringPxSize
        distinctiveColors: Theme.palette.identiconRingColors
    }

    sourceComponent: (root.asset.isLetterIdenticon || root.asset.name === "") ? letterIdenticon :
                     !root.asset.isImage ? roundedIcon : roundedImage

    property bool hoverEnabled: false
    readonly property bool hovered: (sourceComponent == roundedIcon && item) ?
                     item.hovered : false

    Component {
        id: roundedImage

        Item {
            width: root.asset.width
            height: root.asset.height

            StatusRoundedImage {
                id: statusRoundImage
                width: parent.width
                height: parent.height
                image.source: root.asset.name
                showLoadingIndicator: true
                border.width: root.asset.imgIsIdenticon ? 1 : 0
                border.color: Theme.palette.directColor7
                color: root.asset.imgIsIdenticon ?
                           Theme.palette.statusRoundedImage.backgroundColor :
                           root.asset.bgColor
                image.fillMode: Image.PreserveAspectCrop
            }
            Loader {
                anchors.centerIn: parent
                active: root.asset.imgStatus === Image.Error ||
                        statusRoundImage.image.status === Image.Error
                sourceComponent: letterIdenticon
                onLoaded: {
                    item.color = Theme.palette.miscColor5
                    item.width = root.asset.width
                    item.height = root.asset.height
                }
            }
        }
    }

    Component {
        id: roundedIcon

        StatusRoundButton {
            icon.width: root.asset.width
            icon.height: root.asset.height
            icon.name: root.asset.name
            icon.rotation: root.asset.rotation
            icon.color: root.asset.color
            icon.hoverColor: root.asset.hoverColor
            color: root.asset.bgColor
            radius: root.asset.bgRadius
            hoverEnabled: root.hoverEnabled

            // onClicked: console.log("Clicked")
            // icon.onColorChanged: console.log("Round button color changed:", icon.color)
        }
    }

    Component {
        id: letterIdenticon
        StatusLetterIdenticon {
            objectName: "statusSmartIdenticonLetter"
            width: root.asset.width
            height: root.asset.height
            color: root.asset.color
            name: root.name
            emoji: root.asset.emoji
            emojiSize: root.asset.emojiSize
            letterSize: root.asset.letterSize
            charactersLen: root.asset.charactersLen
        }
    }

    // Next components are painted above main sourceComponent
    StatusIdenticonRing {
        settings: root.ringSettings
        anchors.fill: parent
        z: root.dZ/2
    }

    // State component
    StatusBadge {
        id: statusBadge
        visible: false
        anchors.bottom: root.bottom
        anchors.right: root.right
        anchors.rightMargin: -border.width
        anchors.bottomMargin: -border.width
        border.width: 3
        implicitHeight: 15
        implicitWidth: 15
        z: root.dZ
    }
}
