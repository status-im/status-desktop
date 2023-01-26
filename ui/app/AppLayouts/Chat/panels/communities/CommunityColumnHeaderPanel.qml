import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

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

    padding: Style.current.halfPadding
    rightPadding: Style.current.padding
    topPadding: Style.current.smallPadding

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
