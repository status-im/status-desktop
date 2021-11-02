import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1

import utils 1.0

import shared 1.0
import shared.popups 1.0
import "../panels"
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property int selectedIndex: 0
    property var onClosed: function () {}
    property var onNextClick: function () {}
    id: popup
    //% "Choose a chat name"
    title: qsTrId("intro-wizard-title2")
    height: 504

    AccountListPanel {
        id: accountList
        anchors.fill: parent
        interactive: false

        model: OnboardingStore.onBoardingModel
        isSelected: function (index) {
            return index === selectedIndex
        }
        onAccountSelect: function(index) {
            selectedIndex = index
        }
    }
    footer: StatusRoundButton {
        objectName: "submitButton"
        id: submitBtn
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        onClicked : {
            onNextClick(selectedIndex);
            popup.close()
        }
    }
}
