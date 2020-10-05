import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
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
        font.pixelSize: Style.current.actionTextFontSize
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
        StatusSwitch {
            checked: appSettings.walletEnabled
            onCheckedChanged: function(value) {
                appSettings.walletEnabled = this.checked
            }
        }
        StyledText {
            //% "NOT RECOMMENDED - Use at your own risk"
            text: qsTrId("not-recommended---use-at-your-own-risk")
        }
    }

    RowLayout {
        id: nodeTabSettings
        anchors.top: walletTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Node Management Tab"
            text: qsTrId("node-management-tab")
        }
        StatusSwitch {
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
        StatusSwitch {
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

    RowLayout {
        id: uiCatalog
        anchors.top: networkTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        Component.onCompleted: {
            uiComponentBtn.enabled = false
        }

        StyledText {
            //% "UI Components"
            text: qsTrId("ui-components")
        }

        StatusSwitch {
            checked: uiComponentBtn.enabled
            onCheckedChanged: function(value) {
                uiComponentBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "Developer setting"
            text: qsTrId("developer-setting")
        }
    }

}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
