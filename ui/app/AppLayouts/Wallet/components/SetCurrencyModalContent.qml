import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../data/"

Item {
    property string currency: "USD"
    id: modalBody
    anchors.fill: parent

    ButtonGroup {
        id: currencyGroup
    }

    ListView {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        spacing: 10
        id: tokenListView
        model: Currencies {}
        ScrollBar.vertical: ScrollBar { active: true }

        delegate: Component {
            Item {
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 10
                width: parent.width
                height: 52

                StyledText {
                    text: name + " (" + code + ")"
                    font.pixelSize: Style.current.primaryTextFontSize
                }

                StatusRadioButton {
                    checked: currency === key
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    ButtonGroup.group: currencyGroup
                    onClicked: { walletModel.setDefaultCurrency(key) }
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
