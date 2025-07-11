import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils

import StatusQ.Components
import StatusQ.Controls

SettingsContentBase {
    id: root

    property bool isStatusNewsViaRSSEnabled
    required property bool isCentralizedMetricsEnabled

    signal setNewsRSSEnabledRequested(bool isStatusNewsViaRSSEnabled)

    function refreshSwitch() {
        enableMetricsSwitch.checked = Qt.binding(function() { return root.isCentralizedMetricsEnabled })
    }

    titleRowComponentLoader.sourceComponent: StatusButton {
        text: qsTr("Privacy policy")
        onClicked: Global.privacyPolicyRequested()
    }

    ColumnLayout {
        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Receive Status News via RSS")
            subTitle: qsTr("Your IP address will be exposed to https://status.app")
            components: [
                StatusSwitch {
                    id: statusNewsSwitch
                    checked: root.isStatusNewsViaRSSEnabled
                    onToggled: root.setNewsRSSEnabledRequested(statusNewsSwitch.checked)
                }
            ]
            onClicked: root.setNewsRSSEnabledRequested(!statusNewsSwitch.checked)
        }
        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Share usage data with Status")
            subTitle: qsTr("From all profiles on device")
            components: [
                StatusSwitch {
                    id: enableMetricsSwitch
                    checked: root.isCentralizedMetricsEnabled
                    onToggled: {
                        Global.openMetricsEnablePopupRequested(Constants.metricsEnablePlacement.privacyAndSecurity, null)
                        refreshSwitch()
                    }
                }
            ]
            onClicked: {
                Global.openMetricsEnablePopupRequested(Constants.metricsEnablePlacement.privacyAndSecurity, null)
                refreshSwitch()
            }
        }
    }
}
