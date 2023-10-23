import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import mainui.activitycenter.views 1.0
import mainui.activitycenter.stores 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    id: root

    property bool utilsReady: false

    orientation: Qt.Vertical

    Logs { id: logs }

    Item {
        id: wrapper
        SplitView.fillHeight: true
        SplitView.fillWidth: true

        Loader {
            active: root.utilsReady
            anchors.centerIn: parent
            width: parent.width - 50
            height: 80

            sourceComponent : ActivityNotificationCommunityMembershipRequest {
                store: storeMock
                notification: notificationMock
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            Label {
                text: "Request state"
            }

            ComboBox {
                id: stateSelector
                textRole: "text"
                valueRole: "value"
                model: ListModel {
                         id: model

                         ListElement { text: "Pending"; value: 1 } // ActivityCenterStore.ActivityCenterMembershipStatus.Pending }
                         ListElement { text: "Accepted"; value: 2 } //ActivityCenterStore.ActivityCenterMembershipStatus.Accepted }
                         ListElement { text: "Declined"; value: 3 } //ActivityCenterStore.ActivityCenterMembershipStatus.Declined }
                         ListElement { text: "AcceptedPending"; value: 4 } //ActivityCenterStore.ActivityCenterMembershipStatus.AcceptedPending }
                         ListElement { text: "DeclinedPending"; value: 5 } //ActivityCenterStore.ActivityCenterMembershipStatus.DeclinedPending }
                     }
            }
        }
    }

    QtObject {
        id: utilsMock
        function getContactDetailsAsJson(arg1, arg2) {
            return JSON.stringify({
                displayName: "Mock user",
                displayIcon: Style.png("tokens/AST"),
                publicKey: 123456789,
                name: "",
                ensVerified: false,
                alias: "",
                lastUpdated: 0,
                lastUpdatedLocally: 0,
                localNickname: "",
                thumbnailImage: "",
                largeImage: "",
                isContact: false,
                isAdded: false,
                isBlocked: false,
                requestReceived: false,
                isSyncing: false,
                removed: false,
                trustStatus: Constants.trustStatus.unknown,
                verificationStatus: Constants.verificationStatus.unverified,
                incomingVerificationStatus: Constants.verificationStatus.unverified
            })
        }

        function isCompressedPubKey(key) {
            return true
        }

        function getColorId(publicKey) {
            return 1
        }

        function isEnsVerified(publicKey) {
            return true
        }

        function getCompressedPk(publicKey) {
            return "0x00000"
        }

        Component.onCompleted: {
            Utils.mainModuleInst = this
            Utils.globalUtilsInst = this
            root.utilsReady = true
        }
        Component.onDestruction: {
            root.utilsReady = false
            Utils.mainModuleInst = {}
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        id: storeMock

        function getCommunityDetailsAsJson(community) {
            return {
                name : "Mock Community",
                image : Style.png("tokens/UNI"),
                color : "orchid"
            }
        }

        function acceptRequestToJoinCommunity(notificationId, communityId) {
            stateSelector.currentIndex = stateSelector.indexOfValue(ActivityCenterStore.ActivityCenterMembershipStatus.AcceptedPending)
        }

        function declineRequestToJoinCommunity(notificationId, communityId) {
            stateSelector.currentIndex = stateSelector.indexOfValue(ActivityCenterStore.ActivityCenterMembershipStatus.DeclinedPending)
        }

        property var contactsStore: QtObject {
            property var myContactsModel: QtObject {
                signal itemChanged(string pubKey)
            }
        }
    }

    QtObject {
        id: notificationMock
        property string id: "1"
        property string chatId: "1"
        property string communityId: "1"
        property int membershipStatus: stateSelector.currentValue
        property int verificationStatus: 1
        property string sectionId: "1"
        property string name: "name"
        property string author: "author"
        property int notificationType: 1
        property var message: QtObject {
            property bool amISender: false
        }

        property int timestamp: Date.now()
        property int previousTimestamp: 0
        property bool read: false
        property bool dismissed: false
        property bool accepted: false
        property var repliedMessage: ({})
        property int chatType: 1
    }

    Settings {
        property alias activityNotificationRequestState: stateSelector.currentIndex
    }
}

// category: Activity Center
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?type=design&node-id=35909-606817&mode=design&t=Ia7Z0AzyYIjkuPtr-0
