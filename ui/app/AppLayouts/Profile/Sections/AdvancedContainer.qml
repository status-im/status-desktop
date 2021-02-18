import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: advancedContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    Column {
        id: generalColumn
        anchors.top: parent.top
        anchors.topMargin: topMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.right: parent.right
        anchors.rightMargin: contentMargin

        StatusSettingsLineButton {
            //% "Network"
            text: qsTrId("network")
            currentValue: utilsModel.getNetworkName()
            onClicked: networksModal.open()
        }

        StatusSettingsLineButton {
            //% "Fleet"
            text: qsTrId("fleet")
            currentValue: profileModel.fleets.fleet
            onClicked: fleetModal.open()
        }

        Item {
            id: spacer1
            height: Style.current.bigPadding
            width: parent.width
        }

        Separator {
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }

        StatusSectionHeadline {
            //% "Experimental features"
            text: qsTrId("experimental-features")
            topPadding: Style.current.bigPadding
            bottomPadding: Style.current.padding
        }

        StatusSettingsLineButton {
            //% "Wallet"
            text: qsTrId("wallet")
            isSwitch: true
            switchChecked: appSettings.walletEnabled
            onClicked: function (checked) {
                appSettings.walletEnabled = checked
            }
        }

        StatusSettingsLineButton {
            //% "Dapp Browser"
            text: qsTrId("dapp-browser")
            isSwitch: true
            switchChecked: appSettings.browserEnabled
            onClicked: function (checked) {
                appSettings.browserEnabled = checked
            }
        }

        StatusSettingsLineButton {
            //% "Communities"
            text: qsTrId("communities")
            isSwitch: true
            switchChecked: appSettings.communitiesEnabled
            onClicked: function (checked) {
                appSettings.communitiesEnabled = checked
            }
        }

        StatusSettingsLineButton {
            //% "Node Management"
            text: qsTrId("node-management")
            isSwitch: true
            switchChecked: appSettings.nodeManagementEnabled
            onClicked: function (checked) {
                appSettings.nodeManagementEnabled = checked
            }
        }
    }

    NetworksModal {
        id: networksModal
    }

    FleetsModal {
        id: fleetModal
    }


}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
