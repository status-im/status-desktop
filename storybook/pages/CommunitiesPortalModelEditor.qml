import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

ListView {
    id: root

    spacing: 25
    ScrollBar.vertical: ScrollBar { x: root.width }

    delegate: ColumnLayout {
        id: rootDelegate

        readonly property var _model: model

        width: ListView.view.width

        Label {
            Layout.fillWidth: true
            text: "community id: " + model.id
            font.weight: Font.Bold
        }

        TextField {
            Layout.fillWidth: true
            text: model.name
            onTextChanged: model.name = text
        }

        TextField {
            Layout.fillWidth: true
            text: model.description
            onTextChanged: model.description = text
        }

        Flow {
            Layout.fillWidth: true

            CheckBox {
                text: "featured"
                checked: model.featured
                onToggled: model.featured = checked
            }
            CheckBox {
                text: "available"
                checked: model.available
                onToggled: model.available = checked
            }
            CheckBox {
                text: "loaded"
                checked: model.loaded
                onToggled: model.loaded = checked
            }
        }

        ListView {
            id: tagsSelector

            Layout.fillWidth: true
            implicitHeight: contentItem.childrenRect.height + ScrollBar.horizontal.height

            clip: true
            orientation: ListView.Horizontal
            spacing: 4

            model: ListModel {
                id: communityTags
                Component.onCompleted: {
                    const allTags = JSON.parse(ModelsData.communityTags)
                    const selectedTags = JSON.parse(rootDelegate._model.tags)
                    for (const key of Object.keys(allTags)) {
                        const selected = selectedTags.find(tag => tag.name === key) !== undefined
                        communityTags.append({ name: key, emoji: allTags[key], selected: selected });
                    }
                }
            }

            delegate: Button {
                text: model.name
                checkable: true
                checked: model.selected

                onClicked: {
                    model.selected = !model.selected

                    const selectedTags = []
                    for (let i = 0; i < communityTags.count; ++i) {
                        const tag = communityTags.get(i)
                        if (tag.selected) selectedTags.push({ name: tag.name, emoji: tag.emoji })
                    }

                    rootDelegate._model.tags = JSON.stringify(selectedTags)
                }
            }

            ScrollBar.horizontal: ScrollBar {}
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            Rectangle {
                border.color: 'gray'
                Layout.fillWidth: true
                Layout.fillHeight: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    fillMode: Image.PreserveAspectFit
                    source: model.icon
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: iconSelector.open()

                    ImageSelectPopup {
                        id: iconSelector

                        parent: root
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8

                        model: IconModel {}

                        onSelected: {
                            rootDelegate._model.icon = icon
                            close()
                        }
                    }
                }
            }

            Rectangle {
                border.color: 'gray'
                Layout.fillWidth: true
                Layout.fillHeight: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    fillMode: Image.PreserveAspectFit
                    source: model.banner
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: bannerSelector.open()

                    ImageSelectPopup {
                        id: bannerSelector

                        parent: root
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8

                        model: BannerModel {}

                        onSelected: {
                            rootDelegate._model.banner = icon
                            close()
                        }
                    }
                }
            }
        }

        TextField {
            Layout.fillWidth: true
            maximumLength: 1024 * 1024 * 1024
            text: model.icon
            onTextChanged: model.icon = text
        }

        TextField {
            Layout.fillWidth: true
            maximumLength: 1024 * 1024 * 1024
            text: model.banner
            onTextChanged: model.banner = text
        }

        Row {
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "members:\t"
            }

            SpinBox {
                editable: true
                height: 30
                from: 0; to: 10 * 1000 * 1000
                value:  model.members
                onValueChanged: model.members = value
            }
        }

        Row {
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "active:\t"
            }

            SpinBox {
                editable: true
                height: 30
                from: 0; to: 10 * 1000 * 1000
                value:  model.activeMembers
                onValueChanged: model.activeMembers = value
            }
        }

        Row {
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "popularity:\t"
            }

            SpinBox {
                editable: true
                height: 30
                from: 0; to: 10 * 1000 * 1000
                value:  model.popularity
                onValueChanged: model.popularity = value
            }
        }
    }
}
