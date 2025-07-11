import QtQuick
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Utils as SQUtils
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups.Dialog
import StatusQ.Layout

import utils
import shared.controls
import shared.popups
import shared.stores

import SortFilterProxyModel

import AppLayouts.Communities.controls
import AppLayouts.Communities.popups
import AppLayouts.Communities.views
import AppLayouts.Communities.panels
import AppLayouts.Communities.stores

StatusSectionLayout {
    id: root

    property CommunitiesStore communitiesStore

    property var assetsModel
    property var collectiblesModel

    property bool createCommunityEnabled: true
    property bool createCommunityBadgeVisible

    objectName: "communitiesPortalLayout"
    onNotificationButtonClicked: Global.openActivityCenterPopup()

    onVisibleChanged: {
        if(visible)
            searcher.input.edit.forceActiveFocus()
    }

    QtObject {
        id: d

        // values from the design
        readonly property int layoutTopMargin: Theme.smallPadding
        readonly property int layoutBottomMargin: Theme.xlPadding*2
        readonly property int titlePixelSize: 28
        readonly property int preventShadowClipMargin: Theme.padding
 
        readonly property bool searchMode: searcher.text.length > 0
    }

    SortFilterProxyModel {
        id: filteredCommunitiesModel

        function selectedTagsPredicate(selectedTagsNames, tagsJSON) {
            if (!tagsJSON) {
                return true
            }
            const tags = JSON.parse(tagsJSON)
            for (const i in tags) {
                selectedTagsNames = selectedTagsNames.filter(name => name !== tags[i].name)
            }
            return selectedTagsNames.length === 0
        }

        sourceModel: root.communitiesStore.curatedCommunitiesModel

        filters: [
            SQUtils.SearchFilter {
                roleName: "name"
                searchPhrase: searcher.text
            },
            FastExpressionFilter {
                expression: {
                    return filteredCommunitiesModel.selectedTagsPredicate(communityTags.selectedTagsNames, model.tags)
                }
                expectedRoles: ["tags"]
            },
            ValueFilter {
                roleName: "amIBanned"
                value: false
            }
        ]
    }

    centerPanel: Item {
        anchors.fill: parent

        anchors.topMargin: d.layoutTopMargin
        anchors.leftMargin: Theme.xlPadding*2
        anchors.rightMargin: Theme.xlPadding

        ColumnLayout {
            id: column

            anchors.fill: parent
            spacing: 18

            StatusBaseText {
                text: qsTr("Discover Communities")
                font.weight: Font.Bold
                font.pixelSize: d.titlePixelSize
                color: Theme.palette.directColor1
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                spacing: Theme.bigPadding

                SearchBox {
                    id: searcher
                    Layout.fillWidth: true
                    Layout.maximumWidth: 327
                    Layout.preferredHeight: 38
                    Layout.alignment: Qt.AlignVCenter
                    topPadding: 0
                    bottomPadding: 0
                }

                // Just a row filler to fit design
                Item { Layout.fillWidth: true }

                StatusButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    Layout.maximumWidth: implicitWidth
                    text: qsTr("Join Community")
                    verticalPadding: 0
                    onClicked: Global.importCommunityPopupRequested()
                }

                StatusButton {
                    objectName: "createCommunityButton"
                    visible: root.createCommunityEnabled
                    Layout.preferredHeight: 38
                    verticalPadding: 0
                    text: qsTr("Create New Community")
                    type: StatusBaseButton.Type.Primary
                    onClicked: {
                        // Global.openPopup(chooseCommunityCreationTypePopupComponent) // hidden as part of https://github.com/status-im/status-desktop/issues/17726
                        root.communitiesStore.setCreateCommunityPopupSeen()
                        Global.createCommunityPopupRequested(false /*isDiscordImport*/)
                    }

                    StatusNewBadge {
                        visible: root.createCommunityBadgeVisible
                    }
                }
            }

            TagsRow {
                id: communityTags
                Layout.fillWidth: true

                tags: root.communitiesStore.communityTags
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: -d.preventShadowClipMargin
                Layout.rightMargin: -d.preventShadowClipMargin

                clip: true

                CommunitiesGridView {
                    id: communitiesGrid

                    anchors.fill: parent
                    anchors.rightMargin: d.preventShadowClipMargin
                    anchors.leftMargin: d.preventShadowClipMargin
                    contentWidth: availableWidth

                    padding: 0
                    bottomPadding: d.layoutBottomMargin

                    model: filteredCommunitiesModel
                    searchLayout: d.searchMode

                    assetsModel: root.assetsModel
                    collectiblesModel: root.collectiblesModel

                    onCardClicked: (communityId) => root.communitiesStore.navigateToCommunity(communityId)
                }
            }
        }
    }

    Component {
        id: chooseCommunityCreationTypePopupComponent
        StatusDialog {
            id: chooseCommunityCreationTypePopup
            title: qsTr("Create new community")
            horizontalPadding: 40
            verticalPadding: 60
            footer: null
            onClosed: destroy()

            contentItem: RowLayout {
                spacing: 20
                BannerPanel {
                    objectName: "createCommunityBanner"
                    text: qsTr("Create a new Status community")
                    buttonText: qsTr("Create new")
                    icon.name: "favourite"
                    onButtonClicked: {
                        chooseCommunityCreationTypePopup.close()
                        Global.createCommunityPopupRequested(false /*isDiscordImport*/)
                    }
                }
                BannerPanel {
                    readonly property bool importInProgress: root.communitiesStore.discordImportInProgress && !root.communitiesStore.discordImportCancelled
                    text: importInProgress ?
                        qsTr("'%1' import in progress...").arg(root.communitiesStore.discordImportCommunityName || root.communitiesStore.discordImportChannelName) :
                        qsTr("Import existing Discord community into Status")
                    buttonText: qsTr("Import existing")
                    icon.name: "download"
                    buttonTooltipText: qsTr("Your current import must be finished or cancelled before a new import can be started.")
                    buttonLoading: importInProgress
                    onButtonClicked: {
                        chooseCommunityCreationTypePopup.close()
                        Global.createCommunityPopupRequested(true /*isDiscordImport*/)
                    }
                }
            }
        }
    }
}
