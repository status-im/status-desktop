import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtQml.StateMachine 1.14 as DSM

import utils 1.0
import shared 1.0
import shared.stores.send 1.0

import AppLayouts.Wallet.stores 1.0

import "../stores"

Item {
    id: ensView

    property EnsUsernamesStore ensUsernamesStore
    property WalletAssetsStore walletAssetsStore

    property var contactsStore
    property var networkConnectionStore
    required property TransactionStore transactionStore

    property int profileContentWidth
    property bool showSearchScreen: false
    property string addedUsername: ""
    property string selectedUsername: ""
    property string selectedChainId: ""

    signal next(output: string)
    signal back()
    signal done(ensUsername: string)
    signal connect(ensUsername: string)
    signal changePubKey(ensUsername: string)
    signal goToWelcome();
    signal goToList();

    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    DSM.StateMachine {
        id: stateMachine
        initialState: ensView.ensUsernamesStore.ensUsernamesModel.count > 0 ? listState : welcomeState
        running: true

        DSM.State {
            id: welcomeState
            onEntered: loader.sourceComponent = welcome

            DSM.SignalTransition {
                targetState: searchState
                signal: next
            }
            DSM.SignalTransition {
                targetState: listState
                signal: goToList
            }
        }

        DSM.State {
            id: searchState
            onEntered: loader.sourceComponent = search
            DSM.SignalTransition {
                targetState: tAndCState
                signal: next
                guard: output === "available"
            }
            DSM.SignalTransition {
                targetState: addedState
                signal: connect
            }
            DSM.SignalTransition {
                targetState: listState
                signal: goToList
            }
            DSM.SignalTransition {
                targetState: welcomeState
                signal: goToWelcome
            }
            DSM.SignalTransition {
                targetState: ensConnectedState
                signal: done
            }
        }

        DSM.State {
            id: addedState
            onEntered: {
                loader.sourceComponent = added;
                loader.item.ensUsername = addedUsername;
            }
            DSM.SignalTransition {
                targetState: listState
                signal: next
            }
            DSM.SignalTransition {
                targetState: listState
                signal: goToList
            }
            DSM.SignalTransition {
                targetState: welcomeState
                signal: goToWelcome
            }
        }

        DSM.State {
            id: listState
            onEntered: {
                loader.sourceComponent = list;
            }
            DSM.SignalTransition {
                targetState: searchState
                signal: next
                guard: output === "search"
            }
            DSM.SignalTransition {
                targetState: detailsState
                signal: next
                guard: output === "details"
            }
            DSM.SignalTransition {
                targetState: listState
                signal: goToList
            }
            DSM.SignalTransition {
                targetState: welcomeState
                signal: goToWelcome
            }
        }

        DSM.State {
            id: detailsState
            onEntered: {
                loader.sourceComponent = details;
            }
            DSM.SignalTransition {
                targetState: listState
                signal: back
            }
            DSM.SignalTransition {
                targetState: listState
                signal: goToList
            }
            DSM.SignalTransition {
                targetState: welcomeState
                signal: goToWelcome
            }
            DSM.SignalTransition {
                targetState: ensReleasedState
                signal: done
            }
        }

        DSM.State {
            id: tAndCState
            onEntered:loader.sourceComponent = termsAndConditions
            DSM.SignalTransition {
                targetState: listState
                signal: goToList
            }
            DSM.SignalTransition {
                targetState: welcomeState
                signal: goToWelcome
            }
            DSM.SignalTransition {
                targetState: listState
                signal: back
            }
            DSM.SignalTransition {
                targetState: listState
                signal: back
            }
            DSM.SignalTransition {
                targetState: ensRegisteredState
                signal: done
            }
        }

        DSM.State {
            id: ensRegisteredState
            onEntered:loader.sourceComponent = ensRegistered
            DSM.SignalTransition {
                targetState: listState
                signal: next
            }
        }

        DSM.State {
            id: ensReleasedState
            onEntered:loader.sourceComponent = ensReleased
            DSM.SignalTransition {
                targetState: listState
                signal: next
            }
        }

        DSM.State {
            id: ensConnectedState
            onEntered:loader.sourceComponent = ensConnected
            DSM.SignalTransition {
                targetState: listState
                signal: next
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: welcome
        EnsWelcomeView {
            username: ensView.ensUsernamesStore.username
            onStartBtnClicked: next(null)
            profileContentWidth: ensView.profileContentWidth
            startButtonEnabled: ensView.networkConnectionStore.ensNetworkAvailable
            tooltipText: ensView.networkConnectionStore.ensNetworkUnavailableText
        }
    }

    Component {
        id: search
        EnsSearchView {
            ensUsernamesStore: ensView.ensUsernamesStore
            contactsStore: ensView.contactsStore
            transactionStore: ensView.transactionStore
            profileContentWidth: ensView.profileContentWidth
            onContinueClicked: {
                if(output === "connected"){
                    connect(username)
                } else {
                    selectedUsername = username;
                    next(output);
                }
            }
            onUsernameUpdated: {
                selectedUsername = username;
                done(username);
            }
        }
    }

    Component {
        id: termsAndConditions
        EnsTermsAndConditionsView {
            ensUsernamesStore: ensView.ensUsernamesStore
            contactsStore: ensView.contactsStore
            transactionStore: ensView.transactionStore
            walletAssetsStore: ensView.walletAssetsStore
            username: selectedUsername
            onBackBtnClicked: back();
            onUsernameRegistered: done(userName);
        }
    }

    Component {
        id: added
        EnsAddedView {
            onOkBtnClicked: next(null)
        }
    }

    Component {
        id: ensRegistered
        EnsRegisteredView {
            ensUsername: selectedUsername
            onOkBtnClicked: next(null)
        }
    }

    Component {
        id: ensReleased
        EnsReleasedView {
            ensUsername: selectedUsername
            onOkBtnClicked: next(null)
        }
    }

    Component {
        id: ensConnected
        EnsConnectedView {
            ensUsername: selectedUsername
            onOkBtnClicked: next(null)
        }
    }

    Component {
        id: list
        EnsListView {
            ensUsernamesStore: ensView.ensUsernamesStore

            profileContentWidth: ensView.profileContentWidth
            onAddBtnClicked: next("search")
            onSelectEns: {
                ensView.ensUsernamesStore.ensDetails(chainId, username)
                selectedUsername = username
                selectedChainId = chainId
                next("details")
            }
        }
    }

    Component {
        id: details
        EnsDetailsView {
            ensUsernamesStore: ensView.ensUsernamesStore
            contactsStore: ensView.contactsStore
            transactionStore: ensView.transactionStore
            username: selectedUsername
            chainId: selectedChainId
            onBackBtnClicked: back()
            onUsernameReleased: {
                selectedUsername = username
                selectedChainId = chainId
                done(username)
            }
        }
    }

    Connections {
        target: ensView
        function onConnect(ensUsername: string) {
            addedUsername = ensUsername;
        }
    }

    Connections {
        target: ensView.ensUsernamesStore.ensUsernamesModule
        function onTransactionCompleted(success: bool, txHash: string, username: string, trxType: string) {
            let title = ""
            switch(trxType){
            case "RegisterENS":
                title = !success ?
                            qsTr("ENS Registration failed")
                          :
                            qsTr("ENS Registration completed");
                break;
            case "SetPubKey":
                title = !success ?
                            qsTr("Updating ENS pubkey failed")
                          :
                            qsTr("Updating ENS pubkey completed");
                break;
            default:
                console.error("unknown transaction type: ", trxType);
                return
            }

            let icon = "block-icon";
            let ephType = Constants.ephemeralNotificationType.normal;
            if (success) {
                icon = "check-circle";
                ephType = Constants.ephemeralNotificationType.success;
            }

            let url = `${ensView.ensUsernamesStore.getEtherscanLink()}/${txHash}`;
            Global.displayToastMessage(qsTr("Transaction pending..."),
                                       qsTr("View on etherscan"),
                                       icon,
                                       false,
                                       ephType,
                                       url)
        }
    }
}

