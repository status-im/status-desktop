import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

ListView {
    id: root

    spacing: 25
    ScrollBar.vertical: ScrollBar { }

    ImageSelectPopup {
        id: iconSelector

        parent: root
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8

        model: ListModel {
            id: iconsModel
        }

        Component.onCompleted: {
            const uniqueIcons = StorybookUtils.getUniqueValuesFromModel(root.model, "icon")
            uniqueIcons.map(image => iconsModel.append( { image }))
        }
    }

    ImageSelectPopup {
        id: bannerSelector

        parent: root
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8

        model: ListModel {
            id: bannersModel
        }

        Component.onCompleted: {
            const uniqueBanners = StorybookUtils.getUniqueValuesFromModel(root.model, "banner")
            uniqueBanners.map(image => bannersModel.append( { image }))
        }
    }

    delegate: Rectangle {
        width: parent.width
        height: column.implicitHeight

        ColumnLayout {
            id: column

            width: parent.width
            spacing: 2

            Label {
                text: "community id: " + model.communityId
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

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                Rectangle {
                    border.color: 'gray'
                    Layout.preferredWidth: root.width / 2
                    Layout.fillHeight: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        fillMode: Image.PreserveAspectFit
                        source: model.icon
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            iconSelector.open()
                            StorybookUtils.singleShotConnection(iconSelector.selected, icon => {
                                model.icon = icon
                                iconSelector.close()
                            })
                        }
                    }
                }

                Rectangle {
                    border.color: 'gray'
                    Layout.preferredWidth: root.width / 2
                    Layout.fillHeight: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        fillMode: Image.PreserveAspectFit
                        source: model.banner
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            bannerSelector.open()
                            StorybookUtils.singleShotConnection(bannerSelector.selected, banner => {
                                model.banner = banner
                                bannerSelector.close()
                            })
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
                spacing: 4

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
                spacing: 4

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
}
