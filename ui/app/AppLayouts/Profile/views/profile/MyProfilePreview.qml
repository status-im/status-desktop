import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.stores 1.0 as WalletStores
import shared.controls 1.0
import shared.views 1.0 as SharedViews

Item {
    property alias contactDetails: profilePreview.contactDetails

    property alias profileStore: profilePreview.profileStore
    property alias contactsStore: profilePreview.contactsStore
    property alias utilsStore: profilePreview.utilsStore

    property alias sendToAccountEnabled: profilePreview.sendToAccountEnabled

    property alias showcaseCommunitiesModel: profilePreview.showcaseCommunitiesModel
    property alias showcaseAccountsModel: profilePreview.showcaseAccountsModel
    property alias showcaseCollectiblesModel: profilePreview.showcaseCollectiblesModel
    property alias showcaseSocialLinksModel: profilePreview.showcaseSocialLinksModel
    property alias showcaseAssetsModel: profilePreview.showcaseAssetsModel

    property alias assetsModel: profilePreview.assetsModel
    property alias collectiblesModel: profilePreview.collectiblesModel

    implicitHeight: profilePreview.implicitHeight 
                        + layout.anchors.topMargin 
                        + layout.anchors.bottomMargin

    implicitWidth: profilePreview.implicitWidth 
                        + layout.anchors.leftMargin 
                        + layout.anchors.rightMargin

    function reload() {
        profilePreview.reload()
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 64
        spacing: 20
        ProfilePerspectiveSelector {
            id: selector
            showcaseVisibility: profilePreview.showcaseMaxVisibility
            onVisibilitySelected: (visibility) => profilePreview.showcaseMaxVisibility = visibility
        }

        SharedViews.ProfileDialogView {
            id: profilePreview

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: implicitHeight

            walletStore: WalletStores.RootStore

            readOnly: true
        }
        Item { Layout.fillHeight: true }
    }

    DropShadow {
        id: shadow
        anchors.fill: layout
        anchors.topMargin: profilePreview.y
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 12
        color: "#40000000"
        source: profilePreview
    }
}
