import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtQml.Models 2.15

import utils 1.0
import shared.controls 1.0
import shared.stores 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1

import AppLayouts.Communities.stores 1.0 as CommunitiesStores

StatusDialog {
    id: root

    property CommunitiesStores.CommunitiesStore store
    property UtilsStore utilsStore

    property alias text: keyInput.text

    signal joinCommunityRequested(string communityId, var communityDetails)

    width: 640
    title: qsTr("Join Community")

    QtObject {
        id: d
        property string importErrorMessage

        readonly property bool communityFound: !!d.communityDetails && !!d.communityDetails.name
        property var communityDetails: null

        property var requestedCommunityDetails: null

        readonly property string inputErrorMessage: isInputValid ? "" : qsTr("Invalid key")
        readonly property string errorMessage: importErrorMessage || inputErrorMessage
        readonly property string inputKey: keyInput.text.trim()
        property int shardCluster: -1
        property int shardIndex: -1
        readonly property string publicKey: {
            if (Utils.isStatusDeepLink(inputKey)) {
                d.shardCluster = -1
                d.shardIndex = -1
                const linkData = Utils.getCommunityDataFromSharedLink(inputKey)
                if (!linkData) {
                    return ""
                }
                if (linkData.shardCluster != undefined && linkData.shardIndex != undefined) {
                    d.shardCluster = linkData.shardCluster
                    d.shardIndex = linkData.shardIndex
                }
                return linkData.communityId
            }
            let updatedKey = inputKey
            if (inputKey.indexOf("#") !== -1) {
                // It's likely <encoded_data>#<community_chat_key> and we only want the community key
                updatedKey = inputKey.split("#")[1]
            }
            if (!root.utilsStore.isCommunityPublicKey(updatedKey)) {
                return ""
            }
            if (!root.utilsStore.isCompressedPubKey(updatedKey)) {
                return updatedKey
            }
            return root.utilsStore.changeCommunityKeyCompression(updatedKey)
        }
        readonly property bool isInputValid: publicKey !== ""

        property bool communityInfoRequested: false

        function updateCommunityDetails(requestIfNotFound) {
            if (!isInputValid) {
                d.communityInfoRequested = false
                d.communityDetails = null
                return
            }

            const details = root.store.getCommunityDetails(publicKey)

            if (!!details) {
                d.communityInfoRequested = false
                d.communityDetails = details
                return
            }

            if (requestIfNotFound) {
                root.store.requestCommunityInfo(publicKey, shardCluster, shardIndex, false)
                d.communityInfoRequested = true
                d.communityDetails = null
            }
        }

        onPublicKeyChanged: {
            // call later to make sure all proeprties used by `updateCommunityDetails` are udpated
            Qt.callLater(() => { d.updateCommunityDetails(true) })
        }
    }

    Connections {
        target: root.store

        function onCommunityInfoRequestCompleted(communityId, errorMsg) {
            if (!d.communityInfoRequested)
                return

            d.communityInfoRequested = false

            if (errorMsg !== "") {
                d.importErrorMessage = qsTr("Couldn't find community")
                return
            }

            d.updateCommunityDetails(false)
            d.importErrorMessage = ""
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                enabled: d.isInputValid && d.communityFound
                loading: d.isInputValid && !d.communityFound && d.communityInfoRequested
                text: qsTr("Join")
                onClicked: {
                    root.joinCommunityRequested(d.publicKey, d.communityDetails)
                }
            }
        }
    }

    StatusScrollView {
        id: scrollContent
        anchors.fill: parent
        anchors.leftMargin: Theme.halfPadding
        contentWidth: (root.width-Theme.bigPadding-Theme.padding)
        padding: 0

        ColumnLayout {
            width: (scrollContent.width-Theme.padding)
            spacing: Theme.halfPadding

            StatusBaseText {
                id: infoText1
                Layout.fillWidth: true
                text: qsTr("Enter the public key of the community you wish to access")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.additionalTextSize
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                id: inputLabel
                text: qsTr("Community key")
                color: Theme.palette.directColor1
            }
            StatusScrollView {
                padding: 0 // use our own (StatusTextArea) padding
                Layout.fillWidth: true
                Layout.preferredHeight: 108
                StatusTextArea {
                    id: keyInput
                    anchors.fill: parent
                    placeholderText: "zQ3..."
                    wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                    onTextChanged: d.importErrorMessage = ""
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 46
                Layout.maximumHeight: 46
                StatusChatInfoButton {
                    visible: d.communityFound
                    title: visible ? d.communityDetails.name : ""
                    subTitle: visible ? qsTr("%n member(s)", "", d.communityDetails.nbMembers) : ""
                    asset.name: visible ? d.communityDetails.image : ""
                    asset.isImage: (asset.name !== "")
                    asset.color: visible ? d.communityDetails.color : ""
                }
                Item { Layout.fillWidth: true }
                StatusBaseText {
                    id: detectionLabel
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: Theme.additionalTextSize
                    visible: !!d.inputKey
                    text: {
                        if (d.errorMessage !== "")
                            return d.errorMessage
                        if (d.isInputValid)
                            return qsTr("Public key detected")
                        return ""
                    }
                    color: d.errorMessage === "" ? Theme.palette.successColor1 : Theme.palette.dangerColor1
                }
            }
        }
    }
}
