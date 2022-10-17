import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    id: root
    Logs { id: logs }

    function findModel(data, model_id) {
        for (let i = 0; i < data.count; i++) {
            let item = data.get(i)
            if (item.model_id === model_id) {
                return item
            }
        }
    }

    property ListModel communitiesData: ListModel {
        ListElement {
            name: "Status"
            description: "Status is a secure messaging app, crypto wallet, and Web3 browser built with state of the art technology."
            members_count: 20
            image: "data:image/jpeg;base64,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"
            color: ""
            joined: true
            model_id: "0x039b2da47552aa117a96ea8f1d4d108ba66637c7517a3c94a57b99dbb8a002eda2"
            muted: false
        }
        ListElement {
            name: "FRENZ"
            description: "You've got a friend in me \n You got troubles, I've got 'em too \n There isn't anything I wouldn't do for you \n We stick together and see it through"
            members_count: 7
            image: "data:image/jpeg;base64,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"
            color: "#51d0f0"
            joined: true
            model_id: "0x02225398deb3a59faf4e06db443eaefd330cf11ed6032a88f9c80c5748d5071d14"
            muted: false
        }
    }

    ImageSelectPopup {
        id: imageSelector

        parent: root
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8

        model: ListModel {
            id: iconsModel
        }

        Component.onCompleted: {
            const uniqueIcons = StorybookUtils.getUniqueValuesFromModel(root.communitiesData, "image")
            uniqueIcons.map(image => iconsModel.append( { image }))
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Label {
            text: "note: invite button and leave community should trigger a modal, this is currently not working in storybook"
        }

        CommunitiesView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width
            communitiesList: communitiesData

            store: QtObject {
                function setActiveCommunity(communityId) {
                    logs.logEvent("store::setActivityCommunity", ["communityId"], arguments)
                }

                function importCommunity(communityKey) {
                    logs.logEvent("store::importCommunity", ["communityKey"], arguments)
                }

                // TODO: this currently does not work because the component is trying to open a modal
                // that is currently incompatible with storybook
                function leaveCommunity(communityKey) {
                    logs.logEvent("store::leaveCommunity", ["communityKey"], arguments)
                    root.findModel(communitiesData, communityId).joined = false
                }

                function setCommunityMuted(communityId, muted) {
                    logs.logEvent("store::setCommunityMuted", ["communityId", "muted"], arguments)
                    root.findModel(communitiesData, communityId).muted = muted
                }

                function inviteUsersToCommunity(keys, inviteMessage) {
                    // store.inviteUsersToCommunity(keys, inviteMessage)
                    logs.logEvent("store::inviteUsersToCommunity", ["keys", "inviteMessage"], arguments)
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        // model editor will go here
        ColumnLayout {
            anchors.fill: parent

            ListView {
                anchors.fill: parent
                model: communitiesData

                delegate: Rectangle {
                    width: parent.width
                    height: column.implicitHeight

                    ColumnLayout {
                        id: column

                        width: parent.width
                        spacing: 2

                        Label {
                            text: "id"
                            font.weight: Font.Bold
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: model.model_id
                            onTextChanged: model.model_id = text
                        }

                        Label {
                            text: "name"
                            font.weight: Font.Bold
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: model.name
                            onTextChanged: model.name = text
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                                    Row {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 1
                                            fillMode: Image.PreserveAspectFit
                                            source: model.image
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                imageSelector.open()
                                                StorybookUtils.singleShotConnection(imageSelector.selected, image => {
                                                    model.image = image
                                                    imageSelector.close()
                                                })
                                            }
                                        }
                                    }
                        }

                        Label {
                            text: "description"
                            font.weight: Font.Bold
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: model.description
                            onTextChanged: model.description = text
                        }

                        Label {
                            text: "members count"
                            font.weight: Font.Bold
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: model.members_count
                            onTextChanged: model.members_count = text
                        }

                        Label {
                            text: "color"
                            font.weight: Font.Bold
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: model.color
                            onTextChanged: model.color = text
                        }

                        Label {
                            text: "joined"
                            font.weight: Font.Bold
                        }

                        Flow {
                            Layout.fillWidth: true

                            CheckBox {
                                text: "joined"
                                checked: model.joined
                                onToggled: model.joined = !model.joined
                            }
                        }

                        Label {
                            text: "muted"
                            font.weight: Font.Bold
                        }

                        Flow {
                            Layout.fillWidth: true

                            CheckBox {
                                text: "muted"
                                checked: model.muted
                                onToggled: model.muted = !model.muted
                            }
                        }
                    }
                }
            }
        }
    }
}
