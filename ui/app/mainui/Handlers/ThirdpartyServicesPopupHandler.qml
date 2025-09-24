import QtQuick

import shared.popups

QtObject {
    id: root

    required property var popupParent
    required property bool thirdPartyServicesEnabled

    signal toggleThirdpartyServicesEnabledRequested()
    signal openDiscussPageRequested()
    signal openThirdpartyServicesArticleRequested()

    function openPopup()
    {
        let thirdpartyServicesPopupInst = thirdpartyServicesPopup.createObject(popupParent)
        thirdpartyServicesPopupInst.open()
    }

    readonly property Component thirdpartyServicesPopup: Component {
        ThirdpartyServicesPopup {
            thirdPartyServicesEnabled: root.thirdPartyServicesEnabled

            onToggleThirdpartyServicesEnabledRequested: root.toggleThirdpartyServicesEnabledRequested()
            onOpenDiscussPageRequested: root.openDiscussPageRequested()
            onOpenThirdpartyServicesArticleRequested: root.openThirdpartyServicesArticleRequested()
        }
    }
}
