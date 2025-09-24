import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils

import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

import shared.controls

SettingsContentBase {
    id: root

    property bool isStatusNewsViaRSSEnabled
    required property bool isCentralizedMetricsEnabled
    required property bool thirdpartyServicesEnabled
    required property bool privacyModeFeatureEnabled

    signal setNewsRSSEnabledRequested(bool isStatusNewsViaRSSEnabled)
    signal openThirdpartyServicesInfoPopupRequested()
    signal openDiscussPageRequested()

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
            enabled: root.thirdpartyServicesEnabled
        }

        // Divider
        Rectangle {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: 1
            color: Theme.palette.baseColor2
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Third-party services")
            subTitle: qsTr("Enable/disable all third-party services")
            components: [
                StatusSwitch {
                    checkable: false
                    checked: root.thirdpartyServicesEnabled
                    onClicked: root.openThirdpartyServicesInfoPopupRequested()
                }
            ]
            onClicked: root.openThirdpartyServicesInfoPopupRequested()
            visible: root.privacyModeFeatureEnabled
        }

        InformationTag {
            id: infoTag

            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter

            leftInset: Theme.padding
            rightInset: Theme.padding
            leftPadding: horizontalPadding + Theme.padding
            rightPadding: horizontalPadding + Theme.padding

            backgroundColor: Theme.palette.primaryColor3
            bgBorderColor: Theme.palette.primaryColor2
            bgRadius: 12
            asset.name: "info"
            tagPrimaryLabel.wrapMode: Text.WordWrap
            tagPrimaryLabel.textFormat: Text.RichText
            tagPrimaryLabel.font.pixelSize: Theme.additionalTextSize
            tagPrimaryLabel.text: qsTr("Share feedback or suggest improvements on our %1.")
            .arg(Utils.getStyledLink("Discuss page", "#", tagPrimaryLabel.hoveredLink, Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))
            tagPrimaryLabel.onLinkActivated: root.openDiscussPageRequested()
            visible: root.privacyModeFeatureEnabled
        }

        // Divider
        Rectangle {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: 1
            color: Theme.palette.baseColor2
            visible: root.privacyModeFeatureEnabled
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
            enabled: root.thirdpartyServicesEnabled
        }

        // Divider
        Rectangle {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: 1
            color: Theme.palette.baseColor2
        }
    }
}
