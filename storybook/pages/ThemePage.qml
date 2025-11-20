import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

Item {
    id: root

    component Panel: Control {
        id: panel

        default property alias content: page.contentChildren
        property alias color: background.color

        background: Rectangle {
            id: background

            color: "yellow"
        }

        padding: Theme.padding

        contentItem: Page {
            id: page

            footer: ColumnLayout {
                RowLayout {
                    Button {
                        text: "reset padding"

                        onClicked: {
                            panel.Theme.padding = undefined
                        }

                        enabled: panel.Theme.explicitPadding
                    }

                    Slider {
                        Layout.preferredWidth: 150

                        from: 0
                        to: 50
                        stepSize: 1

                        value: panel.Theme.padding

                        onValueChanged: {
                            if (value !== panel.Theme.padding)
                                panel.Theme.padding = value
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap

                        font.pixelSize: Theme.fontSize(13)
                        text: `padding: ${panel.Theme.padding}`
                    }
                }

                RowLayout {
                    Button {
                        text: "reset font size"

                        onClicked: {
                            panel.Theme.fontSizeOffset = undefined
                        }

                        enabled: panel.Theme.explicitFontSizeOffset
                    }

                    Slider {
                        Layout.preferredWidth: 150

                        from: -5
                        to: 10
                        stepSize: 1

                        value: panel.Theme.fontSizeOffset

                        onValueChanged: {
                            if (value !== panel.Theme.fontSizeOffset)
                                panel.Theme.fontSizeOffset = value
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap

                        font.pixelSize: Theme.fontSize(13)
                        text: `font size offset: ${panel.Theme.fontSizeOffset}`
                    }
                }

                RowLayout {
                    Label {
                        text: `theme:`
                    }
                    Button {
                        text: "Dark"
                        onClicked: panel.Theme.style = Theme.Dark
                    }

                    Button {
                        text: "Light"
                        onClicked: panel.Theme.style = Theme.Light
                    }

                    Button {
                        text: "Reset"
                        enabled: panel.Theme.explicitStyle
                        onClicked: panel.Theme.style = undefined
                    }

                    Rectangle {
                        border.width: 1
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        color: Theme.palette.background
                    }
                }
            }
        }
    }

    Panel {
        anchors.fill: parent

        Panel {
            anchors.fill: parent

            color: "green"

            RowLayout {
                anchors.fill: parent

                spacing: 0

                Panel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: parent.width / 2

                    color: "red"
                }

                Panel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: parent.width / 2

                    color: "blue"
                }
            }
        }
    }

    Rectangle {
        anchors.fill: row
        anchors.margins: -10
        border.color: "gray"
        opacity: 0.8
    }

    RowLayout {
        id: row

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: 100

        Label {
            text: "Top level padding:"
        }

        Slider {

            from: 0
            to: 50
            stepSize: 1

            value: root.Theme.padding

            onValueChanged: {
                root.Theme.padding = value
            }
        }
    }
}

// category: Utils
// status: good
