import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core.Theme

import SortFilterProxyModel

Item {
    id: root

    ListModel {
        id: colorsModel

        function extractColorGroup(input) {
          const regex = /^(.*Color)\d+$/;
          const match = input.match(regex);
          return match ? match[1] : "";
        }

        function isColor(val) {
            return val.toString().match(/^#[a-fA-F0-9]+$/)
        }

        function hasColor(val) {
            return val.toString().match(/#[a-fA-F0-9]+/)
        }

        Component.onCompleted: {
            const entries = Object.entries(root.Theme.palette)
            const modelEntries = []

            function add(key, section, getterFunction) {
                modelEntries.push({
                    key,
                    section,
                    getter: ({ get: getterFunction })
                })
            }

            entries.forEach(e => {
                const key = e[0]
                const strValue = e[1].toString()

                if (isColor(strValue)) {
                    const section = extractColorGroup(key) || "Other"
                    add(key, section, () => root.Theme.palette[key])
                } else if (hasColor(strValue)) {
                    const subEntries = Object.entries(root.Theme.palette[key])

                    subEntries.forEach(e => {
                        const subKey = e[0]
                        const strValue = e[1].toString()

                        if (isColor(strValue))
                            add(subKey, key, () => root.Theme.palette[key][subKey])
                    })
                }
            })

            const colorEntries = Object.entries(StatusColors)

            colorEntries.forEach(e => {
                const key = e[0]
                const strValue = e[1].toString()

                if (isColor(strValue))
                    add(key, "Status Colors", () => StatusColors[key])
            })

            const sections = new Map()
            modelEntries.forEach(e => sections.set(e.section, []))
            modelEntries.forEach(e => sections.get(e.section).push(e))

            const modelData = []
            sections.forEach((groupData, groupName)
                             => modelData.push({ groupName, groupData }))

            append(modelData)
        }
    }

    component ColorRectangle: Rectangle {
        id: colorRectangle
        property alias text: textLabel.text

        border.color: "gray"
        radius: 10

        implicitWidth: 260
        implicitHeight: 120

        Control {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            padding: 5

            background: Rectangle {
                color: "white"
                opacity: 0.2
                radius: 5
            }

            contentItem: Column {
                Row {
                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text {
                        id: textLabel
                    }
                    ToolButton {
                        focusPolicy: Qt.NoFocus
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        padding: 0
                        text: "📋"
                        font.pixelSize: Theme.asideTextFontSize
                        onClicked: ClipboardUtils.setText(textLabel.text)
                        ToolTip.text: "Copy color name"
                        ToolTip.visible: hovered
                    }
                }
                Row {
                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text {
                        id: colorLabel
                        color: textLabel.color
                        text: colorRectangle.color.toString()
                    }
                    ToolButton {
                        focusPolicy: Qt.NoFocus
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        padding: 0
                        text: "📋"
                        font.pixelSize: Theme.asideTextFontSize
                        onClicked: ClipboardUtils.setText(colorLabel.text)
                        ToolTip.text: "Copy color value"
                        ToolTip.visible: hovered
                    }
                }
            }
        }
    }

    component ColorFlow: ColumnLayout {
        id: colorFlow

        property string title
        property var model

        Label {
            Layout.topMargin: 8
            visible: colorRepeater.count
            font.weight: Font.Medium
            font.pixelSize: 15
            topPadding: 8
            text: `${colorFlow.title} (${colorRepeater.count})`
        }
        Flow {
            Layout.preferredWidth: scrollview.availableWidth
            spacing: 5

            visible: colorRepeater.count

            Repeater {
                id: colorRepeater
                model: SortFilterProxyModel {
                    sourceModel: colorFlow.model

                    filters: FastExpressionFilter {
                        readonly property ThemePalette palette: root.Theme.palette

                        expression: {
                            searchField.searchText
                            palette

                            const key = model.key
                            const color = model.getter.get()

                            return key.toLowerCase().includes(searchField.searchText) ||
                                    color.toString().toLowerCase().includes(searchField.searchText)
                        }

                        enabled: searchField.searchText !== ""
                        expectedRoles: ["key", "getter"]
                    }
                }
                delegate: ColorRectangle {
                    required property string key
                    required property var getter

                    text: key
                    color: getter.get()
                }
            }
        }
    }

    ScrollView {
        id: scrollview

        anchors.fill: parent
        padding: 8
        contentWidth: availableWidth

        ColumnLayout {
            spacing: 0

            RowLayout {
                Label {
                    text: "Search"
                    font.weight: Font.Medium
                }
                TextField {
                    Layout.preferredWidth: 200
                    readonly property string searchText: text.toLowerCase()
                    id: searchField
                }
                ToolButton {
                    focusPolicy: Qt.NoFocus
                    text: "❌"
                    enabled: searchField.searchText !== ""
                    onClicked: searchField.clear()
                }
            }

            Repeater {
                model: colorsModel

                delegate: ColorFlow {
                    required property string groupName
                    required property var groupData

                    title: groupName
                    model: groupData
                }
            }
        }
    }

    Component.onCompleted: searchField.forceActiveFocus()
}

// category: Core
// status: good
