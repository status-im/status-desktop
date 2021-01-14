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
        spacing: Style.current.bigPadding
        anchors.top: parent.top
        anchors.topMargin: 46
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.right: parent.right
        anchors.rightMargin: contentMargin

        StatusSectionMenuItem {
            label: qsTr("Network")
            info: utilsModel.getNetworkName()
            onClicked: networksModal.open()
        }

        StatusSectionMenuItem {
            label: qsTr("Fleet")
            info: profileModel.fleets.fleet
            onClicked: fleetModal.open()
        }

        Separator {}

        StatusSectionHeadline {
            text: qsTr("Experimental features")
        }

        StatusSettingsLineButton {
            text: qsTr("Wallet")
            isSwitch: true
            switchChecked: appSettings.walletEnabled
            onClicked: function (checked) {
                appSettings.walletEnabled = checked
            }
        }

        StatusSettingsLineButton {
            text: qsTr("Dapp Browser")
            isSwitch: true
            switchChecked: appSettings.browserEnabled
            onClicked: function (checked) {
                appSettings.browserEnabled = checked
            }
        }

        StatusSettingsLineButton {
            text: qsTr("Communities")
            isSwitch: true
            switchChecked: appSettings.communitiesEnabled
            onClicked: function (checked) {
                appSettings.communitiesEnabled = checked
            }
        }

        StatusSettingsLineButton {
            text: qsTr("Node Management")
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
