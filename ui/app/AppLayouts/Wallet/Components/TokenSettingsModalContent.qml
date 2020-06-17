import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../Chat/ContactsColumn"
import "../data/"

Item {
    id: element

    Text {
        id: modalDialogTitle
        text: qsTr("Add/Remove Tokens")
        anchors.top: parent.top
        anchors.left: parent.left
        font.bold: true
        font.pixelSize: 17
        anchors.leftMargin: Theme.padding
        anchors.topMargin: Theme.padding
    }

    Image {
        id: closeModalImg
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.topMargin: Theme.padding
        source: "../../../../shared/img/close.svg"
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
        anchors.bottomMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: 32

        SearchBox {
            id: searchBox
            customHeight: 36
            fontPixelSize: 12
            anchors.top: modalBody.top
        }

        ListView {
            anchors.top: searchBox.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
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
                    property bool isVisible: searchBox.text == "" || name.toLowerCase().includes(searchBox.text.toLowerCase()) || symbol.toLowerCase().includes(searchBox.text.toLowerCase())
                    visible: isVisible && symbol !== "" ? true : false
                    height: isVisible && symbol !== "" ? 40 : 0

                    Image {
                        id: assetInfoImage
                        width: 36
                        height: isVisible && symbol !== "" ? 36 : 0
                        source: hasIcon ? "../../../img/tokens/" + symbol + ".png" : "../../../img/tokens/0-native.png"
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
                        checked: walletModel.hasAsset("0x123", symbol)
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        onClicked: walletModel.toggleAsset(symbol, assetCheck.checked, address, name, decimals, "eeeeee")
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
        label: qsTr("Add custom token")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        onClicked: {
            popup.close()
            addCustomTokenModal.open()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
