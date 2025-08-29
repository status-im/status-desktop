import QtQuick
import QtQuick.Controls

import AppLayouts.Market

SplitView {
    id: root

    MarketPrivacyWall {
        onOpenThirdpartyServicesInfoPopupRequested: console.warn("Enable third party services requested")
        onOpenDiscussPageRequested: console.warn("Open discuss page requested")
        onNotificationButtonClicked: console.warn("Open notification center requested")
    }
}

// category: Layouts
// status: good
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=26157-27066&m=dev
