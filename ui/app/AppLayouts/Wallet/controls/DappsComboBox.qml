import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0
import shared.controls 1.0
import shared.popups.walletconnect 1.0
import shared.popups.walletconnect.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components.private 0.1 as SQP

ComboBox {
    id: root
    
    property bool walletConnectEnabled: true
    property bool connectorEnabled: true

    signal dappsListReady
    signal pairDapp
    signal disconnectDapp(string dappUrl)

    implicitHeight: 38
    implicitWidth: 38

    background: SQP.StatusComboboxBackground {
        objectName: "dappsBackground"
        active: root.down || root.hovered
        Binding on color {
            when: !root.enabled
            value: Theme.palette.baseColor2
        }
    }

    indicator: null

    contentItem: Item {
        objectName: "dappsContentItem"
        StatusBadge {
            objectName: "dappBadge"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 5
            width: 6
            height: 6
            visible: root.delegateModel.count > 0
        }

        StatusIcon {
            objectName: "dappIcon"
            anchors.centerIn: parent
            width: 16
            height: 16
            icon: "dapp"
            color: Theme.palette.baseColor1
        }
    }

    delegate: DAppDelegate {
        width: ListView.view.width

        onDisconnectDapp: (dappUrl) => {
            root.disconnectDapp(dappUrl)
        }
    }

    popup: DAppsListPopup {
        objectName: "dappsListPopup"

        x: root.width - width
        y: root.height + 4

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        delegateModel: root.delegateModel

        onConnectDapp: {
            dappConnectSelectComponent.createObject(root).open()
            this.close()
        }

        onOpened: {
            root.dappsListReady()
        }
    }

    Component {
        id: dappConnectSelectComponent
        StatusDialog {
            id: dappConnectSelect
            objectName: "dappConnectSelect"
            width: 480
            topPadding: Theme.bigPadding
            leftPadding: Theme.padding
            rightPadding: Theme.padding
            bottomPadding: 4
            destroyOnClose: true

            title: qsTr("Connect a dApp")
            footer: StatusDialogFooter {
                rightButtons: ObjectModel {
                    StatusButton {
                        text: qsTr("Cancel")
                        onClicked: dappConnectSelect.close()
                    }
                }
            }

            contentItem: ColumnLayout {
                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.padding
                    color: Theme.palette.baseColor1
                    text: qsTr("How would you like to connect?")
                }
                StatusListItem {
                    objectName: "btnStatusConnector"
                    title: "Status Connector"
                    asset.name: Theme.png("status-logo")
                    asset.isImage: true
                    enabled: root.connectorEnabled
                    components: [
                        StatusIcon {
                            icon: "external-link"
                            color: Theme.palette.baseColor1
                        }
                    ]
                    onClicked: {
                        dappConnectSelect.close()
                        Global.openLink("https://chromewebstore.google.com/detail/a-wallet-connector-by-sta/kahehnbpamjplefhpkhafinaodkkenpg")
                    }
                }
                StatusListItem {
                    objectName: "btnWalletConnect"
                    title: "Wallet Connect"
                    asset.name: Theme.svg("walletconnect")
                    asset.isImage: true
                    enabled: root.walletConnectEnabled
                    components: [
                        StatusIcon {
                            icon: "next"
                            color: Theme.palette.baseColor1
                        }
                    ]
                    onClicked: {
                        dappConnectSelect.close()
                        root.pairDapp()
                    }
                }
            }
        }
    }

    StatusToolTip {
        id: tooltip
        objectName: "dappTooltip"
        visible: root.hovered && !root.down
        text: qsTr("dApp connections")
        orientation: StatusToolTip.Orientation.Bottom
        y: root.height + 14
    }
}
