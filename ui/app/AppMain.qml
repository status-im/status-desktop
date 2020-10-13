import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared"
import "./AppLayouts"
import QtWebEngine 1.10
import QtWebChannel 1.13

RowLayout {
    id: appMain
    spacing: 0
    Layout.fillHeight: true
    Layout.fillWidth: true



    QtObject {
        id: ethersChannel
        WebChannel.id: "backend"

        property int messageId: 0

        property var cbDictionary: ({})

        signal post(string data);

        function postMessage(data, cb) {
            messageId++;
            if(cb){
                cbDictionary[messageId] = cb;
            }
            post(JSON.stringify({messageId, data}));
        }

        function response(requestId, data){
            var responseData = JSON.parse(data);
            if(cbDictionary[requestId]){
                cbDictionary[requestId](responseData);
            }
        }

        function error(requestId, error){
            if(cbDictionary[requestId]){
                cbDictionary[requestId](null, error);
            }
        }
    }

    WebChannel {
        id: channel
        registeredObjects: [ethersChannel]
    }

    Column {
        width: Math.max(sendMsg.width, signBroadcastRawTrx.width)
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop

        Button {
            id: sendMsg
            text: "IsUserAllowed"

            onClicked: {
                const request = {
                    type: "isUserAllowed",
                               // keccak(ChannelID),                                                // user address derived from pubkey
                    payload: ["0x1122334455667788990011223344556677889900112233445566778899001122", "0x66C0DC5111673DDC578b5B1c36412578E2de68B6"]
                }


                // isOperator
                //const request = {
                //    type: "isUserAllowed",
                //    payload: ["0x1122334455667788990011223344556677889900112233445566778899001122", "0x66C0DC5111673DDC578b5B1c36412578E2de68B6"]
                //}

                // getUsers                                 // ChannelId
                // const request = {type:"getUsers", payload: "0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658"}

                // getOperators                                 // ChannelId
                // const request = {type:"getOperators", payload: "0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658"}



                ethersChannel.postMessage(request, (message) => {
                    console.log("User is allowed: ", message);
                });
            }

        }

        Button {
            id: signBroadcastRawTrx
            text: "SignAndBroadcastRawTransaction"
            onClicked: {
                const request = { type: "getNonce", payload: walletModel.getDefaultAddress() }
                ethersChannel.postMessage(request, (nonce) => {
                    // Signing a transaction:
                    const password = "richard"; // TODO: replace with a more safe password :-P                                                                           gwei
                    const signature = walletModel.signTransaction(walletModel.getDefaultAddress(), "0x5f66406B79CD80e4F9D33E3153b94B174839a449", "2000000000", "21000", "1", nonce.toString(), "", password, 100);

                    // Broadcast the transaction
                    const request = { type: "broadcast", payload: JSON.parse(signature).result };
                    ethersChannel.postMessage(request, (trxHash, error) => {
                        if(error){
                            console.log("ERROR!", error);
                        } else {
                            console.log("Success", trxHash)
                        }
                    });
                });
            }
        }

        Button {
            id: registerChannelBtn
            text: "Registering test4 channel"
            onClicked: {
                // Do promises work in qml?
                const request = { type: "getNonce", payload: walletModel.getDefaultAddress() }
                ethersChannel.postMessage(request, (nonce) => {

                    const request = {type: "registerChannel", payload: utilsModel.channelHash("test4")}
                    ethersChannel.postMessage(request, (data) => {

                        // Signing a transaction:
                        const password = "richard"; // TODO: replace with a more safe password :-P       contract address                                           gwei
                        const signature = walletModel.signTransaction(walletModel.getDefaultAddress(), "0x025Da72d4389ff2479aBe291F9aB716a70003b7f", "0", "100000", "1", nonce.toString(), data, password, 100);

                        // Broadcast the transaction
                        const request = { type: "broadcast", payload: JSON.parse(signature).result };
                        ethersChannel.postMessage(request, (trxHash, error) => {
                            if(error){
                                console.log("ERROR!", error);
                            } else {
                                console.log("Success registering channel", trxHash)
                            }
                        });

                    });
                });
            }
        }

        Button {
            id: allowUser
            text: "Allow user"
            onClicked: {
                // Do promises work in qml?
                const request = { type: "getNonce", payload: walletModel.getDefaultAddress() }
                ethersChannel.postMessage(request, (nonce) => {

                    const request = {type: "allowUser", payload: [utilsModel.channelHash("test4"), "0x0011223344556677889900112233445566778899"]}
                    ethersChannel.postMessage(request, (data) => {

                        // Signing a transaction:
                        const password = "richard"; // TODO: replace with a more safe password :-P       contract address                                           gwei
                        const signature = walletModel.signTransaction(walletModel.getDefaultAddress(), "0x025Da72d4389ff2479aBe291F9aB716a70003b7f", "0", "100000", "1", nonce.toString(), data, password, 100);

                        // Broadcast the transaction
                        const request = { type: "broadcast", payload: JSON.parse(signature).result };
                        ethersChannel.postMessage(request, (trxHash, error) => {
                            if(error){
                                console.log("ERROR!", error);
                            } else {
                                console.log("Success allowing user into channel", trxHash)
                            }
                        });

                    });
                });
            }
        }
    }

    WebEngineView {
        id: ethersWebView
        visible: true
        webChannel: channel
        url: "qrc://ui/app/AppLayouts/POA/ethers.html"
    }


    ToastMessage {
        id: toastMessage
    }

    TabBar {
        id: tabBar
        width: 78
        Layout.maximumWidth: 80
        Layout.preferredWidth: 80
        Layout.minimumWidth: 80
        currentIndex: 0
        topPadding: 57
        rightPadding: 19
        leftPadding: 19
        transformOrigin: Item.Top
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillHeight: true
        spacing: 5
        background: Rectangle {
            color: "#00000000"
            border.color: Style.current.border
        }

        TabButton {
            id: chatBtn
            x: 0
            width: 40
            height: 40
            text: ""
            padding: 0
            transformOrigin: Item.Center
            anchors.horizontalCenter: parent.horizontalCenter
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/messageActive.svg" : "img/message.svg"
            }

            Rectangle {
                visible: chatsModel.unreadMessagesCount > 0
                anchors.top: image.top
                anchors.left: image.right
                anchors.leftMargin: -10
                anchors.topMargin: -5
                radius: 9
                color: Style.current.blue
                width: chatsModel.unreadMessagesCount < 10 ? 18 : messageCount.width + 10
                height: 18
                Text {
                    id: messageCount
                    font.pixelSize: chatsModel.unreadMessagesCount > 99 ? 10 : 12
                    color: Style.current.white
                    anchors.centerIn: parent
                    text: chatsModel.unreadMessagesCount
                }
            }

        }

        TabButton {
            id: walletBtn
            enabled: isExperimental === "1" || appSettings.walletEnabled
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: chatBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image1
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/walletActive.svg" : "img/wallet.svg"
            }
        }

        TabButton {
            id: browserBtn
            enabled: isExperimental === "1" || appSettings.browserEnabled
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: walletBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image2
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/compassActive.svg" : "img/compass.svg"
            }
        }

        TabButton {
            id: profileBtn
            width: 40
            height: 40
            text: ""
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: browserBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image3
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/profileActive.svg" : "img/profile.svg"
            }
        }

        TabButton {
            id: nodeBtn
            enabled: isExperimental === "1"
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: profileBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image4
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/nodeActive.svg" : "img/node.svg"
            }
        }

        TabButton {
            id: uiComponentBtn
            enabled: isExperimental === "1"
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: nodeBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image5
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/nodeActive.svg" : "img/node.svg"
            }
        }
    }

    StackLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex
        onCurrentIndexChanged: {
            if (typeof this.children[currentIndex].onActivated === "function") {
                this.children[currentIndex].onActivated()
            }
        }

        ChatLayout {
            id: chatLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        WalletLayout {
            id: walletLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        BrowserLayout {
            id: browserLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        ProfileLayout {
            id: profileLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        NodeLayout {
            id: nodeLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        UIComponents {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.33000001311302185;height:770;width:1232}
}
##^##*/
