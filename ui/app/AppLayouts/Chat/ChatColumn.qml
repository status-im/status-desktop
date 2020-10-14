import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"
import "./components"
import "./ChatColumn"
import "./ChatColumn/ChatComponents"
import "./data"

StackLayout {
    id: chatColumnLayout
    property int chatGroupsListViewCount: 0

    property bool isUserAllowed: !chatsModel.activeChannel.name.startsWith(Constants.moderatedChannelPrefix)
    
    property bool isReply: false
    property bool isImage: false

    property bool isExtendedInput: isReply || isImage

    property bool isConnected: false
    property string contactToRemove: ""

    property var onActivated: function () {
        chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Component.onCompleted: {
        chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.minimumWidth: 300

    currentIndex:  chatsModel.activeChannelIndex > -1 && chatGroupsListViewCount > 0 ? 0 : 1

    function showReplyArea() {
        isReply = true;
        isImage = false;
        let replyMessageIndex = chatsModel.messageList.getMessageIndex(SelectedMessage.messageId);
        if (replyMessageIndex === -1) return;
        
        let userName = chatsModel.messageList.getMessageData(replyMessageIndex, "userName")
        let message = chatsModel.messageList.getMessageData(replyMessageIndex, "message")
        let identicon = chatsModel.messageList.getMessageData(replyMessageIndex, "identicon")

        chatInput.showReplyArea(userName, message, identicon)
    }

    function requestAddressForTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  walletModel.eth2Wei(amount.toString(), tokenDecimals)
        chatsModel.requestAddressForTransaction(chatsModel.activeChannel.id,
                                                address,
                                                amount,
                                                tokenAddress)
        chatCommandModal.close()
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  walletModel.eth2Wei(amount.toString(), tokenDecimals)
        chatsModel.requestTransaction(chatsModel.activeChannel.id,
                                      address,
                                      amount,
                                      tokenAddress)
        chatCommandModal.close()
    }

    Connections {
        target: chatView
        onUserAllowedFetched: {
            if (hashedChatId === utilsModel.channelHash(chatsModel.activeChannel.name).toLowerCase() && address === utilsModel.derivedAnUserAddress(profileModel.profile.pubKey).toLowerCase()) {
                chatColumnLayout.isUserAllowed = allowed
            }
        }
    }

    function checkIfUserIsAllowed() {
        const allowed = fetchUserAllowed(chatsModel.activeChannel.name, profileModel.profile.pubKey)
        if (allowed !== Constants.fetching) {
            chatColumnLayout.isUserAllowed = allowed
        }
    }

    
    ColumnLayout {
        spacing: 0

        RowLayout {
            id: chatTopBar
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            z: 60
            spacing: 0
            TopBar {
                id: topBar
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            z: 60
            Rectangle {
                Component.onCompleted: {
                    isConnected = chatsModel.isOnline
                    if(!isConnected){
                        connectedStatusRect.visible = true
                    }
                }

                id: connectedStatusRect
                Layout.fillWidth: true
                height: 40;
                color: isConnected ? Style.current.green : Style.current.darkGrey
                visible: false
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: Style.current.white
                    id: connectedStatusLbl
                    text: isConnected ?
                              //% "Connected"
                              qsTrId("connected") :
                              //% "Disconnected"
                              qsTrId("disconnected")
                }
            }

            Timer {
                id: timer
            }
        }

        RowLayout {
            id: chatContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            spacing: 0
            ChatMessages {
                id: chatMessages
                messageList: chatsModel.messageList
            }
        }

        ImagePopup {
            id: imagePopup
        }

        EmojiReactions {
            id: reactionModel
        }

        MessageContextMenu {
            id: messageContextMenu
        }

        ListModel {
            id: suggestions
        }

        Connections {
            target: chatsModel
            onActiveChannelChanged: {
                checkIfUserIsAllowed()

                chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
                suggestions.clear()
                for (let i = 0; i < chatsModel.suggestionList.rowCount(); i++) {
                    suggestions.append({
                                           alias: chatsModel.suggestionList.rowData(i, "alias"),
                                           ensName: chatsModel.suggestionList.rowData(i, "ensName"),
                                           address: chatsModel.suggestionList.rowData(i, "address"),
                                           identicon: chatsModel.suggestionList.rowData(i, "identicon"),
                                           ensVerified: chatsModel.suggestionList.rowData(i, "ensVerified")
                                       });
                }
            }
            onOnlineStatusChanged: {
                if (connected == isConnected) return;
                isConnected = connected;
                if(isConnected){
                    checkIfUserIsAllowed()
                    timer.setTimeout(function(){
                        connectedStatusRect.visible = false;
                    }, 5000);
                } else {
                    connectedStatusRect.visible = true;
                }
            }
        }


        Rectangle {
            id: notAllowedArea
            visible: !chatColumnLayout.isUserAllowed
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            height: visible ? infotext.height + 2 * Style.current.halfPadding : 0
            Layout.preferredHeight: height
            color: "transparent"

            StyledText {
                id: infotext
                text: qsTr("You do not have permission to write in this moderated chat.\nTo get access to it, click on the button here to burn SNT and join the channel\nDo note that since this channel is moderated, you can get removed at any time if you spam or say anything discriminatory")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Style.current.halfPadding
                anchors.right: joinButton.left
                anchors.rightMargin: Style.current.halfPadding
                wrapMode: Text.WordWrap
            }

            StyledButton {
                id: joinButton
                label: qsTr("Join this chat")
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    walletModel.setFocusedAccountByAddress(walletModel.getDefaultAddress())
                    var acc = walletModel.focusedAccount
                    signTransactionModal.selectedAccount = {
                        name: acc.name,
                        address: walletModel.getDefaultAddress(),
                        iconColor: acc.iconColor,
                        assets: acc.assets
                    }
                    signTransactionModal.open()
                }
            }

            XDaiTransactionDoneModal {
                id: xDaiTransactionDoneModal
            }

            SignXdaiTransaction  {
                id: signTransactionModal
                signTransaction: (fromAddress, contractAddress, gasLimit, gasPrice, password) => {
                                     const request = { type: "getNonce", payload: fromAddress }
                                     ethersChannel.postMessage(request, (nonce) => {
                                                                   // TODO change this to a burn when the allowUser is only for moderators
                                                                   const request = {type: "allowUser", payload: [utilsModel.channelHash(chatsModel.activeChannel.name), utilsModel.derivedAnUserAddress(profileModel.profile.pubKey)]}
                                                                   ethersChannel.postMessage(request, (data) => {
                                                                                                 // Signing a transaction:
                                                                                                 const signature = walletModel.signTransaction(fromAddress, contractAddress, "0", gasLimit, gasPrice, nonce.toString(), data, password, 100);

                                                                                                 // Broadcast the transaction
                                                                                                 const request = { type: "broadcast", payload: JSON.parse(signature).result };
                                                                                                 ethersChannel.postMessage(request, (trxHash, error) => {
                                                                                                                               if(error){
                                                                                                                                   console.log("ERROR!", error);
                                                                                                                               } else {
                                                                                                                                   console.log("Success adding user", trxHash)
                                                                                                                                   xDaiTransactionDoneModal.txHash = trxHash
                                                                                                                                   xDaiTransactionDoneModal.channelname = chatsModel.activeChannel.name
                                                                                                                                   xDaiTransactionDoneModal.open()
                                                                                                                                   signTransactionModal.close()
                                                                                                                               }
                                                                                                                           });

                                                                                             });
                                                               });
                                 }
            }
        }

        Rectangle {
            id: inputArea
            visible: chatColumnLayout.isUserAllowed
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            height: visible ? chatInput.height : 0
            Layout.preferredHeight: height
            color: "transparent"

            SuggestionBox {
                id: suggestionsBox
                model: suggestions
                width: chatContainer.width
                anchors.bottom: inputArea.top
                anchors.left: inputArea.left
                filter: chatInput.textInput.text
                cursorPosition: chatInput.textInput.cursorPosition
                property: "ensName, alias"
                onItemSelected: function (item, lastAtPosition, lastCursorPosition) {
                    let hasEmoji = Emoji.hasEmoji(chatInput.textInput.text)
                    let currentText = hasEmoji ?
                            chatsModel.plainText(Emoji.deparse(chatInput.textInput.text)) :
                            chatsModel.plainText(chatInput.textInput.text);

                    let aliasName = item[suggestionsBox.property.split(",").map(p => p.trim()).find(p => !!item[p])]
                    aliasName = aliasName.replace(".stateofus.eth", "")
                    let nameLen = aliasName.length + 2 // We're doing a +2 here because of the `@` and the trailing whitespace
                    let position = 0;
                    let text = ""

                    if (currentText === "@") {
                        position = nameLen
                        text = "@" + aliasName + " "
                    } else {
                        let left = currentText.substring(0, lastAtPosition)
                        let right = currentText.substring(hasEmoji ? lastCursorPosition + 2 : lastCursorPosition)
                        text = `${left} @${aliasName} ${right}`
                    }

                    chatInput.textInput.text = hasEmoji ? Emoji.parse(text, "26x26") : text
                    chatInput.textInput.cursorPosition = lastAtPosition + aliasName.length + 2
                    suggestionsBox.suggestionsModel.clear()
                }
            }
            
            Loader {
                active: chatsModel.loadingMessages
                sourceComponent: loadingIndicator
                anchors.right: parent.right
                anchors.bottom: chatInput.top
                anchors.rightMargin: Style.current.padding
                anchors.bottomMargin: Style.current.padding
            }

            Component {
                id: loadingIndicator
                SVGImage {
                    id: loadingImg
                    source: "../../../app/img/loading.svg"
                    width: 25
                    height: 25
                    fillMode: Image.Stretch
                    RotationAnimator {
                        target: loadingImg;
                        from: 0;
                        to: 360;
                        duration: 1200
                        running: true
                        loops: Animation.Infinite
                    }
                }
            }

            StatusChatInput {
                id: chatInput
                anchors.bottom: parent.bottom
                recentStickers: chatsModel.recentStickers
                stickerPackList: chatsModel.stickerPacks
                chatType: chatsModel.activeChannel.chatType
                onSendTransactionCommandButtonClicked: {
                    chatCommandModal.sendChatCommand = chatColumnLayout.requestAddressForTransaction
                    chatCommandModal.isRequested = false
                    //% "Send"
                    chatCommandModal.commandTitle = qsTrId("command-button-send")
                    chatCommandModal.title = chatCommandModal.commandTitle
                    //% "Request Address"
                    chatCommandModal.finalButtonLabel = qsTrId("request-address")
                    chatCommandModal.selectedRecipient = {
                        address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                        identicon: chatsModel.activeChannel.identicon,
                        name: chatsModel.activeChannel.name,
                        type: RecipientSelector.Type.Contact
                    }
                    chatCommandModal.open()
                }
                onReceiveTransactionCommandButtonClicked: {
                    chatCommandModal.sendChatCommand = root.requestTransaction
                    chatCommandModal.isRequested = true
                    //% "Request"
                    chatCommandModal.commandTitle = qsTrId("wallet-request")
                    chatCommandModal.title = chatCommandModal.commandTitle
                    //% "Request"
                    chatCommandModal.finalButtonLabel = qsTrId("wallet-request")
                    chatCommandModal.selectedRecipient = {
                        address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                        identicon: chatsModel.activeChannel.identicon,
                        name: chatsModel.activeChannel.name,
                        type: RecipientSelector.Type.Contact
                    }
                    chatCommandModal.open()
                }
                onStickerSelected: {
                    chatsModel.sendSticker(hashId, packId)
                }
            }
        }
    }

    EmptyChat {}

    ChatCommandModal {
        id: chatCommandModal
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:770;width:800}
}
##^##*/
