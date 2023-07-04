import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    id: root
    Logs { id: logs }

    ListModel {
        id: emptyModel
    }

    Component {
        id: dlgComponent
        SharedAddressesPopup {
            //anchors.centerIn: parent
            isEditMode: ctrlEditMode.checked
            communityName: "Decentraland"
            communityIcon: ModelsData.assets.uni
            loginType: ctrlLoginType.currentIndex
            walletAccountsModel: WalletAccountsModel {}
            permissionsModel: {
                if (ctrlPermissions.checked && ctrlTokenGatedChannels.checked)
                    return PermissionsModel.complexPermissionsModel
                if (ctrlPermissions.checked)
                    return PermissionsModel.permissionsModel
                if (ctrlTokenGatedChannels.checked)
                    return PermissionsModel.channelsOnlyPermissionsModel

                return emptyModel
            }

            assetsModel: AssetsModel {}
            collectiblesModel: CollectiblesModel {}
            visible: true

            onShareSelectedAddressesClicked: logs.logEvent("::shareSelectedAddressesClicked", ["airdropAddress", "sharedAddresses"], arguments)
            onClosed: destroy()
        }
    }

    property var dialog

    function createAndOpenDialog() {
        dialog = dlgComponent.createObject(root)
        dialog.open()
    }

    Component.onCompleted: createAndOpenDialog()

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Pane {
            id: pane

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: createAndOpenDialog()
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent

            Switch {
                id: ctrlPermissions
                text: "With permissions"
                checked: true
            }

            Switch {
                id: ctrlTokenGatedChannels
                text: "With token gated channels"
                checked: true
            }

            Switch {
                id: ctrlEditMode
                text: "Edit mode"
            }

            ColumnLayout {
                visible: ctrlEditMode.checked
                Label {
                    Layout.fillWidth: true
                    text: "Login type"
                }

                ComboBox {
                    id: ctrlLoginType
                    Layout.fillWidth: true
                    model: ["Password","Biometrics","Keycard"]
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "lightgray"
            }

            Text {
                text: "Info"
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: "Shared addresses: %1".arg(!!dialog ? dialog.selectedSharedAddresses.join(";") : "")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Text {
                Layout.fillWidth: true
                text: "Airdrop address: %1".arg(!!dialog ? dialog.selectedAirdropAddress : "")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
