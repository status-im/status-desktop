import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils

Control {
    id: root

    property string name
    property int membersCount
    property url image
    property color color
    property bool amISectionAdmin
    property bool openCreateChat

    signal infoButtonClicked
    signal adHocChatButtonClicked

    padding: Theme.halfPadding
    rightPadding: Theme.padding
    topPadding: Theme.smallPadding

    contentItem: RowLayout {
        StatusChatInfoButton {
            objectName: "communityHeaderButton"
            Layout.fillWidth: true
            title: root.name
            subTitle: qsTr("%n member(s)", "", root.membersCount)
            asset.name: root.image
            asset.color: root.color
            asset.isImage: true
            type: StatusChatInfoButton.Type.OneToOneChat
            hoverEnabled: root.amISectionAdmin
            onClicked: if(root.amISectionAdmin) root.infoButtonClicked()
        }

        StatusIconTabButton {
            objectName: "startChatButton"
            icon.name: "edit"
            icon.color: Theme.palette.directColor1
            Layout.alignment: Qt.AlignVCenter
            checked: root.openCreateChat
            highlighted: root.openCreateChat
            onClicked: root.adHocChatButtonClicked()

            StatusToolTip {
                text: qsTr("Start chat")
                visible: parent.hovered
                orientation: StatusToolTip.Orientation.Bottom
                y: parent.height + 12
            }
        }
    }
}
