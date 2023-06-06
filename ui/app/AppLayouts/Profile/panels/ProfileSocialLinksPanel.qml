import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0

import utils 1.0

import AppLayouts.Profile.popups 1.0

import SortFilterProxyModel 0.2

Control {
    id: root

    property var profileStore
    property var socialLinksModel

    background: null

    Component {
        id: addSocialLinkModalComponent
        AddSocialLinkModal {
            containsSocialLink: root.profileStore.containsSocialLink
            onAddLinkRequested: root.profileStore.createLink(linkText, linkUrl, linkType, linkIcon)
        }
    }

    Component {
        id: modifySocialLinkModal
        ModifySocialLinkModal {
            containsSocialLink: root.profileStore.containsSocialLink
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
            StatusBaseText {
                text: qsTr("%1/%2").arg(root.profileStore.temporarySocialLinksModel.count).arg(Constants.maxNumOfSocialLinks)
                color: Theme.palette.baseColor1
            }
        }

        // empty placeholder when no links; dashed rounded rectangle
        ShapeRectangle {
            readonly property bool maxReached: root.profileStore.temporarySocialLinksModel.count === Constants.maxNumOfSocialLinks

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // the rectangular path is rendered outside
            Layout.preferredHeight: 44
            text: maxReached? qsTr("Link limit of %1 reached").arg(Constants.maxNumOfSocialLinks) : ""

            StatusLinkText {
                objectName: "addMoreSocialLinks"
                anchors.centerIn: parent
                visible: !parent.maxReached
                text: qsTr("＋ Add a link")
                color: Theme.palette.primaryColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                font.weight: Font.Normal
                onClicked: Global.openPopup(addSocialLinkModalComponent)
            }
        }

        StatusListView {
            id: linksView
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            model: root.socialLinksModel
            interactive: false

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
                    hasIcon: true
                    icon.name: model.icon
                    icon.color: ProfileUtils.linkTypeColor(model.linkType)
                    actions: [
                        StatusLinkText {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Math.ceil(implicitWidth)
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
