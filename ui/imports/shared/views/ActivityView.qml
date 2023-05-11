import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.stores 1.0

import SortFilterProxyModel 0.2

import utils 1.0

import "../panels"
import "../popups"
import "../stores"
import "../controls"

// Temporary developer view to test the filter APIs
Control {
    id: root

    property var controller: null
    property var networksModel: null
    property var assetsModel: null
    property bool assetsLoading: true

    // Mirrors src/backend/activity.nim ActivityType
    enum ActivityType {
        Send,
        Receive,
        Buy,
        Swap,
        Bridge
    }

    // Mirrors src/backend/activity.nim ActivityStatus
    enum ActivityStatus {
        Failed,
        Pending,
        Complete,
        Finalized
    }

    background: Rectangle {
        anchors.fill: parent
        color: "white"
    }

    QtObject {
        id: d

        readonly property int millisInADay: 24 * 60 * 60 * 1000
        property int start: fromSlider.value > 0
            ? Math.floor(new Date(new Date() - (fromSlider.value * millisInADay)).getTime() / 1000)
            : 0
        property int end: toSlider.value > 0
            ? Math.floor(new Date(new Date() - (toSlider.value * millisInADay)).getTime() / 1000)
            : 0

        function updateFilter() {
            // Time
            controller.setFilterTime(d.start, d.end)

            // Activity types
            var types = []
            for(var i = 0; i < typeModel.count; i++) {
                let item = typeModel.get(i)
                if(item.checked) {
                    types.push(i)
                }
            }
            controller.setFilterType(JSON.stringify(types))

            // Activity status
            var statuses = []
            for(var i = 0; i < statusModel.count; i++) {
                let item = statusModel.get(i)
                if(item.checked) {
                    statuses.push(i)
                }
            }
            controller.setFilterStatus(JSON.stringify(statuses))

            // Counterparty addresses
            var addresses = toAddressesInput.text.split(',')
            if(addresses.length == 1 && addresses[0].trim() == "") {
                addresses = []
            } else {
                for (var i = 0; i < addresses.length; i++) {
                    addresses[i] = padHexAddress(addresses[i].trim());
                }
            }
            controller.setFilterToAddresses(JSON.stringify(addresses))

            // Involved addresses
            var addresses = addressesInput.text.split(',')
            if(addresses.length == 1 && addresses[0].trim() == "") {
                addresses = []
            } else {
                for (var i = 0; i < addresses.length; i++) {
                    addresses[i] = padHexAddress(addresses[i].trim());
                }
            }
            controller.setFilterAddresses(JSON.stringify(addresses))

            // Chains
            var chains = []
            for(var i = 0; i < clonedNetworksModel.count; i++) {
                let item = clonedNetworksModel.get(i)
                if(item.checked) {
                    chains.push(parseInt(item.chainId))
                }
            }
            controller.setFilterChains(JSON.stringify(chains))

            // Assets
            var assets = []
            if(assetsLoader.status == Loader.Ready) {
                for(var i = 0; i < assetsLoader.item.count; i++) {
                    let item = assetsLoader.item.get(i)
                    if(item.checked) {
                        assets.push(item.symbol)
                    }
                }
            }
            controller.setFilterAssets(JSON.stringify(assets))

            // Update the model
            controller.updateFilter()
        }

        function padHexAddress(input) {
            var addressLength = 40;
            var strippedInput = input.startsWith("0x") ? input.slice(2) : input;

            if (strippedInput.length > addressLength) {
                console.error("Input is longer than expected address");
                return null;
            }

            var paddingLength = addressLength - strippedInput.length;
            var padding = Array(paddingLength + 1).join("0");

            return "0x" + padding + strippedInput;
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ColumnLayout {
            id: filterLayout

            ColumnLayout {
                id: timeFilterLayout

                RowLayout {
                    Label { text: "Past Days Span: 100" }
                    Slider {
                        id: fromSlider

                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50

                        from: 100
                        to: 0

                        stepSize: 1
                        value: 0
                    }
                    Label { text: `${fromSlider.value}d - ${toSlider.value}d` }
                    Slider {
                        id: toSlider

                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50

                        enabled: fromSlider.value > 1

                        from: fromSlider.value - 1
                        to: 0

                        stepSize: 1
                        value: 0
                    }
                    Label { text: "0" }
                }
                Label { text: `Interval: ${d.start > 0 ? root.epochToDateStr(d.start) : "all time"} - ${d.end > 0 ? root.epochToDateStr(d.end) : "now"}` }
            }
            RowLayout {
                Label { text: "Type" }
                // Models the ActivityType
                ListModel {
                    id: typeModel

                    ListElement { text: qsTr("Send"); checked: false }
                    ListElement { text: qsTr("Receive"); checked: false }
                    ListElement { text: qsTr("Buy"); checked: false }
                    ListElement { text: qsTr("Swap"); checked: false }
                    ListElement { text: qsTr("Bridge"); checked: false }
                }

                ComboBox {
                    model: typeModel

                    displayText: qsTr("Select types")

                    currentIndex: -1
                    textRole: "text"

                    delegate: ItemOnOffDelegate {}
                }

                Label { text: "Status" }
                // ActivityStatus
                ListModel {
                    id: statusModel
                    ListElement { text: qsTr("Failed"); checked: false }
                    ListElement { text: qsTr("Pending"); checked: false }
                    ListElement { text: qsTr("Complete"); checked: false }
                    ListElement { text: qsTr("Finalized"); checked: false }
                }

                ComboBox {
                    displayText: qsTr("Select statuses")

                    model: statusModel

                    currentIndex: -1
                    textRole: "text"

                    delegate: ItemOnOffDelegate {}
                }

                Label { text: "To addresses" }
                TextField {
                    id: toAddressesInput

                    Layout.fillWidth: true

                    placeholderText: qsTr("0x1234, 0x5678, ...")
                }

                Button {
                    text: qsTr("Update")
                    onClicked: d.updateFilter()
                }
            }
            RowLayout {

                Label { text: "Addresses" }
                TextField {
                    id: addressesInput

                    Layout.fillWidth: true

                    placeholderText: qsTr("0x1234, 0x5678, ...")
                }

                Label { text: "Chains" }
                ComboBox {
                    displayText: qsTr("Select chains")

                    Layout.preferredWidth: 300

                    model: clonedNetworksModel
                    currentIndex: -1

                    delegate: ItemOnOffDelegate {}
                }

                Label { text: "Assets" }
                ComboBox {
                    displayText: assetsLoader.status != Loader.Ready ? qsTr("Loading...") : qsTr("Select an asset")

                    enabled: assetsLoader.status == Loader.Ready

                    Layout.preferredWidth: 300

                    model: assetsLoader.item

                    currentIndex: -1

                    delegate: ItemOnOffDelegate {}
                }
            }

            CloneModel {
                id: clonedNetworksModel

                sourceModel: root.networksModel
                roles: ["layer", "chainId", "chainName"]
                rolesOverride: [{ role: "text", transform: (md) => `${md.chainName} [${md.chainId}] ${md.layer}` },
                                { role: "checked", transform: (md) => false }]
            }

            // Found out the hard way that the assets are not loaded immediately after root.assetLoading is enabled so there is no data set yet
            Timer {
                id: delayAssetLoading

                property bool loadingEnabled: false

                interval: 1000; repeat: false
                running: !root.assetsLoading
                onTriggered: loadingEnabled = true
            }

            Loader {
                id: assetsLoader

                sourceComponent: CloneModel {
                    sourceModel: root.assetsModel
                    roles: ["name", "symbol", "address"]
                    rolesOverride: [{ role: "text", transform: (md) => `[${md.symbol}] ${md.name}`},
                                    { role: "checked", transform: (md) => false }]
                }
                active: delayAssetLoading.loadingEnabled
            }

            component ItemOnOffDelegate: Item {
                width: parent ? parent.width : 0
                height: itemLayout.implicitHeight

                readonly property var entry: model

                RowLayout {
                    id: itemLayout
                    anchors.fill: parent

                    CheckBox { checked: entry.checked; onCheckedChanged: entry.checked = checked }
                    Label { text: entry.text }
                    RowLayout {}
                }
            }
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: controller.model

            delegate: Item {
                width: parent ? parent.width : 0
                height: itemLayout.implicitHeight

                readonly property var entry: model.activityEntry

                RowLayout {
                    id: itemLayout
                    anchors.fill: parent

                    Label { text: entry.isMultiTransaction ? "MT" : entry.isPendingTransaction ? "PT" : " T" }
                    Label { text: `[${root.epochToDateStr(entry.timestamp)}] ` }
                    Label { text: entry.isMultiTransaction ? entry.fromAmount : entry.amount }
                    Label { text: "from"; Layout.leftMargin: 5; Layout.rightMargin: 5 }
                    Label { text: entry.sender; Layout.maximumWidth: 200; elide: Text.ElideMiddle }
                    Label { text: "to"; Layout.leftMargin: 5; Layout.rightMargin: 5 }
                    Label { text: entry.recipient; Layout.maximumWidth: 200; elide: Text.ElideMiddle }
                    Label { text: "got"; Layout.leftMargin: 5; Layout.rightMargin: 5; visible: entry.isMultiTransaction }
                    Label { text: entry.toAmount; Layout.leftMargin: 5; Layout.rightMargin: 5; visible: entry.isMultiTransaction }
                    RowLayout {}    // Spacer
                }
            }
        }
    }

    function epochToDateStr(epochTimestamp) {
        var date = new Date(epochTimestamp * 1000);
        return date.toLocaleString(Qt.locale(), "dd-MM-yyyy hh:mm");
    }
}
