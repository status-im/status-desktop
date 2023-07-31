import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

import AppLayouts.Communities.panels 1.0
import StatusQ.Core.Theme 0.1

import utils 1.0

SplitView {

    QtObject {
        id: d

        property string name: "Uniswap"
        property int membersCount: 184
        property bool amISectionAdmin: false
        property color color: "orchid"
        property url image: Style.png("tokens/UNI")
        property bool openCreateChat: false
    }

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                width: widthSlider.value
                height: communityColumnHeader.implicitHeight
                anchors.centerIn: parent
                color: Theme.palette.baseColor4

                ColumnHeaderPanel {
                    id: communityColumnHeader

                    width: widthSlider.value
                    anchors.centerIn: parent
                    name: d.name
                    membersCount: d.membersCount
                    image: d.image
                    color: d.color
                    amISectionAdmin: d.amISectionAdmin
                    openCreateChat: false
                    onInfoButtonClicked: logs.logEvent("ColumnHeaderPanel::onInfoButtonClicked()")
                    onAdHocChatButtonClicked: {
                        logs.logEvent("ColumnHeaderPanel::onAdHocChatButtonClicked(): " + openCreateChat.toString())
                        openCreateChat = !openCreateChat
                    }
                }
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 250
            logsView.logText: logs.logText

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Width:"
                }

                Slider {
                    id: widthSlider
                    value: 400
                    from: 250
                    to: 600
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        CommunityInfoEditor {
            name: d.name
            membersCount: d.membersCount
            amISectionAdmin: d.amISectionAdmin
            color: d.color
            image: d.image

            onNameChanged: d.name = name
            onMembersCountChanged: d.membersCount = membersCount
            onAmISectionAdminChanged: d.amISectionAdmin = amISectionAdmin
            onColorChanged: d.color = color
            onImageChanged: d.image = image
        }
    }
}

// category: Panels
