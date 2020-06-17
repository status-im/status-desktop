import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../data/"

Item {
    id: element
    property string currency: "USD"

    Text {
        id: modalDialogTitle
        text: "Settings"
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

    ButtonGroup {
        id: currencyGroup
    }

    Item {
        id: modalBody
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.top: headerSeparator.top
        anchors.topMargin: Theme.padding
        anchors.bottom: footerSeparator.top
        anchors.bottomMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: 32

        ListView {
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 10
            id: tokenListView
            model: Currencies {}
            ScrollBar.vertical: ScrollBar { active: true }

            delegate: Component {
                Item {
                    id: element
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent.width
                    height: 52

                    Text {
                        text: name + " (" + code + ")"
                        font.pixelSize: 15
                    }

                    RadioButton {
                        checked: currency === key
                        anchors.right: parent.right
                        ButtonGroup.group: currencyGroup
                        onClicked: { walletModel.setDefaultCurrency(key) }
                    }
                }
            }
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
        label: "Save"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        onClicked: {
            console.log("TODO: apply all accounts")
            popup.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
