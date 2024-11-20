import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtQml.StateMachine 1.14 as DSM

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.stores 1.0 as SharedStores
import shared.popups.send 1.0

import AppLayouts.Wallet.stores 1.0

import "../stores"

Item {
    id: ensView

    property EnsUsernamesStore ensUsernamesStore
    property WalletAssetsStore walletAssetsStore

    required property var sendModalPopup

    property ContactsStore contactsStore
    property SharedStores.NetworkConnectionStore networkConnectionStore

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

    QtObject {
        id: d

        readonly property string registerENS: "RegisterENS"
        readonly property string setPubKey: "SetPubKey"
        readonly property string releaseENS: "ReleaseENS"

        readonly property var sntToken: ModelUtils.getByKey(ensView.walletAssetsStore.groupedAccountAssetsModel, "tokensKey", ensView.ensUsernamesStore.getStatusTokenKey())
        readonly property SumAggregator aggregator: SumAggregator {
            model: !!d.sntToken && !!d.sntToken.balances ? d.sntToken.balances: nil
            roleName: "balance"
        }
        property real sntBalance: !!sntToken && !!sntToken.decimals ? aggregator.value/(10 ** sntToken.decimals): 0
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

                ensView.sendModalPopup.modalHeaderText = qsTr("Connect username with your pubkey")
                ensView.sendModalPopup.interactive = false
                ensView.sendModalPopup.preSelectedRecipient = ensView.ensUsernamesStore.getEnsRegisteredAddress()
                ensView.sendModalPopup.preSelectedRecipientType = Helpers.RecipientAddressObjectType.Address
                ensView.sendModalPopup.preSelectedHoldingID = Constants.ethToken
                ensView.sendModalPopup.preSelectedHoldingType = Constants.TokenType.ERC20
                ensView.sendModalPopup.preSelectedSendType = Constants.SendType.ENSSetPubKey
                ensView.sendModalPopup.preDefinedAmountToSend = LocaleUtils.numberToLocaleString(0)
                ensView.sendModalPopup.preSelectedChainId = ensView.selectedChainId
                ensView.sendModalPopup.publicKey = ensView.contactsStore.myPublicKey
                ensView.sendModalPopup.ensName = ensView.selectedUsername
                ensView.sendModalPopup.open()
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

            onBackBtnClicked: back();

            onRegisterUsername: {
                ensView.sendModalPopup.interactive = false
                ensView.sendModalPopup.preSelectedRecipient = ensView.ensUsernamesStore.getEnsRegisteredAddress()
                ensView.sendModalPopup.preSelectedRecipientType = Helpers.RecipientAddressObjectType.Address
                ensView.sendModalPopup.preSelectedHoldingID = !!d.sntToken && !!d.sntToken.symbol ? d.sntToken.symbol: ""
                ensView.sendModalPopup.preSelectedHoldingType = Constants.TokenType.ERC20
                ensView.sendModalPopup.preSelectedSendType = Constants.SendType.ENSRegister
                ensView.sendModalPopup.preDefinedAmountToSend = LocaleUtils.numberToLocaleString(10)
                ensView.sendModalPopup.preSelectedChainId = ensView.selectedChainId
                ensView.sendModalPopup.publicKey = ensView.contactsStore.myPublicKey
                ensView.sendModalPopup.ensName = ensView.selectedUsername
                ensView.sendModalPopup.open()
            }

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

                ensView.sendModalPopup.modalHeaderText = qsTr("Release your username")
                ensView.sendModalPopup.interactive = false
                ensView.sendModalPopup.preSelectedAccountAddress = senderAddress
                ensView.sendModalPopup.preSelectedRecipient = ensView.ensUsernamesStore.getEnsRegisteredAddress()
                ensView.sendModalPopup.preSelectedRecipientType = Helpers.RecipientAddressObjectType.Address
                ensView.sendModalPopup.preSelectedHoldingID = Constants.ethToken
                ensView.sendModalPopup.preSelectedHoldingType = Constants.TokenType.Native
                ensView.sendModalPopup.preSelectedSendType = Constants.SendType.ENSRelease
                ensView.sendModalPopup.preDefinedAmountToSend = LocaleUtils.numberToLocaleString(0)
                ensView.sendModalPopup.preSelectedChainId = ensView.selectedChainId
                ensView.sendModalPopup.publicKey = ensView.contactsStore.myPublicKey
                ensView.sendModalPopup.ensName = ensView.selectedUsername
                ensView.sendModalPopup.open()
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

