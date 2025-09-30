import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Utils
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Models

import SortFilterProxyModel

Button {
    id: root

    // language currently selected for translations, e.g. "cs"
    required property string currentLanguage
    // list of language/locale codes, e.g. ["cs_CZ","ko","fr"]
    required property var languageCodes

    signal languageSelected(string languageCode)

    font.family: Theme.baseFont.name
    font.weight: Font.Medium
    font.pixelSize: Theme.additionalTextSize

    horizontalPadding: Theme.smallPadding
    verticalPadding: Theme.halfPadding
    spacing: 4

    opacity: enabled ? 1.0 : Theme.disabledOpacity

    text: d.beautifyIsoCode(d.selectedLanguage)

    QtObject {
        id: d

        readonly property string selectedLanguage: root.currentLanguage || "en" // TODO extend with ISO code validation; fallback to "en"

        readonly property int maxPopupHeight: 400
        readonly property int delegateHeight: 70

        readonly property SortFilterProxyModel languageModel: SortFilterProxyModel {
            id: languageModel
            sourceModel: LanguageModel {
                languageCodes: root.languageCodes
            }
            filters: [
                AnyOf {
                    enabled: searchField.text !== ""
                    SearchFilter {
                        roleName: "code"
                        searchPhrase: searchField.text
                    }
                    SearchFilter {
                        roleName: "name"
                        searchPhrase: searchField.text
                    }
                    SearchFilter {
                        roleName: "nativeName"
                        searchPhrase: searchField.text
                    }
                }
            ]
            sorters: StringSorter {
                roleName: "nativeName"
            }
        }

        function beautifyIsoCode(code) {
            return code.replace('_', '-').toUpperCase()
        }
    }

    background: Rectangle {
        radius: Theme.radius
        color: root.enabled && (root.hovered || dropdown.opened) ? Theme.palette.primaryColor2 : Theme.palette.primaryColor3
        Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
    }

    contentItem: RowLayout {
        spacing: root.spacing
        StatusIcon {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            icon: "globe"
            color: Theme.palette.primaryColor1
        }
        StatusBaseText {
            horizontalAlignment: Qt.AlignHCenter
            text: root.text
            color: Theme.palette.primaryColor1
            font: root.font
        }
        StatusIcon {
            icon: "chevron-down"
            color: Theme.palette.primaryColor1
        }
    }

    onClicked: dropdown.opened ? dropdown.close() : dropdown.open()

    StatusDropdown {
        id: dropdown

        objectName: "dropdown"

        directParent: root
        relativeX: root.width - width
        relativeY: root.height + 2
        width: 300
        margins: Theme.halfPadding

        padding: 0

        onOpened: searchField.forceActiveFocus()
        onClosed: searchField.input.edit.clear()

        contentItem: ColumnLayout {
            spacing: Theme.halfPadding
            StatusInput {
                id: searchField
                Layout.topMargin: Theme.padding
                Layout.preferredWidth: userSelectorPanel.width - userSelectorPanel.leftMargin - userSelectorPanel.rightMargin
                Layout.alignment: Qt.AlignHCenter
                placeholderText: qsTr("Search")
                input.asset.name: "search"
                input.clearable: true
                KeyNavigation.tab: userSelectorPanel
            }
            StatusListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: Theme.padding
                Layout.maximumHeight: d.maxPopupHeight
                leftMargin: Theme.padding
                rightMargin: 14
                id: userSelectorPanel
                model: d.languageModel
                implicitHeight: contentHeight
                spacing: 4
                highlightFollowsCurrentItem: true
                highlight: Rectangle {
                    radius: Theme.radius
                    color: userSelectorPanel.activeFocus ? Theme.palette.primaryColor2 : "transparent"
                }

                delegate: ItemDelegate {
                    width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
                    height: d.delegateHeight
                    checked: model.code === d.selectedLanguage
                    background: Rectangle {
                        radius: Theme.radius
                        color: userSelectorPanel.activeFocus ? "transparent" : hovered ? Theme.palette.primaryColor2 : "transparent"
                    }
                    contentItem: RowLayout {
                        ColumnLayout {
                            Layout.fillWidth: true
                            StatusBaseText {
                                Layout.fillWidth: true
                                horizontalAlignment: Qt.AlignLeft // force LTR
                                text: model.nativeName
                                font.capitalization: Font.Capitalize
                                font.pixelSize: root.font.pixelSize
                                font.weight: root.font.weight
                            }
                            StatusBaseText {
                                Layout.fillWidth: true
                                text: "%1 (%2)".arg(model.name).arg(d.beautifyIsoCode(model.code))
                                font: root.font
                                color: Theme.palette.baseColor1
                            }
                        }
                        StatusIcon {
                            Layout.preferredHeight: 20
                            Layout.alignment: Qt.AlignRight
                            visible: checked
                            icon: "tiny/checkmark"
                            color: Theme.palette.primaryColor1
                        }
                    }
                    onClicked: {
                        dropdown.close()
                        root.languageSelected(model.code)
                    }
                    HoverHandler {
                        cursorShape: hovered ? Qt.PointingHandCursor : undefined
                    }
                }
            }
        }
    }

    HoverHandler {
        cursorShape: hovered ? Qt.PointingHandCursor : undefined
    }
}
