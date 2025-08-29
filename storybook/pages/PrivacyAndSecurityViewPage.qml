import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Profile.views

import Storybook

import utils

SplitView {

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        PrivacyAndSecurityView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            isStatusNewsViaRSSEnabled: true
            isCentralizedMetricsEnabled: true
            thirdpartyServicesEnabled: ctrlThirdpartyServicesEnabled.checked
            privacyModeFeatureEnabled: ctrlPrivacyMode.checked
            onOpenThirdpartyServicesInfoPopupRequested: {
                console.warn("onLaunchThirdyPartyServicesInfoPopupRequested")
                ctrlThirdpartyServicesEnabled.checked = !ctrlThirdpartyServicesEnabled.checked
            }
            onOpenDiscussPageRequested: console.warn("onOpenDiscussPageRequested")
        }
    }

    ColumnLayout {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Switch {
            id: ctrlPrivacyMode
            text: "Privacy Mode Feature Enabled"
            checked: true
        }

        Switch {
            id: ctrlThirdpartyServicesEnabled
            text: "Third Party Services Enabled"
            checked: true
        }
    }
}

// category: Views
// status: good
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=25914-21065&m=dev
