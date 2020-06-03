import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../imports"
import "../../../../shared"
import "../tokens/"

Item {
    id: element

    Text {
        id: modalDialogTitle
        text: "Add/Remove Tokens"
        anchors.top: parent.top
        anchors.left: parent.left
        font.bold: true
        font.pixelSize: 17
        anchors.leftMargin: 16
        anchors.topMargin: 16
    }

    Image {
        id: closeModalImg
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.topMargin: 16
        source: "../../../img/close.svg"
        MouseArea {
            id: closeModalMouseArea
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                popup.close()
            }
        }
    }

    Separator {
        id: headerSeparator
        anchors.top: modalDialogTitle.bottom
    }

    Item {
        id: modalBody
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.top: headerSeparator.bottom
        anchors.topMargin: Theme.padding
        anchors.bottom: footerSeparator.top
        anchors.bottomMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 32

        ListView {
            anchors.fill: parent
            spacing: 10
            id: tokenListView
            model: Tokens {}
            ScrollBar.vertical: ScrollBar { active: true }

            delegate: Component {

                Item {
                    id: element
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent.width
                    height: 40

                    Image {
                        id: assetInfoImage
                        width: 36
                        height: 36
                        source: "../../../img/tokens/" + symbol + ".png"
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: assetFullTokenName
                        text: name
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.left: assetInfoImage.right
                        anchors.leftMargin: Theme.smallPadding
                        color: Theme.darkGrey
                        font.pixelSize: 15
                    }
                    Text {
                        id: assetSymbol
                        text: symbol
                        anchors.left: assetInfoImage.right
                        anchors.leftMargin: Theme.smallPadding
                        anchors.top: assetInfoImage.top
                        anchors.topMargin: 0
                        color: Theme.black
                        font.pixelSize: 15
                    }
                    CheckBox  {
                        id: assetCheck
                        checked: false //walletModel.hasAsset("0x123", symbol)
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                    }
                }
            }
            highlightFollowsCurrentItem: true
        }
    }

    Separator {
        id: footerSeparator
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 76
    }

    StyledButton {
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: "Apply to all accounts"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        onClicked: {
//            console.log(txtCurrency.textField.text)
//            assetsModel.setDefaultCurrency(txtCurrency.textField.text)
            popup.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
