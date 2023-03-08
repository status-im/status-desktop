import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import AppLayouts.Profile.popups 1.0

import SortFilterProxyModel 0.2

Control {
    id: root

    property var profileStore
    property var socialLinksModel

    background: null

    implicitHeight: layout.implicitHeight + linksView.contentHeight

    Component {
        id: addSocialLinkModalComponent
        AddSocialLinkModal {
            onAddLinkRequested: root.profileStore.createLink(linkText, linkUrl, linkType, linkIcon)
        }
    }

    Component {
        id: modifySocialLinkModal
        ModifySocialLinkModal {
            onUpdateLinkRequested: root.profileStore.updateLink(uuid, linkText, linkUrl)
            onRemoveLinkRequested: root.profileStore.removeLink(uuid)
        }
    }

    contentItem: ColumnLayout {
        id: layout
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: Style.current.halfPadding
            StatusBaseText {
                text: qsTr("Links")
                color: Theme.palette.baseColor1
            }
            Item { Layout.fillWidth: true }
            StatusLinkText {
                text: qsTr("＋ Add more links")
                color: Theme.palette.primaryColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                font.weight: Font.Normal
                onClicked: Global.openPopup(addSocialLinkModalComponent)
            }
        }

        SortFilterProxyModel {
            id: filteredSocialLinksModel
            sourceModel: root.socialLinksModel
            filters: ExpressionFilter {
                expression: model.text !== "" && model.url !== ""
            }
        }

        // empty placeholder when no links; dashed rounded rectangle
        ShapeRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // the rectangular path is rendered outside
            Layout.preferredHeight: 44
            visible: !filteredSocialLinksModel.count
            text: qsTr("Your links will appear here")
        }

        StatusListView {
            id: linksView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.socialLinksModel

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: DropArea {
                id: delegateRoot

                property int visualIndex: index

                width: ListView.view.width
                height: draggableDelegate.height

                keys: ["x-status-draggable-list-item-internal"]

                onEntered: function(drag) {
                    const from = drag.source.visualIndex
                    const to = draggableDelegate.visualIndex
                    if (to === from)
                        return
                    root.profileStore.moveLink(from, to, 1)
                    drag.accept()
                }

                onDropped: function(drop) {
                    root.profileStore.saveSocialLinks(true /*silent*/)
                }

                StatusDraggableListItem {
                    id: draggableDelegate

                    readonly property string asideText: ProfileUtils.stripSocialLinkPrefix(model.url, model.linkType)

                    visible: !!asideText
                    width: parent.width
                    height: visible ? implicitHeight : 0

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }

                    dragParent: linksView
                    visualIndex: delegateRoot.visualIndex
                    draggable: linksView.count > 1
                    title: ProfileUtils.linkTypeToText(model.linkType) || model.text
                    icon.name: model.icon
                    icon.color: ProfileUtils.linkTypeColor(model.linkType)
                    actions: [
                        StatusLinkText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.primaryTextFontSize
                            font.weight: Font.Normal
                            text: draggableDelegate.asideText
                            onClicked: Global.openLink(model.url)
                        },
                        StatusFlatRoundButton {
                            icon.name: "edit_pencil"
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            icon.width: 16
                            icon.height: 16
                            type: StatusFlatRoundButton.Type.Tertiary
                            tooltip.text: qsTr("Edit link")
                            onClicked: Global.openPopup(modifySocialLinkModal,
                                                        {linkType: model.linkType, icon: model.icon, uuid: model.uuid,
                                                            linkText: model.text, linkUrl: draggableDelegate.asideText})
                        }
                    ]
                }
            }
        }
    }
}
