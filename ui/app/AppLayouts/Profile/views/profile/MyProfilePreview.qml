import QtQuick 2.14
import QtGraphicalEffects 1.14

import shared.views 1.0 as SharedViews

import StatusQ.Core.Theme 0.1

Item {
    property alias profileStore: profilePreview.profileStore
    property alias contactsStore: profilePreview.contactsStore
    property alias sendToAccountEnabled: profilePreview.sendToAccountEnabled
    property alias dirtyValues: profilePreview.dirtyValues
    property alias dirty: profilePreview.dirty

    property alias showcaseCommunitiesModel: profilePreview.showcaseCommunitiesModel
    property alias showcaseAccountsModel: profilePreview.showcaseAccountsModel
    property alias showcaseCollectiblesModel: profilePreview.showcaseCollectiblesModel
    property alias showcaseSocialLinksModel: profilePreview.showcaseSocialLinksModel
    property alias showcaseAssetsModel: profilePreview.showcaseAssetsModel

    property alias assetsModel: profilePreview.assetsModel
    property alias collectiblesModel: profilePreview.collectiblesModel

    implicitHeight: profilePreview.implicitHeight 
                        + profilePreview.anchors.topMargin 
                        + profilePreview.anchors.bottomMargin

    implicitWidth: profilePreview.implicitWidth 
                        + profilePreview.anchors.leftMargin 
                        + profilePreview.anchors.rightMargin

    function reload() {
        profilePreview.reload()
    }

    SharedViews.ProfileDialogView {
        id: profilePreview
        anchors.fill: parent
        anchors.margins: 64
        readOnly: true
    }

    DropShadow {
        id: shadow
        anchors.fill: profilePreview
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 12
        color: "#40000000"
        source: profilePreview
    }
}
