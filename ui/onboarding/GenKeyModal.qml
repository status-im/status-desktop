import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"
import "../shared/status"
import "./Login"

ModalPopup {
    property int selectedIndex: 0
    property var onClosed: function () {}
    property var onNextClick: function () {}
    id: popup
    //% "Choose a chat name"
    title: qsTrId("intro-wizard-title2")

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
    footer: StatusRoundButton {
        id: submitBtn
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        icon.name: "arrow-right"
        icon.width: 20 * scaleAction.factor
        icon.height: 16 * scaleAction.factor
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
