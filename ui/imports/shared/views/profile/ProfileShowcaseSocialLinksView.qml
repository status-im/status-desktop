import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Popups 0.1

import shared.controls.delegates 1.0
import utils 1.0

Item {
    id: root

    required property string mainDisplayName
    required property var socialLinksModel

    property alias cellWidth: webView.cellWidth
    property alias cellHeight: webView.cellHeight

    signal copyToClipboard(string text)

    StatusBaseText {
        anchors.centerIn: parent
        visible: (webView.count === 0)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.palette.directColor1
        text: qsTr("%1 has not shared any links").arg(root.mainDisplayName)
    }
    StatusGridView {
        id: webView

        anchors.fill: parent
        topMargin: Theme.bigPadding
        bottomMargin: Theme.bigPadding
        leftMargin: Theme.bigPadding

        visible: count

        model: root.socialLinksModel
        ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: width / 2 }
        delegate: InfoCard {
            id: socialLinksInfoDelegate
            readonly property int linkType: ProfileUtils.linkTextToType(model.text)
            width: GridView.view.cellWidth - Theme.padding
            height: GridView.view.cellHeight - Theme.padding
            title: !!ProfileUtils.linkTypeToText(linkType) ? ProfileUtils.linkTypeToText(linkType) : model.text
            asset.bgColor: ProfileUtils.linkTypeBgColor(linkType)
            asset.name: ProfileUtils.linkTypeToIcon(linkType)
            asset.color: ProfileUtils.linkTypeColor(linkType)
            asset.width: 20
            asset.height: 20
            asset.bgWidth: 32
            asset.bgHeight: 32
            asset.isImage: false
            subTitle: model.url
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    Global.openMenu(delegatesActionsMenu, this, { url: model.url });
                }
            }
            highlight: hovered
            rightSideButtons: RowLayout {
                StatusFlatRoundButton {
                    implicitWidth: 24
                    implicitHeight: 24
                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "external"
                    icon.width: 16
                    icon.height: 16
                    radius: width/2
                    highlighted: true
                    visible: socialLinksInfoDelegate.hovered
                    icon.color: socialLinksInfoDelegate.hovered && !hovered ? Theme.palette.baseColor1 : Theme.palette.directColor1

                    onClicked: {
                        Global.openLinkWithConfirmation(model.url, StatusQUtils.StringUtils.extractDomainFromLink(model.url));
                    }
                }
            }
        }
    }

    Item {
        width: 279
        height: 32
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        visible: (webView.count > 0)
        Rectangle {
            anchors.fill: parent
            color: Theme.palette.background
            radius: 30
            border.color: Theme.palette.baseColor2
        }
        Row {
            anchors.centerIn: parent
            spacing: 4
            StatusIcon {
                width: 16
                height: 16
                icon: "info"
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                font.pixelSize: Theme.additionalTextSize
                text: qsTr("Social handles and links are unverified")
            }
        }
    }

    Component {
        id: delegatesActionsMenu
        StatusMenu {
            id: contextMenu

            property string url

            StatusSuccessAction {
                id: copyAddressAction
                successText: qsTr("Copied")
                text: qsTr("Copy link")
                icon.name: "copy"
                onTriggered: {
                    root.copyToClipboard(contextMenu.url);
                }
            }
        }
    }
}
