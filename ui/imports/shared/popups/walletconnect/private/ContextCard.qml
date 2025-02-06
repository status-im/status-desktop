import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.controls 1.0
import shared.controls 1.0

Rectangle {
    id: root

    property string selectedAccountAddress: ""
    property bool connectionAttempted: false
    property var accountsModel
    property var chainsModel
    property alias chainSelection: networkFilter.selection
    property bool multipleChainSelection: true

    readonly property alias selectedAccount: accountsDropdown.currentAccount


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

            AccountSelector {
                id: accountsDropdown

                Layout.preferredWidth: 204
                Layout.preferredHeight: 38
                control.horizontalPadding: 12
                control.verticalPadding: 4
                control.enabled: !root.connectionAttempted && count > 1
                model: root.accountsModel
                indicator.visible: control.enabled
                selectedAddress: root.selectedAccountAddress
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.border.color
        }

        RowLayout {
            Layout.margins: 15

            StatusBaseText {
                text: qsTr("On")

                Layout.fillWidth: true
            }

            NetworkFilter {
                id: networkFilter
                objectName: "networkFilter"
                Layout.preferredWidth: accountsDropdown.Layout.preferredWidth

                flatNetworks: root.chainsModel
                showTitle: true
                multiSelection: root.multipleChainSelection
                selectionAllowed: false

                // disable interactions w/o looking disabled
                control.hoverEnabled: false
                MouseArea {
                    anchors.fill: parent
                    onPressed: mouse.accepted = true
                }
            }
        }
    }
}
