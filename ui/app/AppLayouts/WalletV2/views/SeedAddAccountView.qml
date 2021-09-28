import QtQuick 2.13


import utils 1.0
import "../panels"
import "../controls"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

Item {
    id: root
    visible: (opacity > 0.1)
    property bool searching: false
    property alias activeAccountsList: activeAccountsView
    property Timer timer: Timer {
        interval: 800
        onTriggered: {
            searching = false;
        }
    }
    property var store
    property var dummyModel: []

    Column {
        id: searchingColumn
        width: parent.width
        height: 80
        anchors.verticalCenter: parent.verticalCenter
        spacing: 15
        StatusLoadingIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.palette.primaryColor1
        }
        StatusBaseText {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
            text: qsTr("Searching for active accounts")
            color: Theme.palette.baseColor1
        }
    }

    ListView {
        id: activeAccountsView
        anchors.fill: parent
        anchors.bottomMargin: 10
        clip: true
        //TODO replace with active accounts model
        model: root.store.walletModelInst.accountsView.accounts
        delegate: SeedAccountDetailsDelegate {
            deleteButtonVisible: (activeAccountsView.count > 1)
            onDeleteClicked: {
                root.store.deleteAccount(address);
            }
        }
    }

    AccountNotFoundPanel {
        id: accountNotFound
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
    }

    states: [
        State {
            when: searching
            PropertyChanges {
                target: searchingColumn
                opacity: 1.0
            }
            PropertyChanges {
                target: activeAccountsView
                opacity: 0.0
            }
            PropertyChanges {
                target: accountNotFound
                opacity: 0.0
            }
        },
        State {
            when: !searching
            PropertyChanges {
                target: searchingColumn
                opacity: 0.0
            }
            PropertyChanges {
                target: activeAccountsView
                opacity: 1.0
            }
            PropertyChanges {
                target: accountNotFound
                opacity: 0.0
            }
        },
        State {
            when: (activeAccountsView.count === 0 && !searching)
            PropertyChanges {
                target: searchingColumn
                opacity: 0.0
            }
            PropertyChanges {
                target: activeAccountsView
                opacity: 0.0
            }
            PropertyChanges {
                target: accountNotFound
                opacity: 1.0
            }
        }
    ]
}
