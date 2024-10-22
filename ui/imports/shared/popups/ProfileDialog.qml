import QtQuick 2.14
import QtQuick.Controls 2.15

import StatusQ.Popups.Dialog 0.1

import shared.views 1.0
import shared.controls 1.0

StatusDialog {
    id: root

    property var parentPopup

    property alias publicKey: profileView.publicKey

    property alias profileStore: profileView.profileStore
    property alias contactsStore: profileView.contactsStore
    property alias utilsStore: profileView.utilsStore

    property alias sendToAccountEnabled: profileView.sendToAccountEnabled

    property alias showcaseCommunitiesModel: profileView.showcaseCommunitiesModel
    property alias showcaseAccountsModel: profileView.showcaseAccountsModel
    property alias showcaseCollectiblesModel: profileView.showcaseCollectiblesModel
    property alias showcaseSocialLinksModel: profileView.showcaseSocialLinksModel
    property alias showcaseAssetsModel: profileView.showcaseAssetsModel

    property alias assetsModel: profileView.assetsModel
    property alias collectiblesModel: profileView.collectiblesModel
    
    property alias dirtyValues: profileView.dirtyValues
    property alias dirty: profileView.dirty

    implicitHeight: implicitContentHeight + (header.visible ? header.height : 0)
    width: 640
    padding: 0

    footer: null
    background: null
    header: Item {
        id: headerItem
        height: selector.height + 20
        visible: profileView.isCurrentUser

        TapHandler {
            enabled: root.closePolicy != Popup.NoAutoClose
            onTapped: {
                root.close()
            }   
        }
        ProfilePerspectiveSelector {
            id: selector
            showcaseVisibility: profileView.showcaseMaxVisibility
            onVisibilitySelected: (visibility) => profileView.showcaseMaxVisibility = visibility
        }
    }

    contentItem: ProfileDialogView {
        id: profileView

        onCloseRequested: root.close()
    }
}
