import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    property var appSettings

    id: advancedContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: title
        //% "Advanced settings"
        text: qsTrId("advanced-settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    RowLayout {
        id: walletTabSettings
        anchors.top: title.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Wallet Tab"
            text: qsTrId("wallet-tab")
        }
        Switch {
            checked: walletBtn.enabled
            onCheckedChanged: function(value) {
                walletBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "NOT RECOMMENDED - Use at your own risk"
            text: qsTrId("not-recommended---use-at-your-own-risk")
        }
    }

    RowLayout {
        id: browserTabSettings
        anchors.top: walletTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Browser Tab"
            text: qsTrId("browser-tab")
        }
        Switch {
            checked: browserBtn.enabled
            onCheckedChanged: function(value) {
                browserBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "experimental (web3 not supported yet)"
            text: qsTrId("experimental-(web3-not-supported-yet)")
        }
    }

    RowLayout {
        id: nodeTabSettings
        anchors.top: browserTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Node Management Tab"
            text: qsTrId("node-management-tab")
        }
        Switch {
            checked: nodeBtn.enabled
            onCheckedChanged: function(value) {
                nodeBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "under development"
            text: qsTrId("under-development")
        }
    }
    
    RowLayout {
        id: networkTabSettings
        anchors.top: nodeTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Enable testnet (Ropsten)\nCurrent network: %1"
            text: qsTrId("enable-testnet--ropsten--ncurrent-network---1").arg(profileModel.network)
        }
        Switch {
            checked: profileModel.network === "testnet_rpc"
            onCheckedChanged: {
                if (checked && profileModel.network === "testnet_rpc" || !checked && profileModel.network === "mainnet_rpc"){
                    return;
                }
                profileModel.network = checked ? "testnet_rpc" : "mainnet_rpc";
            }
        }
        StyledText {
            //% "Under development\nNOTE: You will be logged out and all installed\nsticker packs will be removed and will\nneed to be reinstalled. Purchased sticker\npacks will not need to be re-purchased."
            text: qsTrId("under-development-nnote--you-will-be-logged-out-and-all-installed-nsticker-packs-will-be-removed-and-will-nneed-to-be-reinstalled--purchased-sticker-npacks-will-not-need-to-be-re-purchased-")
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
