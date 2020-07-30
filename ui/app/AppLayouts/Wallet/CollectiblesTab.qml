import QtQuick 2.13
import "../../../imports"
import "../../../shared"

Item {
    StyledText {
        //% "No collectibles in this account"
        text: qsTrId("no-collectibles-in-this-account")
        visible: walletModel.collectibles.rowCount() === 0
    }

    Loader {
        id: loadingImg
        active: false
        sourceComponent: loadingImageComponent
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.currentPadding
        anchors.verticalCenter: txtPassword.verticalCenter
    }

    Component {
        id: loadingImageComponent
        LoadingImage {}
    }

    Connections {
        target: walletModel
        onLoadingCollectibles: {
            loadingImg.active = isLoading
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

    ListView {
        id: assetListView
        spacing: Style.current.smallPadding
        anchors.topMargin: Style.current.bigPadding
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
