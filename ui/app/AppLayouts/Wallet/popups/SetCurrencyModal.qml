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

    property string defaultCurrency: RootStore.defaultCurrency

    onDefaultCurrencyChanged: {
        setCurrencyModalContent.currency = defaultCurrency
    }

    //% "Set Currency"
    title: qsTrId("set-currency")

    SetCurrencyModalContent {
        id: setCurrencyModalContent
        tokenListModel: CurrenciesStore {}
        onSetDefaultCurrency: {
            RootStore.setDefaultCurrency(key)
        }
    }

    footer: StatusButton {
        anchors.right: parent.right
        //% "Save"
        text: qsTrId("save")
        onClicked: {
            console.log("TODO: apply all accounts")
            popup.close()
        }
    }
}
