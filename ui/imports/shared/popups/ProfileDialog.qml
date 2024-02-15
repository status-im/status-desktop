import QtQuick 2.14

import StatusQ.Popups.Dialog 0.1

import shared.views 1.0

StatusDialog {
    id: root

    property var parentPopup

    property alias publicKey: profileView.publicKey

    property alias profileStore: profileView.profileStore
    property alias contactsStore: profileView.contactsStore
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

    width: 640
    padding: 0

    header: null
    footer: null

    contentItem: ProfileDialogView {
        id: profileView

        onCloseRequested: root.close()
    }
}
