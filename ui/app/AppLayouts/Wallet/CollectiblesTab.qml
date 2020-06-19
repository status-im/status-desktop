import QtQuick 2.13
import "../../../imports"
import "../../../shared"

Item {
    StyledText {
        visible: walletModel.collectibles.rowCount() === 0
        text: qsTr("No collectibles in this account")
    }

    Component {
        id: collectiblesViewDelegate

        Item {
            id: element
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            height: 40

            Image {
                id: collectibleImage
                width: 36
                height: 36
                source: image
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                id: collectibleName
                text: name
                anchors.leftMargin: Theme.padding
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: collectibleImage.right
                font.pixelSize: 15
            }

            StyledText {
                id: collectibleIdText
                text: collectibleId
                anchors.leftMargin: Theme.padding
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: collectibleName.right
                color: Theme.darkGrey
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

    ListView {
        id: assetListView
        spacing: Theme.smallPadding
        anchors.topMargin: Theme.bigPadding
        anchors.fill: parent
//        model: exampleModel
        model: walletModel.collectibles
        delegate: collectiblesViewDelegate
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
