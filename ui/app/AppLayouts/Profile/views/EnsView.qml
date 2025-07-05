import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.StateMachine as DSM

import StatusQ
import StatusQ.Core
import StatusQ.Core.Utils
import StatusQ.Popups.Dialog
import StatusQ.Core.Theme

import utils
import shared
import shared.stores as SharedStores
import shared.popups.send

import AppLayouts.Wallet.stores
import AppLayouts.stores as AppLayoutStores

import "../stores"

Item {
    id: ensView

    property EnsUsernamesStore ensUsernamesStore
    property WalletAssetsStore walletAssetsStore

    property AppLayoutStores.ContactsStore contactsStore
    property SharedStores.NetworkConnectionStore networkConnectionStore

    property int profileContentWidth
    property bool showSearchScreen: false
    property string addedUsername: ""
    property string selectedUsername: ""
    property int selectedChainId: -1

    signal next(output: string)
    signal back()
    signal done(ensUsername: string)
    signal connect(ensUsername: string)
    signal changePubKey(ensUsername: string)
    signal goToWelcome();
    signal goToList();

    signal connectUsernameRequested(string ensName)
    signal registerUsernameRequested(string ensName)
    signal releaseUsernameRequested(string ensName, string senderAddress, int chainId)

    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    QtObject {
        id: d

        readonly property string registerENS: "RegisterENS"
        readonly property string setPubKey: "SetPubKey"
        readonly property string releaseENS: "ReleaseENS"
    }

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
            profileContentWidth: ensView.profileContentWidth

            onContinueClicked: {
                if(output === "connected"){
                    connect(username)
                } else {
                    selectedUsername = username;
                    next(output);
                }
            }

            onConnectUsername: {
                ensView.selectedUsername = username
                ensView.connectUsernameRequested(ensView.selectedUsername)
            }

            Connections {
                target: ensView.ensUsernamesStore.ensUsernamesModule
                function onTransactionWasSent(trxType: string, chainId: int, txHash: string, username: string, error: string) {
                    if (!!error || trxType !== d.setPubKey) {
                        return
                    }
                    done(ensView.selectedUsername)
                }
            }
        }
    }

    Component {
        id: termsAndConditions
        EnsTermsAndConditionsView {
            ensUsernamesStore: ensView.ensUsernamesStore
            username: selectedUsername
            assetsModel: ensView.walletAssetsStore.groupedAccountAssetsModel

            onBackBtnClicked: back();

            onRegisterUsername: ensView.registerUsernameRequested(ensView.selectedUsername)

            Connections {
                target: ensView.ensUsernamesStore.ensUsernamesModule
                function onTransactionWasSent(trxType: string, chainId: int, txHash: string, username: string, error: string) {
                    if (!!error || trxType !== d.registerENS) {
                        return
                    }
                    done(ensView.selectedUsername)
                }
            }
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
            username: selectedUsername
            chainId: selectedChainId

            onBackBtnClicked: back()

            onReleaseUsernameRequested: {
                const name = RootStore.getNameForWalletAddress(senderAddress)
                if (name === "") {
                    Global.openPopup(noAccountPopupComponent)
                    return
                }
                ensView.releaseUsernameRequested(ensView.selectedUsername, senderAddress, ensView.selectedChainId)
            }

            Connections {
                target: ensView.ensUsernamesStore.ensUsernamesModule
                function onTransactionWasSent(trxType: string, chainId: int, txHash: string, username: string, error: string) {
                    if (!!error || trxType !== d.releaseENS) {
                        return
                    }
                    done(ensView.selectedUsername)
                }
            }
        }
    }

    Component {
        id: noAccountPopupComponent
        StatusDialog {
            title: qsTr("Release username")

            StatusBaseText {
                anchors.fill: parent
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
                text: qsTr("The account this username was bought with is no longer among active accounts.\nPlease add it and try again.")
            }

            standardButtons: Dialog.Ok
        }
    }

    Connections {
        target: ensView
        function onConnect(ensUsername: string) {
            addedUsername = ensUsername;
        }
    }

}

