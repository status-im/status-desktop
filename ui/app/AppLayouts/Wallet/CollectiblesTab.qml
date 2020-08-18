import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../imports"
import "../../../shared"

Item {
    property bool isLoading: true
    id: root

    Loader {
        active: true
        sourceComponent: true || root.isLoading || walletModel.collectibles.rowCount() > 0 ? collectiblesListComponent
                                                                                   : noCollectiblesComponent
        width: parent.width
    }

    Component {
        id: noCollectiblesComponent

        StyledText {
            color: Style.current.secondaryText
            text: qsTr("Collectibles will appear here")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 15
            visible: !root.isLoading && walletModel.collectibles.rowCount() === 0
        }
    }

    Component {
        id: collectiblesListComponent

        Rectangle {
            property bool hovered: false

            id: collectibleHeader
            height: 64
            width: parent.width
            color: hovered ? Style.current.backgroundHover : Style.current.transparent
            border.width: 0
            radius: Style.current.radius

            Image {
                id: collectibleIconImage
                source: "../../img/collectibles/CryptoKitties.png"
                width: 40
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "CryptoKitties"
                anchors.left: collectibleIconImage.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
            }

            Loader {
                active: true
                sourceComponent: root.isLoading ? loadingComponent : handleComponent
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
            }

            Component {
                id: loadingComponent

                LoadingImage {}
            }

            Component {
                id: handleComponent

                Item {
                    id: element1
                    width: childrenRect.width
                    height: numberCollectibleText.height

                    StyledText {
                        id: numberCollectibleText
                        color: Style.current.secondaryText
                        // TODO change with number of current collectible
                        text: "6"
                        font.pixelSize: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SVGImage {
                        id: caretImg
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../img/caret.svg"
                        width: 11
                        anchors.left: numberCollectibleText.right
                        anchors.leftMargin: Style.current.padding
                        fillMode: Image.PreserveAspectFit
                    }
                    ColorOverlay {
                        anchors.fill: caretImg
                        source: caretImg
                        color: Style.current.black
                    }
                }
            }

            MouseArea {
                enabled: !root.isLoading
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    collectibleHeader.hovered = true
                }
                onExited: {
                    collectibleHeader.hovered = false
                }
                onClicked: {
                    console.log('Open collectibles')
                }
            }
        }
    }

    Connections {
        target: walletModel
        onLoadingCollectibles: {
            root.isLoading= isLoading
        }
    }

    Component {
        id: collectiblesViewDelegate

        Item {
            id: element
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            height: 132

            SVGImage {
                id: collectibleImage
                width: 128
                height: 128
                source: image
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                id: collectibleName
                text: name
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: collectibleImage.right
                anchors.leftMargin: Style.current.padding
                font.pixelSize: 15
            }

            StyledText {
                id: collectibleIdText
                text: collectibleId
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: collectibleName.right
                color: Style.current.darkGrey
                font.pixelSize: 15
            }
        }
    }

    ListModel {
        id: exampleModel

        ListElement {
            name: "Kitty cat"
            image: "../../img/token-icons/eth.svg"
            collectibleId: "1337"
        }
    }

//    ListView {
//        id: assetListView
//        spacing: Style.current.smallPadding
//        anchors.topMargin: Style.current.bigPadding
//        anchors.fill: parent
////        model: exampleModel
//        model: walletModel.collectibles
//        delegate: collectiblesViewDelegate
//    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
