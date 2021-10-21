import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.popups 1.0
import "../panels"
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    width: 480
    height: 510

    property string currentCurrency: RootStore.currentCurrency

    onCurrentCurrencyChanged: {
        setCurrencyModalContent.currency = currentCurrency
    }

    //% "Set Currency"
    title: qsTrId("set-currency")

    SetCurrencyModalContent {
        id: setCurrencyModalContent
        tokenListModel: CurrenciesStore {}
    }

    footer: StatusButton {
        anchors.right: parent.right
        //% "Save"
        text: qsTrId("save")
        onClicked: {
            RootStore.updateCurrency(setCurrencyModalContent.currency)
            popup.close()
        }
    }
}
