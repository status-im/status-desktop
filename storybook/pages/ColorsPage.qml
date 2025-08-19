import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme

import Storybook

import SortFilterProxyModel

SplitView {
    id: root

    orientation: Qt.Vertical

    component ColorRectangle: Rectangle {
        id: colorRectangle
        property alias text: textLabel.text

        implicitWidth: 120
        implicitHeight: 60
        Column {
            anchors.centerIn: parent
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

    component ColorFlow: ColumnLayout {
        id: colorFlow

        property string title
        property var model

        ListModel {
            id: listModel
            Component.onCompleted: {
                append(Object.entries(colorFlow.model))
            }
        }

        Label {
            Layout.topMargin: 8
            //visible: colorRepeater.count
            font.weight: Font.Medium
            text: "%1 (%2)".arg(colorFlow.title).arg(colorRepeater.count)
        }
        Flow {
            Layout.preferredWidth: scrollview.availableWidth
            spacing: 5

            Repeater {
                id: colorRepeater
                model: SortFilterProxyModel {
                    sourceModel: listModel
                    proxyRoles: [
                        ExpressionRole {
                            name: "name"
                            expression: model[0]
                        },
                        ExpressionRole {
                            name: "color"
                            expression: model[1]
                        }
                    ]
                    filters: FastExpressionFilter {
                        expression: {
                            searchField.searchText
                            return (!!model.name && model.name.toLowerCase().includes(searchField.searchText)) ||
                                    (!!model.color && model.color.toLowerCase().includes(searchField.searchText))
                        }
                        enabled: searchField.searchText !== ""
                        expectedRoles: ["name", "color"]
                    }
                }
                delegate: ColorRectangle {
                    text: model.name
                    color: model.color
                }
            }
        }
    }

    Component.onCompleted: searchField.forceActiveFocus()

    ScrollView {
        id: scrollview
        contentWidth: availableWidth
        SplitView.fillHeight: true
        padding: 8

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
                Label {
                    text: "INFO: Reload the page after selecting 'Dark mode'"
                    font.weight: Font.Medium
                }
            }

            ColorFlow {
                title: "Base"
                model: {
                    "baseColor1": Theme.palette.baseColor1.toString(),
                    "baseColor2": Theme.palette.baseColor2.toString(),
                    "baseColor3": Theme.palette.baseColor3.toString(),
                    "baseColor4": Theme.palette.baseColor4.toString(),
                    "baseColor5": Theme.palette.baseColor5.toString()
                }
            }

            ColorFlow {
                title: "Primary"
                model: {
                    "primaryColor1": Theme.palette.primaryColor1.toString(),
                    "primaryColor2": Theme.palette.primaryColor2.toString(),
                    "primaryColor3": Theme.palette.primaryColor3.toString()
                }
            }

            ColorFlow {
                title: "Danger"
                model: {
                    "dangerColor1": Theme.palette.dangerColor1.toString(),
                    "dangerColor2": Theme.palette.dangerColor2.toString(),
                    "dangerColor3": Theme.palette.dangerColor3.toString()
                }
            }

            ColorFlow {
                title: "Warning"
                model: {
                    "warningColor1": Theme.palette.warningColor1.toString(),
                    "warningColor2": Theme.palette.warningColor2.toString(),
                    "warningColor3": Theme.palette.warningColor3.toString()
                }
            }

            ColorFlow {
                title: "Success"
                model: {
                    "successColor1": Theme.palette.successColor1.toString(),
                    "successColor2": Theme.palette.successColor2.toString(),
                    "successColor3": Theme.palette.successColor3.toString()
                }
            }

            ColorFlow {
                title: "Direct"
                model: {
                    "directColor1": Theme.palette.directColor1.toString(),
                    "directColor2": Theme.palette.directColor2.toString(),
                    "directColor3": Theme.palette.directColor3.toString(),
                    "directColor4": Theme.palette.directColor4.toString(),
                    "directColor5": Theme.palette.directColor5.toString(),
                    "directColor6": Theme.palette.directColor6.toString(),
                    "directColor7": Theme.palette.directColor7.toString(),
                    "directColor8": Theme.palette.directColor8.toString(),
                    "directColor9": Theme.palette.directColor9.toString()
                }
            }

            ColorFlow {
                title: "Indirect"
                model: {
                    "indirectColor1": Theme.palette.indirectColor1.toString(),
                    "indirectColor2": Theme.palette.indirectColor2.toString(),
                    "indirectColor3": Theme.palette.indirectColor3.toString(),
                    "indirectColor4": Theme.palette.indirectColor4.toString()
                }
            }

            ColorFlow {
                title: "Mention"
                model: {
                    "mentionColor1": Theme.palette.mentionColor1.toString(),
                    "mentionColor2": Theme.palette.mentionColor2.toString(),
                    "mentionColor3": Theme.palette.mentionColor3.toString(),
                    "mentionColor4": Theme.palette.mentionColor4.toString()
                }
            }

            ColorFlow {
                title: "Pin"
                model: {
                    "pinColor1": Theme.palette.pinColor1.toString(),
                    "pinColor2": Theme.palette.pinColor2.toString(),
                    "pinColor3": Theme.palette.pinColor3.toString()
                }
            }

            ColorFlow {
                title: "Misc"
                model: {
                    "miscColor1": Theme.palette.miscColor1.toString(),
                    "miscColor2": Theme.palette.miscColor2.toString(),
                    "miscColor3": Theme.palette.miscColor3.toString(),
                    "miscColor4": Theme.palette.miscColor4.toString(),
                    "miscColor5": Theme.palette.miscColor5.toString(),
                    "miscColor6": Theme.palette.miscColor6.toString(),
                    "miscColor7": Theme.palette.miscColor7.toString(),
                    "miscColor8": Theme.palette.miscColor8.toString(),
                    "miscColor9": Theme.palette.miscColor9.toString(),
                    "miscColor10": Theme.palette.miscColor10.toString(),
                    "miscColor11": Theme.palette.miscColor11.toString(),
                    "miscColor12": Theme.palette.miscColor12.toString()
                }
            }

            ColorFlow {
                title: "User customization"
                model: Theme.palette.userCustomizationColors
            }

            ColorFlow {
                title: "Status colors"
                model: StatusColors.colors
            }
        }
    }
}

// category: Core
// status: good
