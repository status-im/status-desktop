pragma Singleton

import QtQuick 2.13

QtObject {
    property var onBoardingModel: onboardingModel
    property var currentAccount: onboardingModel.currentAccount

    function importMnemonic(mnemonic) {
        onboardingModel.importMnemonic(mnemonic)
    }

    function setCurrentAccount(selectedAccountIdx) {
        onboardingModel.setCurrentAccount(selectedAccountIdx)
    }

    property ListModel accountsSampleData: ListModel {
        ListElement {
            username: "Ferocious Herringbone Sinewave2"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
            address: "0x123456789009876543211234567890"
        }
        ListElement {
            username: "Another Account"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
            address: "0x123456789009876543211234567890"
        }
    }
}
