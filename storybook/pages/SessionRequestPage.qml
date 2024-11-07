import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.services.dapps.types 1.0

SplitView {
    id: root
    orientation: Qt.Horizontal
    
    readonly property string sign: "{\n\
        \"id\": 1730473461432473,\n\
        \"params\": {\n\
            \"chainId\": \"eip155:1\",\n\
            \"request\": {\n\
                \"expiryTimestamp\": 1730473761,\n\
                \"method\": \"personal_sign\",\n\
                \"params\": [\n\
                    \"0x4d7920656d61696c206973206a6f686e40646f652e636f6d202d2031373330343733343631343331\",\n\
                    \"0x8b6950bb8a74489a83e6a1281e3aa008f02bf368\"\n\
                ]\n\
            },\n\
            \"topic\": \"3a9a320f8fc8e7a814895b148911373ba7df58c176ddca989f0e72ea1f9b8148\",\n\
            \"verifyContext\": {\n\
                \"verified\": {\n\
                    \"isScam\": false,\n\
                    \"origin\": \"https://react-app.walletconnect.com\",\n\
                    \"validation\": \"VALID\",\n\
                    \"verifyUrl\": \"https://verify.walletconnect.org\"\n\
                }\n\
            }\n\
        }\n\
    }"
    readonly property string transaction: "{\n\
        \"id\": 1730473547658704,\n\
        \"params\": {\n\
            \"chainId\": \"eip155:10\",\n\
            \"request\": {\n\
                \"expiryTimestamp\": 1730473847,\n\
                \"method\": \"eth_sendTransaction\",\n\
                \"params\": [\n\
                    {\n\
                        \"data\": \"0x\",\n\
                        \"from\": \"0x8b6950bb8a74489a83e6a1281e3aa008f02bf368\",\n\
                        \"gasLimit\": \"0x5208\",\n\
                        \"gasPrice\": \"0x0f437c\",\n\
                        \"nonce\": \"0x4e\",\n\
                        \"to\": \"0x8b6950bb8a74489a83e6a1281e3aa008f02bf368\",\n\
                        \"value\": \"0x00\"\n\
                    }\n\
                ]\n\
            }\n\
        },\n\
        \"topic\": \"3a9a320f8fc8e7a814895b148911373ba7df58c176ddca989f0e72ea1f9b8148\",\n\
        \"verifyContext\": {\n\
            \"verified\": {\n\
                \"isScam\": false,\n\
                \"origin\": \"https://react-app.walletconnect.com\",\n\
                \"validation\": \"VALID\",\n\
                \"verifyUrl\": \"https://verify.walletconnect.org\"\n\
            }\n\
        }\n\
    }"
    ScrollView {
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        TextArea {
            id: result
            text: "Result: " + JSON.stringify(SessionRequest.parse(JSON.parse(textEdit.text.replace(/\\n/g, "\n"))), undefined, 2)
            readOnly: true
        }
    }

    ColumnLayout {
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        SplitView.preferredWidth: root.width / 2
        Label {
            text: "Paste the event here to simulate the session request parsing"
            font.bold: true
        }
        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "black"
        }
        TextArea {
            id: textEdit
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: root.transaction
            onTextChanged: text = JSON.stringify(JSON.parse(text.replace(/\\/g, "")), undefined, 2)
        }
        ComboBox {
            id: comboBox
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: ["sign", "transaction"]
            currentIndex: 0
            onCurrentIndexChanged: textEdit.text = root[comboBox.currentText]
        }
    }
}