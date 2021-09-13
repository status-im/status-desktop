import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status/core"

Item {
    id: root
    property string imageUrl: ""
    property string name: "CryptoKitties"
    property string slug: "cryptokitties"
    property int ownedAssetCount: 0
    property var collectibleModal
    property bool isOpened: false
    property bool assetsLoaded: false

    width: parent.width
    height: {
        if (!isOpened) {
            return header.height
        }
        
        return header.height + contentLoader.height
    }

    function toggleCollection() {
        if (root.isOpened) {
            root.isOpened = false
            return
        }

        walletV2Model.collectiblesView.loadAssets(walletV2Model.accountsView.currentAccount.address, root.slug)
        root.isOpened = true
    }

    Connections {
        target: walletV2Model.collectiblesView.getAssetsList(root.slug)
        function onAssetsChanged() {
            root.assetsLoaded = true
        }
    }

    Rectangle {
        id: header
        property bool hovered: false
        height: 64
        width: parent.width
        color: hovered ? Style.current.backgroundHover : Style.current.transparent
        border.width: 0
        radius: Style.current.radius

        Image {
            id: image
            source: root.imageUrl
            width: 40
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: root.name
            anchors.left: image.right
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 17
        }

        Item {
            anchors.right: header.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: header.verticalCenter
            width: childrenRect.width
            height: count.height

            StyledText {
                id: count
                color: Style.current.secondaryText
                text: root.ownedAssetCount
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            SVGImage {
                id: caretImg
                anchors.verticalCenter: parent.verticalCenter
                source: "../../../img/caret.svg"
                width: 11
                anchors.left: count.right
                anchors.leftMargin: Style.current.padding
                fillMode: Image.PreserveAspectFit
            }

            ColorOverlay {
                anchors.fill: caretImg
                source: caretImg
                color: Style.current.black
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: {
                header.hovered = true
            }
            onExited: {
                header.hovered = false
            }
            onClicked: {
                root.toggleCollection()
            }
        }
    }

    Loader {
        id: contentLoader
        active: root.isOpened
        width: parent.width
        anchors.top: header.bottom
        anchors.topMargin: Style.current.halfPadding
        sourceComponent: root.assetsLoaded ? loaded : loading
    }

    Component {
        id: loading
        Item {
            id: loadingIndicator
            height: 164
            StatusLoadingIndicator {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20
                height: 20
            }
        }
    }

    Component {
        id: loaded
        ScrollView {
            height: contentRow.height
            width: parent.width
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            clip: true

            Row {
                id: contentRow
                bottomPadding: Style.current.padding
                spacing: Style.current.padding

                Repeater {
                    model: walletV2Model.collectiblesView.getAssetsList(root.slug)

                    Item {
                        width: image.width
                        height: image.height
                        clip: true

                        RoundedImage {
                            id: image
                            width: 164
                            height: 164
                            border.width: 1
                            border.color: Style.current.border
                            radius: 16
                            source: model.imageUrl
                            fillMode: Image.PreserveAspectCrop
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: {
                                collectibleModal.openModal({
                                    name: model.name,
                                    collectibleId: model.id,
                                    description: model.description,
                                    permalink: model.permalink,
                                    imageUrl: model.imageUrl
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
