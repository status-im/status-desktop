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

    required property MetricsStore metricsStore

    Component.onCompleted: {
        enableMetricsSwitch.checked = metricsStore.isCentralizedMetricsEnabled()
    }

    function enableMetrics(enable) {
        enableMetricsSwitch.checked = enable
        metricsStore.toggleCentralizedMetrics(enable)
    }

    ColumnLayout {
        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Share usage data with Status")
            components: [
                StatusSwitch {
                    id: enableMetricsSwitch
                    onClicked: {
                        Global.openPopup(metricsEnabledPopupComponent)
                    }
                }
            ]
            onClicked: {
                Global.openPopup(metricsEnabledPopupComponent)
            }
        }

        Component {
            id: metricsEnabledPopupComponent
            MetricsEnablePopup {
                onAccepted: root.enableMetrics(true)
                onRejected: root.enableMetrics(false)
            }
        }
    }
}
