import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtQml.StateMachine 1.14 as DSM

import utils 1.0
import "../../../../shared"
/* import "./Ens" */

import "../stores"
import "."

Item {
    id: root

    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property var store

    property bool showSearchScreen: false
    property string addedUsername: ""
    property string selectedUsername: ""
    property var messageStore

    signal next(output: string)
    signal back()
    signal done(ensUsername: string)
    signal connect(ensUsername: string)
    signal changePubKey(ensUsername: string)


    signal goToWelcome();
    signal goToList();

    function goToStart(){
        if(root.store.ens.rowCount() > 0 && networkGuarded){
            goToList();
        } else {
            goToWelcome();
        }
    }

    DSM.StateMachine {
        id: stateMachine
        initialState: welcomeState
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
            username: root.store.username
            onStartBtnClicked: next(null)
        }
    }

    Component {
        id: search
        EnsSearchView {
            store: root.store
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
            store: root.store
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
            store: root.store
            messageStore: ensContainer.messageStore
            onAddBtnClicked: next("search")
            onSelectEns: {
                root.store.ensDetails(username)
                selectedUsername = username;
                next("details")
            }
        }
    }

    Component {
        id: details
        EnsDetailsView {
            store: root.store
            username: selectedUsername
            onBackBtnClicked: back();
            onUsernameReleased: {
                selectedUsername = username;
                done(username);
            }
        }
    }

    Connections {
        target: root
        onConnect: {
            addedUsername = ensUsername;
        }
    }

    Connections {
        target: root.store.ens
        onTransactionWasSent: {
            //% "Transaction pending..."
            toastMessage.title = qsTrId("ens-transaction-pending")
            toastMessage.source = Style.svg("loading")
            toastMessage.iconColor = Style.current.primary
            toastMessage.iconRotates = true
            toastMessage.link = `${root.store.etherscanLink}/${txResult}`
            toastMessage.open()
        }
        onTransactionCompleted: {
            switch(trxType){
                case "RegisterENS":
                    toastMessage.title = !success ? 
                                         //% "ENS Registration failed"
                                         qsTrId("ens-registration-failed")
                                         :
                                         //% "ENS Registration completed"
                                         qsTrId("ens-registration-completed");
                    break;
                case "SetPubKey":
                    toastMessage.title = !success ? 
                                         //% "Updating ENS pubkey failed"
                                         qsTrId("updating-ens-pubkey-failed")
                                         :
                                         //% "Updating ENS pubkey completed"
                                         qsTrId("updating-ens-pubkey-completed");
                    break;
            }

            if (success) {
                toastMessage.source = Style.svg("check-circle")
                toastMessage.iconColor = Style.current.success
            } else {
                toastMessage.source = Style.svg("block-icon")
                toastMessage.iconColor = Style.current.danger
            }

            toastMessage.link = `${root.store.etherscanLink}/${txHash}`
            toastMessage.open()
        }
    }
}

