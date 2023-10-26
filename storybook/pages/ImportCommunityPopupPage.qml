import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0

import utils 1.0
import shared.popups 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d

        readonly property alias dialog: loader.item

        property bool utilsReady: false

        readonly property string newCommunityLink: "https://status.app/c/Cw6AChsKBnlveW95bxIGeW95b3lvGAEiByM4OEIwRkYD#zQ3shwHXstcword5gUtJCWVi55ZxPsdtfTQitnWNEAR1p3Gzd"
        readonly property string newCommunityPublicKey: "0x03f751777ab35759f98ad241150f4329b9cc13aa42052ef64d16e9d474b9677bea"
        readonly property string newCommunityCompressedPublicKey: "zQ3shwHXstcword5gUtJCWVi55ZxPsdtfTQitnWNEAR1p3Gzd"

        readonly property var newCommunityDetails: QtObject {
            readonly property string id: "0x039c47e9837a1a7dcd00a6516399d0eb521ab0a92d512ca20a44ac6278bfdbb5c5"
            readonly property string name: "test-1"
            readonly property int memberRole: 0
            readonly property bool isControlNode: false
            readonly property string description: "test"
            readonly property string introMessage: "123"
            readonly property string outroMessage: "342"
            readonly property string image: ModelsData.icons.superRare
            readonly property string bannerImageData: ModelsData.banners.superRare
            readonly property string icon: ""
            readonly property string color: "#4360DF"
            readonly property string tags: "null"
            readonly property bool hasNotification: false
            readonly property int notificationsCount: 0
            readonly property bool active: false
            readonly property bool enabled: true
            readonly property bool joined: false
            readonly property bool spectated: false
            readonly property bool canJoin: true
            readonly property bool canManageUsers: false
            readonly property bool canRequestAccess: false
            readonly property bool isMember: false
            readonly property bool amIBanned: false
            readonly property int access: 1
            readonly property bool ensOnly: false
            readonly property int nbMembers: 42
            readonly property bool encrypted: false
        }

        readonly property string knownCommunityLink: "https://status.app/c/CwyAChcKBHRlc3QSBHRlc3QYAiIHIzQzNjBERgM=#zQ3shqAAKxRroS2BE4FgLjjombivfU7XgeNqVFj1eRZ4GHuAU"
        readonly property string knownCommunityPublicKey: "0x03c892238f64e9b74cefbaaaf5d557fee401a20d6fb52da126de45755b2a2b8166"
        readonly property string knownCommunityCompressedPublicKey: "zQ3shqAAKxRroS2BE4FgLjjombivfU7XgeNqVFj1eRZ4GHuAU"

        readonly property var knownCommunityDetails: QtObject {
            readonly property string id: "0x03c892238f64e9b74cefbaaaf5d557fee401a20d6fb52da126de45755b2a2b8166"
            readonly property string name: "test-2"
            readonly property int memberRole: 0
            readonly property bool isControlNode: false
            readonly property string description: "test"
            readonly property string introMessage: "123"
            readonly property string outroMessage: "342"
            readonly property string image: ModelsData.icons.status
            readonly property string bannerImageData: ModelsData.banners.status
            readonly property string icon: ""
            readonly property string color: "#4360DF"
            readonly property string tags: "null"
            readonly property bool hasNotification: false
            readonly property int notificationsCount: 0
            readonly property bool active: false
            readonly property bool enabled: true
            readonly property bool joined: false
            readonly property bool spectated: false
            readonly property bool canJoin: true
            readonly property bool canManageUsers: false
            readonly property bool canRequestAccess: false
            readonly property bool isMember: false
            readonly property bool amIBanned: false
            readonly property int access: 1
            readonly property bool ensOnly: false
            readonly property int nbMembers: 15
            readonly property bool encrypted: false
        }

        property bool currenKeyIsPublic: false
        property string currentKey: ""
    }

    QtObject {
        id: communityStoreMock

        property bool newCommunityFetched: false

        signal communityInfoRequestCompleted(string communityId, string errorMsg)

        function getCommunityDetails(publicKey, importing, requestWhenNotFound) {
            if (publicKey === d.knownCommunityPublicKey) {
                return d.knownCommunityDetails
            }
            if (publicKey === d.newCommunityPublicKey && newCommunityFetched)
                return d.newCommunityDetails
            return null
        }

        function requestCommunityInfo(communityId) {
            // Dynamically create a timer to be able to simulate overlapping requests
            let timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", root)
            timer.interval = 1000
            timer.repeat = false
            timer.triggered.connect(() => {
                const communityFound = (communityId === d.knownCommunityPublicKey || communityId === d.newCommunityPublicKey)
                const error = communityFound ? "" : "communtiy not found"
                if (communityId === d.newCommunityPublicKey) {
                    newCommunityFetched = true
                }
                communityStoreMock.communityInfoRequestCompleted(communityId, error)
            })
            timer.start()
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
            return d.dialog.text === d.knownCommunityCompressedPublicKey ||
                    d.dialog.text === d.newCommunityCompressedPublicKey
        }

        function changeCommunityKeyCompression(key) {
            if (key === d.knownCommunityCompressedPublicKey)
                return d.knownCommunityPublicKey
            if (key === d.newCommunityCompressedPublicKey)
                return d.newCommunityPublicKey
            if (key === d.knownCommunityPublicKey)
                return d.knownCommunityCompressedPublicKey
            if (key === d.newCommunityPublicKey)
                return d.newCommunityCompressedPublicKey
            return ""
        }

        function getCommunityDataFromSharedLink(link) {
            return d.knownCommunityDetails
        }

        function getCompressedPk(publicKey) {
            return d.knownCommunityCompressedPublicKey
        }

        signal importingCommunityStateChanged(string communityId, int state, string errorMsg)

        // sharedUrlsModuleInst

        function parseCommunitySharedUrl(link) {
            if (link === d.knownCommunityLink)
                return JSON.stringify({ communityId: d.knownCommunityPublicKey })
            if (link === d.newCommunityLink)
                return JSON.stringify({ communityId: d.newCommunityPublicKey })
            return null
        }

        Component.onCompleted: {
            Utils.sharedUrlsModuleInst = this
            Utils.globalUtilsInst = this
            d.utilsReady = true
        }
        Component.onDestruction: {
            d.utilsReady = false
            Utils.sharedUrlsModuleInst = {}
            Utils.globalUtilsInst = {}
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            id: popupBg
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"
                onClicked: loader.item.open()
            }
        }

        Loader {
            id: loader
            active: d.utilsReady
            anchors.fill: parent

            sourceComponent: ImportCommunityPopup {
                anchors.centerIn: parent
                modal: false
                closePolicy: Popup.NoAutoClose
                destroyOnClose: false

                store: communityStoreMock

                Component.onCompleted: open()

                onJoinCommunityRequested: (communityId, communityDetails) => {
                    logs.logEvent("onJoinCommunity", ["communityId", "communityDetails"], communityId, communityDetails)
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        GridLayout {
            columns: 4

            Button {
                text: "Reset communities storage"
                Layout.fillWidth: false
                Layout.columnSpan: 4
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    communityStoreMock.newCommunityFetched = false
                    const prevText = d.dialog.text
                    d.dialog.text = ""
                    d.dialog.text = prevText
                }
            }

            Label {
                text: "Known community"
            }

            Button {
                checked: d.dialog && d.dialog.text === d.knownCommunityLink
                text: "Link"
                onClicked: {
                    d.dialog.text = d.knownCommunityLink
                }
            }

            Button {
                checked: d.dialog && d.dialog.text === d.knownCommunityPublicKey
                text: "Public key"
                onClicked: {
                    d.dialog.text = d.knownCommunityPublicKey
                }
            }

            Button {
                checked: d.dialog && d.dialog.text === d.knownCommunityCompressedPublicKey
                text: "Compressed public key"
                onClicked: {
                    d.dialog.text = d.knownCommunityCompressedPublicKey
                }
            }

            Label {
                text: "Never fetched community"
            }

            Button {
                checked: d.dialog && d.dialog.text === d.newCommunityLink
                text: "Link"
                onClicked: {
                    d.dialog.text = d.newCommunityLink
                }
            }

            Button {
                checked: d.dialog && d.dialog.text === d.newCommunityPublicKey
                text: "Public key"
                onClicked: {
                    d.dialog.text = d.newCommunityPublicKey
                }
            }

            Button {
                checked: d.dialog && d.dialog.text === d.newCommunityCompressedPublicKey
                text: "Compressed public key"
                onClicked: {
                    d.dialog.text = d.newCommunityCompressedPublicKey
                }
            }

        }
    }
}

// category: Popups
