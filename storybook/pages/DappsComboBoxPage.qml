import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Wallet.controls

SplitView {
    id: root

    width: 400
    height: 400

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        DappsComboBox {
            id: connectedDappComboBox
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            model: emptyModelCheckbox.checked ? emptyModel : smallModelCheckbox.checked ? smallModel: dappsModel
            popup.visible: true
            enabled: enabledCheckbox.checked

            onDappListRequested: {
                console.log("Dapps list requested")
            }
            onConnectDapp: {
                console.log("Connect dapp")
            }
            onDisconnectDapp: {
                console.log("Disconnect dapp")
            }
        }

        ListModel {
            id: emptyModel
        }

        ListModel {
            id: smallModel
            ListElement {
                name: "SMALL Model"
                url: "https://dapp.test/1"
                iconUrl: "https://se-sdk-dapp.vercel.app/assets/eip155:1.png"
                connectorBadge: "https://random.imagecdn.app/20/20"
            }
        }

        ListModel {
            id: dappsModel
            ListElement {
                name: ""
                url: "https://dapp.test/1"
                iconUrl: "https://se-sdk-dapp.vercel.app/assets/eip155:1.png"
                connectorBadge: "https://random.imagecdn.app/20/20"
            }
            ListElement {
                name: "Test dApp 2"
                url: "https://dapp.test/2"
                iconUrl: ""
                connectorBadge: "https://random.imagecdn.app/20/20"
            }
            ListElement {
                name: ""
                url: "https://dapp.test/3"
                iconUrl: ""
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 4 - very long name !!!!!!!!!!!!!!!!"
                url: "https://dapp.test/4"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 5 - very long url"
                url: "https://dapp.test/very_long/url/unusual"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 6"
                url: "https://dapp.test/6"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 7"
                url: "https://dapp.test/7"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 8"
                url: "https://dapp.test/8"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 9"
                url: "https://dapp.test/9"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 10"
                url: "https://dapp.test/10"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
            ListElement {
                name: "Test dApp 11"
                url: "https://dapp.test/11"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
                connectorBadge: ""
            }
        }
    }

    Pane {
        id: controls
        SplitView.preferredWidth: 300
        SplitView.fillHeight: true

        ColumnLayout {
            RadioButton {
                text: "Default model"
                checked: true
            }

            RadioButton {
                id: emptyModelCheckbox
                text: "Empty model"
            }

            RadioButton {
                id: smallModelCheckbox
                text: "Small model"
            }

            CheckBox {
                id: enabledCheckbox
                text: "Enabled"
                checked: true
            }
        }
    }
}

// category: Controls

// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=130-31949&t=hnzB58fTnEnx2z84-0
// https://www.figma.com/design/1OYKMzU6KTQHQAqDhojk0r/Status-connector?node-id=3216-5618&node-type=FRAME&t=CqsuoQHp1p5MOUt9-0
