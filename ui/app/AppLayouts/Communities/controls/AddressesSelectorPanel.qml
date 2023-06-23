import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2


Control {
    id: root

    property alias model: addressesInputList.model
    property alias text: addressesInputList.text

    property bool loading: false

    signal addAddressesRequested(string addresses)
    signal removeAddressRequested(int index)

    readonly property alias count: addressesInputList.count
    readonly property alias validAddressesCount: validAddressesModel.count
    readonly property int invalidAddressesCount: addressesInputList.count
                                                 - validAddressesCount

    function forceInputFocus() {
        addressesInputList.forceInputFocus()
    }

    function clearInput() {
        addressesInputList.clearInput()
    }

    function positionListAtEnd() {
        addressesInputList.positionListAtEnd()
    }

    contentItem: Column {
        spacing: 8

        RowLayout {
            width: root.availableWidth
            spacing: 0

            StatusBaseText {
                color: Theme.palette.baseColor1
                text: qsTr("ETH addresses")
                font.pixelSize: Theme.tertiaryTextFontSize
                elide: Text.ElideRight
            }

            Item { Layout.fillWidth: true }

            StatusBaseText {
                visible: !root.loading && root.validAddressesCount > 0
                color: Theme.palette.baseColor1
                text: qsTr("%n valid address(s)", "", root.validAddressesCount)
                      + (root.invalidAddressesCount > 0 ? " / " : "")
                font.pixelSize: Theme.tertiaryTextFontSize
            }

            StatusBaseText {
                visible: !root.loading && root.invalidAddressesCount > 0
                color: Theme.palette.dangerColor1
                text: root.validAddressesCount > 0
                      ? qsTr("%n invalid",
                             "invalid addresses, where \"addresses\" is implicit",
                             root.invalidAddressesCount)
                      : qsTr("%n invalid address(s)", "", root.invalidAddressesCount)
                font.pixelSize: Theme.tertiaryTextFontSize
            }

            StatusLoadingIndicator {
                visible: root.loading

                Layout.preferredWidth: 10
                Layout.preferredHeight: 10
                Layout.rightMargin: 2
            }
        }

        SortFilterProxyModel {
            id: validAddressesModel

            sourceModel: root.model ?? null

            filters: ValueFilter {
                roleName: "valid"
                value: true
            }
        }

        AddressesInputList {
            id: addressesInputList

            enabled: !root.loading
            width: root.availableWidth

            Component.onCompleted: {
                addAddressesRequested.connect(root.addAddressesRequested)
                removeAddressRequested.connect(root.removeAddressRequested)
            }
        }
    }
}
