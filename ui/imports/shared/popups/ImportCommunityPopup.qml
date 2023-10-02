import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import QtQml.Models 2.14

import utils 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1

StatusDialog {
    id: root
    property var store
    width: 640
    title: qsTr("Import Community")

    signal joinCommunity(string communityId, var communityDetails)
    QtObject {
        id: d
        property string importErrorMessage

        readonly property bool communityFound: (d.communityDetails !== null && !!d.communityDetails.name)
        readonly property var communityDetails: {
            if (isInputValid) {
                let key = isPublicKey ? Utils.getCompressedPk(publicKey) :
                          root.store.getCommunityPublicKeyFromPrivateKey(inputKey);
                return root.store.getCommunityDetails(key);
            } else {
                return null;
            }
        }

        readonly property string inputErrorMessage: isInputValid ? "" : qsTr("Invalid key")
        readonly property string errorMessage: importErrorMessage || inputErrorMessage
        readonly property string inputKey: keyInput.text.trim()
        readonly property bool isPrivateKey: (Utils.isPrivateKey(inputKey))
        readonly property bool isPublicKey: (publicKey !== "")
        readonly property string privateKey: inputKey
        readonly property string publicKey: {
            if (!Utils.isStatusDeepLink(inputKey)) {
                const key = Utils.dropCommunityLinkPrefix(inputKey)
                if (!Utils.isCommunityPublicKey(key))
                    return ""
                if (!Utils.isCompressedPubKey(key))
                    return key
                return Utils.changeCommunityKeyCompression(key)
            } else {
                return Utils.getCommunityDataFromSharedLink(inputKey).communityId;
            }
        }
        readonly property bool isInputValid: isPrivateKey || isPublicKey
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                id: importButton
                enabled: (d.isInputValid && (d.isPrivateKey && d.communityFound ? agreeToKeepOnline.checked : true))
                loading: (enabled && !d.communityFound)
                text: !d.publicKey ? qsTr("Make this device the control node for %1").arg((!loading && !!d.communityDetails) ? d.communityDetails.name : "")
                                   : qsTr("Import")
                onClicked: {
                    if (d.isPrivateKey) {
                        root.store.importCommunity(d.privateKey);
                        root.close();
                    } else if (d.isPublicKey) {
                        root.joinCommunity(d.publicKey, d.communityDetails);
                    }
                }
            }
        }
    }


    StatusScrollView {
        id: scrollContent
        anchors.fill: parent
        anchors.leftMargin: Style.current.halfPadding
        contentWidth: (root.width-Style.current.bigPadding-Style.current.padding)
        padding: 0

        ColumnLayout {
            width: (scrollContent.width-Style.current.padding)
            spacing: Style.current.halfPadding

            StatusBaseText {
                id: infoText1
                Layout.fillWidth: true
                text: qsTr("Enter the public key of the community you wish to access, or enter the private key of a community you own. Remember to always keep any private key safe and never share a private key with anyone else.")
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                id: inputLabel
                text: qsTr("Community key")
                color: Theme.palette.directColor1
                font.pixelSize: 15
            }

            StatusTextArea {
                id: keyInput
                Layout.fillWidth: true
                Layout.preferredHeight: 108
                placeholderText: "0x0..."
                wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                onTextChanged: d.importErrorMessage = ""
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
                    font.pixelSize: 13
                    visible: keyInput.text.trim() !== ""
                    text: {
                        if (d.errorMessage !== "") {
                            return d.errorMessage
                        }
                        if (d.isPrivateKey) {
                            return qsTr("Private key detected")
                        }
                        if (d.isPublicKey) {
                            return qsTr("Public key detected")
                        }
                    }
                    color: d.errorMessage === "" ? Theme.palette.successColor1 : Theme.palette.dangerColor1
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: (d.communityFound && d.isPrivateKey)
                Layout.topMargin: 12
                spacing: Style.current.padding
                StatusWarningBox {
                    Layout.fillWidth: true
                    icon: "caution"
                    text: qsTr("Another device might currently have the control node for this Community. Running multiple control nodes will cause unforeseen issues. Make sure you delete the private key in that other device in the community management tab.")
                    bgColor: borderColor
                }
                StatusDialogDivider { Layout.fillWidth: true; Layout.topMargin: Style.current.padding }
                StatusBaseText {
                    Layout.topMargin: Style.current.halfPadding
                    visible: (d.communityFound && d.isPrivateKey)
                    font.pixelSize: Style.current.primaryTextFontSize
                    text: qsTr("I acknowledge that...")
                }
                StatusCheckBox {
                    id: agreeToKeepOnline
                    Layout.fillWidth: true
                    font.pixelSize: Style.current.primaryTextFontSize
                    text: qsTr("I must keep this device online and running Status for the Community to function")
                }
            }
        }
    }
}
