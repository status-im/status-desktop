import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

SettingsContentBase {
    id: root

    property alias isStatusNewsViaRSSEnabled: statusNewsSwitch.checked
    required property bool isCentralizedMetricsEnabled

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
                }
            ]
            onClicked: statusNewsSwitch.checked = !statusNewsSwitch.checked
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
