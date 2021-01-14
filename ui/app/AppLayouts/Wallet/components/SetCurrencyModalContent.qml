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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: true
        spacing: 10
        id: tokenListView
        model: Currencies {}
        ScrollBar.vertical: ScrollBar { 
            active: true
            policy: tokenListView.contentHeight > tokenListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        }
        boundsBehavior: Flickable.StopAtBounds
        
        delegate: Component {
            Rectangle {
                id: wrapper
                property bool hovered: false
                radius: Style.current.radius
                color: modalBody.currency === key ? Style.current.lightBlue : (hovered ? Style.current.backgroundHover: Style.current.transparent)
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 10
                width: parent.width
                height: 52

                StyledText {
                    text: name + " (" + code + ")"
                    font.pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.padding
                }

                StatusRadioButton {
                    id: currencyRadioBtn
                    checked: currency === key
                    isHovered: wrapper.hovered
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    ButtonGroup.group: currencyGroup
                    onClicked: { walletModel.setDefaultCurrency(key) }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        wrapper.hovered = true
                    }
                    onExited: {
                        wrapper.hovered = false
                    }
                    onClicked: {
                        currencyRadioBtn.checked = !currencyRadioBtn.checked
                        modalBody.currency = key
                        walletModel.setDefaultCurrency(key)
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
