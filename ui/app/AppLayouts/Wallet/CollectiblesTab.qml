import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../imports"
import "../../../shared"
import "./components/collectiblesComponents"

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


    CollectiblesModal {
        id: collectiblesModalComponent
    }

    Component {
        id: collectiblesListComponent

        Column {
            spacing: Style.current.halfPadding
            anchors.fill: parent

            CollectiblesContainer {
                collectibleName: "CryptoKitties"
                collectibleIconSource: "../../img/collectibles/CryptoKitties.png"
                isLoading: root.isLoading
                collectiblesModal: collectiblesModalComponent
                buttonText: qsTr("View in Cryptokitties")
                getLink: function (id) {
                    return `https://www.cryptokitties.co/kitty/${id}`
                }
            }

            CollectiblesContainer {
                collectibleName: "Ethermons"
                collectibleIconSource: "../../img/collectibles/ethermons.png"
                isLoading: root.isLoading
                collectiblesModal: collectiblesModalComponent
                buttonText: qsTr("View in Ethermon")
                getLink: function (id) {
                    return `https://www.etheremon.com/#/mons/${id}`
                }
            }

            CollectiblesContainer {
                collectibleName: "Kudos"
                collectibleIconSource: "../../img/collectibles/kudos.png"
                isLoading: root.isLoading
                collectiblesModal: collectiblesModalComponent
                buttonText: qsTr("View in Gitcoin")
                getLink: function (id) {
                    return ""
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
