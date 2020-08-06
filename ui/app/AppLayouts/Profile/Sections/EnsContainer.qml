import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtQml.StateMachine 1.14 as DSM
import "../../../../imports"
import "../../../../shared"
import "./Ens"

Item {
    id: ensContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    property bool showSearchScreen: false
    property string addedUsername: ""
    property string selectedUsername: ""

    signal next(output: string)
    signal back()
    signal connect(ensUsername: string)

    signal goToWelcome();
    signal goToList();

    function goToStart(){
        if(profileModel.ens.rowCount() > 0){
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
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: welcome
        Welcome {
            onClick: function(){
                next(null);
            }
        }
    }

    Component {
        id: search
        Search {
            onClick: function(output, username){
                if(output === "connected"){
                    connect(username)
                } else {
                    next(output);
                }
            }
        }
    }

    Component {
        id: termsAndConditions
        TermsAndConditions {
            onClick: function(output){
                next(output);
            }
        }
    }

    Component {
        id: added
        Added {
            onClick: function(){
                next(null);
            }
        }
    }

    Component {
        id: list
        List {
            onClick: function(){
                next("search");
            }
            onSelectENS: function(username){
                profileModel.ens.details(username)
                selectedUsername = username;
                next("details")
            }
        }
    }

    Component {
        id: details
        ENSDetails {
            username: selectedUsername
            onClick: function(){
                back()
            }
        }
    }

    Connections {
        target: ensContainer
        onConnect: {
            addedUsername = ensUsername;
        }
    }
}
