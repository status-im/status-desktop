import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    property var signal_model: QtObject {
        property string output: ""
        property string ensUsername_done: ""
        property string ensUsername_connect: ""
        property string ensUsername_changePubKey: ""

        property string taken_usernames: "vitalik,iuri"
        property string connected_usernames_different_key: "maria"
        property string connected_usernames: "john"
    }

    property var ensUsernameModule: QtObject {
        signal usernameAvailabilityChecked(availabilityStatus: string)
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        EnsView {
            id: ensView
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            profileContentWidth: parent.width

            ensUsernamesStore: EnsUsernamesStore {
                ensUsernamesModule: ensUsernameModule
                ensUsernamesModel: []

                pubkey: "0x123"
                icon: ""
                preferredUsername: "user display name"
                username: "username"

                walletAccounts: QtObject {
                }

                function checkEnsUsernameAvailability(ensName, isStatus) {
                    logs.logEvent("ensUsernamesStore::checkEnsUsernameAvailability", ["ensName", "isStatus"], arguments)
                    if (signal_model.taken_usernames.split(",").indexOf(ensName) > -1) {
                        return ensUsernameModule.usernameAvailabilityChecked("taken")
                    }
                    if (signal_model.connected_usernames_different_key.split(",").indexOf(ensName) > -1) {
                        return ensUsernameModule.usernameAvailabilityChecked("connected-different-key")
                    }
                    if (signal_model.connected_usernames.split(",").indexOf(ensName) > -1) {
                        return ensUsernameModule.usernameAvailabilityChecked("already-connected")
                    }
                    return ensUsernameModule.usernameAvailabilityChecked("available")
                }

                function getChainIdForEns() {
                    logs.logEvent("ensUsernamesStore::getChainIdForEns")
                    return "chainId"
                }

                function setPubKeyGasEstimate(address) {
                    logs.logEvent("ensUsernamesStore::setPubKeyGasEstimate", ["address"], arguments)
                    return 100 // gas estimate
                }

                function setPubKey(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, eip1559Enabled) {
                    logs.logEvent("ensUsernamesStore::setPubKey", ["ensUsername", "address", "gas", "gasPrice", "maxPriorityFeePerGas", "maxFeePerGas", "password", "eip1559Enabled"], arguments)
                    return "0x123"
                }

                function ensConnectOwnedUsername(name, isStatus) {
                    logs.logEvent("ensUsernamesStore::ensConnectOwnedUsername", ["name", "isStatus"], arguments)
                }

                function getEnsRegisteredAddress() {
                    logs.logEvent("ensUsernamesStore::getEnsRegisteredAddress")
                    return "0x234"
                }

                function registerEnsGasEstimate(username, address) {
                    logs.logEvent("ensUsernamesStore::registerEnsGasEstimate", ["username", "address"], arguments)
                    return 100
                }

                function registerEns(ensUsername, address, gasLimit, gasPrice, tipLimit, overallLimit, password, eip1559Enabled) {
                    logs.logEvent("ensUsernamesStore::registerEns", ["ensUsername", "address", "gasLimit", "gasPrice", "tipLimit", "overallLimit", "password", "eip1559Enabled"], arguments)
                }

                function getSntBalance() {
                    logs.logEvent("ensUsernamesStore::getSntBalance")
                    return 1000
                }

                function copyToClipboard(pubKey) {
                    logs.logEvent("ensUsernamesStore::copyToClipboard", ["pubKey"], arguments)
                }

                function getWalletDefaultAddress() {
                    logs.logEvent("ensUsernamesStore::getWalletDefaultAddress")
                    return "0x345"
                }

                function getEtherscanLink() {
                    logs.logEvent("ensUsernamesStore::getEtherscanLink")
                    return "http://etherscan.com"
                }

                function getEnsRegistry() {
                    logs.logEvent("ensUsernamesStore::getEnsRegistry")
                    return "0x456"
                }
            }

            contactsStore: QtObject {
            }

            stickersStore: QtObject {
                property var stickersModule: QtObject {
                }
            }

            onNext: {
                logs.logEvent("signal::next", ["output"], arguments)
            }
            onBack: {
                logs.logEvent("signal::back")
            }
            onDone: {
                logs.logEvent("signal::done", ["ensUsername"], arguments)
            }
            onConnect: {
                logs.logEvent("signal::connect", ["ensUsername"], arguments)
            }
            onChangePubKey: {
                logs.logEvent("signal::changePubKey", ["ensUsername"], arguments)
            }
            onGoToWelcome: {
                logs.logEvent("signal::goToWelcome")
            }
            onGoToList: {
                logs.logEvent("signal::goToList")
            }

        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        ColumnLayout {
            width: parent.width

            Label {
                text: "taken usernames"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: signal_model.taken_usernames
                onTextChanged: signal_model.taken_usernames = text
            }

            Label {
                text: "usernames connected using a different key"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: signal_model.connected_usernames_different_key
                onTextChanged: signal_model.connected_usernames_different_key = text
            }

            Label {
                text: "usernames already connected"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: signal_model.connected_usernames
                onTextChanged: signal_model.connected_usernames = text
            }


            Label {
                text: "output"
                font.weight: Font.Bold
            }

            Flow {
                Layout.fillWidth: true

                CheckBox {
                    text: "none"
                    checked: (signal_model.output == null || signal_model.output == "")
                    onToggled: signal_model.output = null
                }
                CheckBox {
                    text: "available"
                    checked: signal_model.output == "available"
                    onToggled: signal_model.output = "available"
                }
                CheckBox {
                    text: "search"
                    checked: signal_model.output == "search"
                    onToggled: signal_model.output = "search"
                }
                CheckBox {
                    text: "details"
                    checked: signal_model.output == "details"
                    onToggled: signal_model.output = "details"
                }
                CheckBox {
                    text: "connected"
                    checked: signal_model.output == "connected"
                    onToggled: signal_model.output = "connected"
                }
            }

            Button {
                text: "Signal::next"
                onClicked: ensView.next(signal_model.output)
            }

            Button {
                text: "Signal::back"
                onClicked: ensView.back()
            }

            Label {
                text: "ensUsername"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: signal_model.ensUsername_done
                onTextChanged: signal_model.ensUsername_done = text
            }

            Button {
                text: "Signal::done"
                onClicked: ensView.done(signal_model.ensUsername_done)
            }

            Label {
                text: "ensUsername"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: signal_model.ensUsername_connect
                onTextChanged: signal_model.ensUsername_connect = text
            }

            Button {
                text: "Signal::connect"
                onClicked: ensView.connect(signal_model.ensUsername_connect)
            }

            Label {
                text: "ensUsername"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: signal_model.ensUsername_changePubKey
                onTextChanged: signal_model.ensUsername_changePubKey = text
            }

            Button {
                text: "Signal::changePubKey"
                onClicked: ensView.changePubKey(signal_model.ensUsername_changePubKey)
            }

            Button {
                text: "Signal::goToWelcome"
                onClicked: ensView.goToWelcome()
            }

            Button {
                text: "Signal::goToList"
                onClicked: ensView.goToList()
            }
        }
    }
}
