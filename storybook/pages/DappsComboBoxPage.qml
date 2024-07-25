import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

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
            model: emptyModelCheckbox.checked ? emptyModel : dappsModel
            popup.visible: true
        }

        ListModel {
            id: emptyModel
        }

        ListModel {
            id: dappsModel
            ListElement {
                name: ""
                url: "https://dapp.test/1"
                iconUrl: "https://se-sdk-dapp.vercel.app/assets/eip155:1.png"
            }
            ListElement {
                name: "Test dApp 2"
                url: "https://dapp.test/2"
                iconUrl: ""
            }
            ListElement {
                name: ""
                url: "https://dapp.test/3"
                iconUrl: ""
            }
            ListElement {
                name: "Test dApp 4 - very long name !!!!!!!!!!!!!!!!"
                url: "https://dapp.test/4"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
            ListElement {
                name: "Test dApp 5 - very long url"
                url: "https://dapp.test/very_long/url/unusual"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
            ListElement {
                name: "Test dApp 6"
                url: "https://dapp.test/6"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
            ListElement {
                name: "Test dApp 7"
                url: "https://dapp.test/7"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
            ListElement {
                name: "Test dApp 8"
                url: "https://dapp.test/8"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
            ListElement {
                name: "Test dApp 9"
                url: "https://dapp.test/9"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
            ListElement {
                name: "Test dApp 10"
                url: "https://dapp.test/10"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
            ListElement {
                name: "Test dApp 11"
                url: "https://dapp.test/11"
                iconUrl: "https://react-app.walletconnect.com/assets/eip155-1.png"
            }
        }
    }

    Pane {
        id: controls
        SplitView.preferredWidth: 300
        SplitView.fillHeight: true

        ColumnLayout {
            CheckBox {
                id: emptyModelCheckbox
                text: "Empty model"
                checked: false
            }
        }
    }
}

// category: Controls

// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=130-31949&t=hnzB58fTnEnx2z84-0