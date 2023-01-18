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

    QtObject {
        id: d
        property string importErrorMessage
        readonly property string inputErrorMessage: isInputValid ? "" : qsTr("Invalid key")
        readonly property string errorMessage: importErrorMessage || inputErrorMessage
        readonly property bool isPrivateKey: Utils.isPrivateKey(keyInput.text)
        readonly property bool isPublicKey: Utils.isChatKey(keyInput.text)
        readonly property bool isInputValid: isPrivateKey || isPublicKey
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")
                onClicked: root.reject()
            }
            StatusButton {
              id: importButton
              enabled: d.isInputValid
              text: d.isPrivateKey ? qsTr("Make this an Owner Node") : qsTr("Import")
              onClicked: {
                  let communityKey = keyInput.text.trim();
                  if (d.isPrivateKey) {
                    if (!communityKey.startsWith("0x")) {
                        communityKey = "0x" + communityKey;
                    }
                    root.store.importCommunity(communityKey);
                    root.close();
                  }
                  if (d.isPublicKey) {
                    importButton.loading = true
                    root.store.requestCommunityInfo(communityKey, true)
                    root.close();
                  }
              }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.padding

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
            placeholderText: "0x0..."
            height: 110
            Layout.fillWidth: true
            onTextChanged: d.importErrorMessage = ""
          }

        StatusBaseText {
            id: detectionLabel
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
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


    Connections {
      target: root.store
      function onImportingCommunityStateChanged(communityId, state, errorMsg) {
          let communityKey = keyInput.text.trim();
          if (d.isPublicKey) {
              let currentCommunityKey = Utils.isCompressedPubKey(communityKey) ?
                  Utils.changeCommunityKeyCompression(communityKey) :
                  communityKey

              if (communityId == currentCommunityKey) {
                  importButton.loading = false
                  if (state === Constants.communityImported && root.opened) {
                    root.close()
                    return
                  }
              }

              if (state === Constants.communityImportingError) {
                d.importErrorMessage = errorMsg
                importButton.loading = false
              }
          }
      }
    }
}
