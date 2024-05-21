import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.14
import SortFilterProxyModel 0.2

import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

// TODO extract the components to StatusQ
import shared.popups.send.controls 1.0

import AppLayouts.Wallet.controls 1.0

import utils 1.0

StatusDialog {
    id: root

    width: 480
    implicitHeight: d.connectionStatus === root.notConnectedStatus ? 633 : 681

    required property var accounts
    required property var flatNetworks

    readonly property alias selectedAccount: d.selectedAccount

    readonly property int notConnectedStatus: 0
    readonly property int connectionSuccessfulStatus: 1
    readonly property int connectionFailedStatus: 2

    function openWithFilter(dappChains, proposer) {
        d.connectionStatus = root.notConnectedStatus
        d.afterTwoSecondsFromStatus = false

        let m = proposer.metadata
        dappCard.name = m.name
        dappCard.url = m.url
        if(m.icons.length > 0) {
            dappCard.iconUrl = m.icons[0]
        } else {
            dappCard.iconUrl = ""
        }

        d.dappChains.clear()
        for (let i = 0; i < dappChains.length; i++) {
            // Convert to int
            d.dappChains.append({ chainId: parseInt(dappChains[i]) })
        }

        root.open()
    }

    function pairSuccessful(session) {
        d.connectionStatus = root.connectionSuccessfulStatus
        closeAndRetryTimer.start()
    }
    function pairFailed(session, err) {
        d.connectionStatus = root.connectionFailedStatus
        closeAndRetryTimer.start()
    }

    Timer {
        id: closeAndRetryTimer

        interval: 2000
        running: false
        repeat: false

        onTriggered: {
            d.afterTwoSecondsFromStatus = true
        }
    }

    signal connect()
    signal decline()
    signal disconnect()

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    title: qsTr("Connection request")

    padding: 20

    contentItem: ColumnLayout {
        spacing: 20
        clip: true

        DAppCard {
            id: dappCard

            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 12
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 20
            Layout.bottomMargin: Layout.topMargin
        }

        ContextCard {
            Layout.fillWidth: true
        }

        PermissionsCard {
            Layout.fillWidth: true

            Layout.leftMargin: 12
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 20
            Layout.bottomMargin: Layout.topMargin
        }
    }

    footer: StatusDialogFooter {
        id: footer
        rightButtons: ObjectModel {
            StatusButton {
                height: 44
                text: qsTr("Decline")

                visible: d.connectionStatus === root.notConnectedStatus

                onClicked: root.decline()
            }
            StatusButton {
                height: 44
                text: qsTr("Disconnect")

                visible: d.connectionStatus === root.connectionSuccessfulStatus

                type: StatusBaseButton.Type.Danger

                onClicked: root.disconnect()
            }
            StatusButton {
                height: 44
                text: d.connectionStatus === root.notConnectedStatus
                            ? qsTr("Connect")
                            : qsTr("Close")

                onClicked: {
                    if (d.connectionStatus === root.notConnectedStatus)
                        root.connect()
                    else
                        root.close()
                }
            }
        }
    }

    component ContextCard: Rectangle {
        id: contextCard

        implicitWidth: contextLayout.implicitWidth
        implicitHeight: contextLayout.implicitHeight

        radius: 8
        // TODO: the color matched the design color (grey4); It is also matching the intention or we should add some another color to the theme? (e.g. sectionBorder)?
        border.color: Theme.palette.baseColor2
        border.width: 1
        color: "transparent"

        ColumnLayout {
            id: contextLayout

            anchors.fill: parent

            RowLayout {
                Layout.margins: 16

                StatusBaseText {
                    text: qsTr("Connect with")

                    Layout.fillWidth: true
                }

                // TODO: have a reusable component for this
                AccountsModalHeader {
                    id: accountsDropdown

                    Layout.preferredWidth: 204

                    control.enabled: d.connectionStatus === root.notConnectedStatus && count > 1
                    model: d.accountsProxy

                    onCountChanged: {
                        if (count > 0) {
                            selectedAccount = d.accountsProxy.get(0)
                        }
                    }

                    selectedAccount: d.accountsProxy.get(0)
                    onSelectedAccountChanged: d.selectedAccount = selectedAccount
                    onSelectedIndexChanged: {
                        d.selectedAccount = model.get(selectedIndex)
                        selectedAccount = d.selectedAccount
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: contextCard.border.color
            }

            RowLayout {
                Layout.margins: 16

                StatusBaseText {
                    text: qsTr("On")

                    Layout.fillWidth: true
                }

                // TODO: replace with a specialized network selection control
                NetworkFilter {
                    Layout.preferredWidth: accountsDropdown.Layout.preferredWidth

                    flatNetworks: d.filteredChains
                    showAllSelectedText: false
                    showCheckboxes: false
                    enabled: d.connectionStatus === root.notConnectedStatus
                }
            }
        }
    }

    component DAppCard: ColumnLayout {
        property alias name: appNameText.text
        property alias url: appUrlText.text
        property string iconUrl: ""

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 72
            Layout.preferredHeight: Layout.preferredWidth

            radius: width / 2
            color: Theme.palette.primaryColor3

            StatusRoundedImage {
                id: iconDisplay

                anchors.fill: parent

                visible: !fallbackImage.visible

                image.source: iconUrl
            }

            StatusIcon {
                id: fallbackImage

                anchors.centerIn: parent

                width: 40
                height: 40

                icon: "dapp"
                color: Theme.palette.primaryColor1

                visible: iconDisplay.image.isLoading || iconDisplay.image.isError || !iconUrl
            }
        }

        StatusBaseText {
            id: appNameText

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4

            font.bold: true
            font.pixelSize: 17
        }

        // TODO replace with the proper URL control
        StatusLinkText {
            id: appUrlText

            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
        }

        Rectangle {
            Layout.preferredWidth: pairingStatusLayout.implicitWidth + 32
            Layout.preferredHeight: pairingStatusLayout.implicitHeight + 14

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16

            visible: d.connectionStatus !== root.notConnectedStatus

            color: d.connectionStatus === root.connectionSuccessfulStatus
                        ? d.afterTwoSecondsFromStatus
                            ? Theme.palette.successColor2
                            : Theme.palette.successColor3
                        : d.afterTwoSecondsFromStatus
                            ? "transparent"
                            : Theme.palette.dangerColor3
            border.color: d.connectionStatus === root.connectionSuccessfulStatus
                                ? Theme.palette.successColor2
                                : Theme.palette.dangerColor2
            border.width: 1
            radius: height / 2

            RowLayout {
                id: pairingStatusLayout

                anchors.centerIn: parent

                spacing: 8

                Rectangle {
                    width: 6
                    height: 6
                    radius: width / 2

                    visible: d.connectionStatus === root.connectionSuccessfulStatus
                    color: Theme.palette.successColor1
                }

                StatusIcon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16

                    visible: d.connectionStatus !== root.connectionSuccessfulStatus

                    color: Theme.palette.dangerColor1
                    icon: "warning"
                }

                StatusBaseText {
                    text: {
                        if (d.connectionStatus === root.connectionSuccessfulStatus)
                            return qsTr("Connected. You can now go back to the dApp.")
                        else if (d.connectionStatus === root.connectionFailedStatus)
                            return qsTr("Error connecting to dApp. Close and try again")
                        return ""
                    }

                    font.pixelSize: 12
                    color: d.connectionStatus === root.connectionSuccessfulStatus ? Theme.palette.directColor1 : Theme.palette.dangerColor1
                }
            }
        }
    }

    component PermissionsCard: ColumnLayout {
        spacing: 8

        StatusBaseText {
            text: qsTr("Uniswap Interface will be able to:")

            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            text: qsTr("Check your account balance and activity")

            font.pixelSize: 13
        }

        StatusBaseText {
            text: qsTr("Request transactions and message signing")

            font.pixelSize: 13
        }
    }

    QtObject {
        id: d

        property SortFilterProxyModel accountsProxy: SortFilterProxyModel {
            sourceModel: root.accounts

            sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
        }

        property var selectedAccount: accountsProxy.count > 0 ? accountsProxy.get(0) : null

        readonly property var filteredChains: LeftJoinModel {
            leftModel: d.dappChains
            rightModel: root.flatNetworks

            joinRole: "chainId"
        }

        readonly property var dappChains: ListModel {}

        property int connectionStatus: notConnectedStatus
        property bool afterTwoSecondsFromStatus: false
    }
}
