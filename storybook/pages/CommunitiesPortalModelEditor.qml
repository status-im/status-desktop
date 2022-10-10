import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

ListView {
    id: root

    spacing: 25
    ScrollBar.vertical: ScrollBar { }

    function singleShotConnection(prop, handler) {
        const internalHandler = (...args) => {
            handler(...args)
            prop.disconnect(internalHandler)
        }
        prop.connect(internalHandler)
    }

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
            const model = root.model
            const icons = []
            for (let i = 0; i < model.count; i++) {
                icons.push(model.get(i).icon)
            }

            const onlyUnique = (value, index, self) => self.indexOf(value) === index
            const uniqueIcons = icons.filter(onlyUnique)
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
            const model = root.model
            const banners = []
            for (let i = 0; i < model.count; i++) {
                banners.push(model.get(i).banner)
            }

            const onlyUnique = (value, index, self) => self.indexOf(value) === index
            const uniqueBanners = banners.filter(onlyUnique)
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
                    onCheckedChanged: model.featured = checked
                }
                CheckBox {
                    text: "available"
                    checked: model.available
                    onCheckedChanged: model.available = checked
                }
                CheckBox {
                    text: "loaded"
                    checked: model.loaded
                    onCheckedChanged: model.loaded = checked
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
                            singleShotConnection(iconSelector.selected, icon => {
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
                            singleShotConnection(bannerSelector.selected, banner => {
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
