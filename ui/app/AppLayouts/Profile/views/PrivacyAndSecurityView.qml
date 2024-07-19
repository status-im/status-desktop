import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Profile.stores 1.0

import "../popups"

import SortFilterProxyModel 0.2

SettingsContentBase {
    id: root

    required property bool isCentralizedMetricsEnabled

    function refreshSwitch() {
        enableMetricsSwitch.checked = Qt.binding(function() { return root.isCentralizedMetricsEnabled })
    }

    ColumnLayout {
        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Share usage data with Status")
            subTitle: qsTr("From all profiles on device")
            components: [
                StatusSwitch {
                    id: enableMetricsSwitch
                    checked: root.isCentralizedMetricsEnabled
                    onClicked: {
                        Global.openMetricsEnablePopupRequested(false, popup => popup.toggleMetrics.connect(refreshSwitch))
                    }
                }
            ]
            onClicked: {
                Global.openMetricsEnablePopupRequested(false, popup => popup.toggleMetrics.connect(refreshSwitch))
            }
        }
    }
}
