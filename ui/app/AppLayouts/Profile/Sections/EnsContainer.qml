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

    signal next()
    signal back()

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
        }

        DSM.State {
            id: searchState
            onEntered: loader.sourceComponent = search
        }
        
        DSM.FinalState {
            id: ensFinalState
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
                next();
            }
        }
    }

    Component {
        id: search
        Search {}
    }
}
