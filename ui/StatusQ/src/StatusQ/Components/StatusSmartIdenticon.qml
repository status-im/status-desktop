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
    }

    property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: root.asset.ringPxSize
        distinctiveColors: Theme.palette.identiconRingColors
    }

    sourceComponent: {
        if (root.loading) return loadingComp
        if (root.asset.isLetterIdenticon || root.asset.name === "") return letterIdenticon
        if (root.asset.isImage) return roundedImage
        return roundedIcon
    }

    property bool loading: false
    property bool hoverEnabled: false
    readonly property bool hovered: (sourceComponent == roundedIcon && item) ?
                     item.hovered : false
    signal clicked(var mouse)

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

        StatusRoundIcon {
            asset.bgRadius: root.asset.bgRadius
            asset.bgWidth: root.asset.bgWidth
            asset.bgHeight: root.asset.bgHeight
            asset.bgColor: root.asset.bgColor
            asset.width: root.asset.width
            asset.height: root.asset.height
            asset.name: root.asset.name
            asset.rotation: root.asset.rotation
            asset.color: root.asset.color
            asset.bgBorderWidth: root.asset.bgBorderWidth
            asset.bgBorderColor: root.asset.bgBorderColor

            signal clicked(var mouse)

            property alias hovered: mouseArea.containsMouse

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: root.hoverEnabled
                cursorShape: loading ? Qt.ArrowCursor
                                     : Qt.PointingHandCursor
                onClicked: parent.clicked(mouse)
            }
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

    Component {
        id: loadingComp
        LoadingComponent {
            anchors.centerIn: parent
            radius: width/2
            height: root.asset.isImage ? root.asset.height : root.asset.bgHeight
            width: root.asset.isImage ? root.asset.width : root.asset.bgWidth
        }
    }

    Connections {
        target: item
        enabled: status === Loader.Ready
        ignoreUnknownSignals: true

        function onClicked(mouse) {
            root.clicked(mouse)
        }
    }
}
