import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    height: 504

    property string txHash: ""

    onOpened: {
        channelname.text = "";
        txHash = ""
    }

    function signTx(fromAddress, contractAddress, gasLimit, gasPrice, password) {
        const request = { type: "getNonce", payload: fromAddress }
        ethersChannel.postMessage(request, (nonce) => {
                                      const request = {type: "registerChannel", payload: [utilsModel.channelHash(channelname.text), utilsModel.derivedAnUserAddress(profileModel.profile.pubKey)]}
                                      ethersChannel.postMessage(request, (data) => {
                                                                    // Signing a transaction
                                                                    const signature = walletModel.signTransaction(fromAddress,
                                                                                                                  contractAddress,
                                                                                                                  "0",
                                                                                                                  gasLimit,
                                                                                                                  gasPrice,
                                                                                                                  nonce.toString(),
                                                                                                                  data,
                                                                                                                  password,
                                                                                                                  100);

                                                                    // Broadcast the transaction
                                                                    const request = { type: "broadcast", payload: JSON.parse(signature).result };
                                                                    ethersChannel.postMessage(request, (trxHash, error) => {
                                                                                                  if(error){
                                                                                                      console.error("ERROR!", error);
                                                                                                  } else {
                                                                                                      // TODO find a way to wait for the TX to end
                                                                                                      popup.txHash = trxHash
                                                                                                      signPermissionedChatCreationModal.close()
                                                                                                  }
                                                                                              });

                                                                });
                                  });

    }

    function doCreate(channelName){
        walletModel.setFocusedAccountByAddress(walletModel.getDefaultAddress())
        var acc = walletModel.focusedAccount
        signPermissionedChatCreationModal.selectedAccount = {
            name: acc.name,
            address: walletModel.getDefaultAddress(),
            iconColor: acc.iconColor,
            assets: acc.assets
        }

        signPermissionedChatCreationModal.open()
    }

    function doJoin(channelName){
        chatsModel.joinChat(channelName, Constants.chatTypePublic);
        popup.close();
    }

    function checkChannelExistence(channelName) {
        const request = {
            type: "channels",
            payload: [utilsModel.channelHash(channelName)]
        }
        ethersChannel.postMessage(request, (channel) => {
                                      if (channel === Constants.zeroAddress) {
                                          // New channel, call create
                                          return doCreate(channelName)
                                      }
                                      doJoin(channelName)
                                  })
    }

    title: qsTr("New Moderated Chat")

    Item {
        anchors.fill: parent
        visible: popup.txHash === ""

        StyledText {
            id: chatInfo
            text: qsTr("A Moderated chat is a channel that everyone can look at, but only the allowed members can write. It's perfect to reduce the risk of spam and create communities")
            color: Style.current.darkGrey
            font.pixelSize: 15
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Input {
            id: channelname
            label: qsTr("Channel name")
            placeholderText: qsTr("Channel name")
            textField.text: Constants.moderatedChannelPrefix
            textField.onTextChanged: {
                if (!textField.text.startsWith(Constants.moderatedChannelPrefix)) {
                    // Make sure moderated- is always at the start
                    // The regex makes it so that we don,t just duplicate moderated- but instead replaces what's there
                    textField.text = textField.text.replace(/m?o?d?e?r?a?t?e?d?-?/, Constants.moderatedChannelPrefix)
                }
            }
            anchors.top: chatInfo.bottom
            anchors.topMargin: Style.current.smallPadding
        }
    }

    Item {
        id: txSentItem
        anchors.fill: parent
        visible: popup.txHash !== ""

        StyledText {
            id: text1
            text: qsTr("Transaction successfully sent. You can watch the progress by clicking the button below")
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            wrapMode: "WordWrap"
        }

        StyledButton {
            id: btn1
            label: qsTr("Go to block explorer")
            anchors.top: text1.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: Qt.openUrlExternally(`https://blockscout.com/poa/xdai/tx/${popup.txHash}/internal-transactions`)
        }

        StyledText {
            id: text2
            text: qsTr("Once the transaction is done, you can open the channel")
            anchors.top: btn1.bottom
            anchors.topMargin: Style.current.padding
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            wrapMode: "WordWrap"
        }

        StyledButton {
            label: qsTr("Go to channel")
            anchors.top: text2.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Style.current.smallPadding
            onClicked: {
                chatsModel.joinChat(channelname.text, Constants.chatTypePublic);
                popup.close();
            }
        }
    }
    
    footer: Item {
        anchors.top: parent.bottom
        anchors.right: parent.right
        anchors.bottom: popup.bottom
        anchors.left: parent.left

        StyledButton {
            visible: popup.txHash === ""
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            label: qsTr("Join channel or create it")
            disabled: channelname.text === ""
            onClicked : checkChannelExistence(channelname.text)
        }

        SignPermissionedChatCreation {
            id: signPermissionedChatCreationModal
            signTransaction: signTx
        }
    }
}

