import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "../shared"
import "./Login"

ModalPopup {
    property int selectedIndex: 0
    property var onClosed: function () {}
    property var onNextClick: function () {}
    id: popup
    title: qsTr("Choose a chat name")

    AccountList {
        id: accountList
        anchors.fill: parent
        interactive: false

        accounts: onboardingModel
        isSelected: function (index, address) {
            return index === selectedIndex
        }
        onAccountSelect: function(index) {
            selectedIndex = index
        }
    }

    footer: Button {
        id: submitBtn
        anchors.bottom: parent.bottom
        anchors.topMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        width: 44
        height: 44
        background: Rectangle {
            radius: 50
            color: Theme.lightBlue
        }

        SVGImage {
            sourceSize.height: 15
            sourceSize.width: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../app/img/leave_chat.svg"
            rotation: 180
            fillMode: Image.PreserveAspectFit
        }

        onClicked : {
            onNextClick(selectedIndex);
            popup.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
