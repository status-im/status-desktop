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
        sourceComponent: root.isLoading || walletModel.collectibles.rowCount() > 0 ? collectiblesListComponent
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
                collectibleType: Constants.cryptokitty
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
                collectibleType: Constants.ethermon
                collectibleIconSource: "../../img/collectibles/ethermons.png"
                isLoading: root.isLoading
                collectiblesModal: collectiblesModalComponent
                buttonText: qsTr("View in Ethermon")
                getLink: function (id) {
                    // TODO find a more direct URL
                    return "https://ethermon.io/inventory"
                }
            }

            CollectiblesContainer {
                collectibleName: "Kudos"
                collectibleType: Constants.kudo
                collectibleIconSource: "../../img/collectibles/kudos.png"
                isLoading: root.isLoading
                collectiblesModal: collectiblesModalComponent
                buttonText: qsTr("View in Gitcoin")
                getLink: function (id, externalUrl) {
                    return externalUrl
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
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
