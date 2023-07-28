import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import shared.controls 1.0
import shared.controls.delegates 1.0

StatusDropdown {
    id: root

    property var selectedKeys: new Set()
    property bool forceButtonDisabled: false
    property int maximumListHeight: 288

    property alias model: listView.model
    readonly property alias count: listView.count

    readonly property alias searchText: filterInput.text

    enum Mode {
        Add, Update
    }

    Instantiator {
        id: selectionChecker

        model: root.model

        property var keys: []

        delegate: QtObject {
            readonly property string key: model.airdropAddress
        }

        readonly property bool allSelected:
            keys.every(key => root.selectedKeys.has(key))

        onObjectAdded: {
            const keysCopy = [...keys]
            keysCopy.splice(index, 0, object.key)
            keys = keysCopy
        }

        onObjectRemoved: {
            const keysCopy = [...keys]
            keysCopy.splice(index, 1)
            keys = keysCopy
        }
    }

    property int mode: MembersDropdown.Mode.Add

    signal backButtonClicked
    signal addButtonClicked

    width: 295

    padding: 11
    bottomInset: 10
    bottomPadding: padding + bottomInset

    onOpened: {
        listView.positionViewAtBeginning()
        filterInput.text = ""
    }

    QtObject {
        id: d

        readonly property int sectionDelegateHeight: 40
        readonly property int delegateHeight: 47
        readonly property int scrollBarWidth: 4
    }

    contentItem: ColumnLayout {
        id: content

        spacing: 8
        height: root.availableHeight
        clip: true

        StatusIconTextButton {
            id: backButton

            Layout.preferredHeight: 48
            Layout.maximumWidth: root.availableWidth

            spacing: 0
            leftPadding: 4
            statusIcon: "previous"
            icon.width: 12
            icon.height: 12
            text: qsTr("Back")

            onClicked: root.backButtonClicked()
        }

        SearchBox {
            id: filterInput

            Layout.fillWidth: true

            placeholderText: qsTr("Search members")
            maximumHeight: 36
            topPadding: 0
            bottomPadding: 0

            input.asset.width: 15
            input.asset.height: 15
            input.leftPadding: 13
            input.font.pixelSize: 13
            input.placeholder.font.pixelSize: 13
        }

        StatusBaseText {
            id: noContactsText

            Layout.fillWidth: true
            Layout.preferredHeight: 50
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: listView.count === 0

            text: qsTr("No contacts found")
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.tertiaryTextFontSize
            elide: Text.ElideRight
            lineHeight: 1.2
        }

        StatusListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: Math.min(contentHeight,
                                             root.maximumListHeight)

            verticalScrollBar {
                implicitWidth: d.scrollBarWidth + ScrollBar.vertical.padding * 2
            }

            visible: count > 0

            header: StatusCheckBox  {
                width: ListView.view.width

                text: qsTr("Select all")
                font.weight: Font.Medium

                checked: selectionChecker.allSelected

                leftSide: false
                size: StatusCheckBox.Size.Small
                indicator.anchors.rightMargin: 12

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        const currentKeys = selectionChecker.keys
                        const keysSet = new Set([...root.selectedKeys])

                        if (listView.headerItem.checked)
                            currentKeys.forEach(key => keysSet.delete(key))
                        else
                            currentKeys.forEach(key => keysSet.add(key))

                        root.selectedKeys = keysSet
                    }
                }
            }

            delegate: ContactListItemDelegate {
                id: delegateRoot

                width: ListView.view.width
                height: d.delegateHeight
                asset.width: 29
                asset.height: 29

                rightPadding: 0
                leftPadding: 6

                color: "transparent"

                onClicked: {
                    const selectedKeysCopy = new Set([...root.selectedKeys])

                    if (root.selectedKeys.has(model.airdropAddress))
                        selectedKeysCopy.delete(model.airdropAddress)
                    else
                        selectedKeysCopy.add(model.airdropAddress)

                    root.selectedKeys = selectedKeysCopy
                }

                components: [
                    StatusCheckBox  {
                        id: contactCheckbox

                        size: StatusCheckBox.Size.Small
                        checked: root.selectedKeys.has(model.airdropAddress)

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: delegateRoot.clicked(
                                           delegateRoot.itemId, mouse)
                        }
                    }
                ]
            }

            section.property: "displayName"
            section.criteria: ViewSection.FirstCharacter
            section.delegate: StatusBaseText {
                text: section.toUpperCase()

                width: ListView.view.width
                height: d.sectionDelegateHeight

                padding: 5
                verticalAlignment: Qt.AlignVCenter

                color: Theme.palette.baseColor1
                font.pixelSize: Theme.tertiaryTextFontSize
            }
        }

        StatusButton {
            id: addButton

            Layout.fillWidth: true

            enabled: {
                if (root.forceButtonDisabled)
                    return false

                if (root.mode === MembersDropdown.Mode.Add)
                    return root.selectedKeys.size > 0

                return true
            }

            text: {
                if (root.mode === MembersDropdown.Mode.Update)
                    return qsTr("Update members")

                return root.selectedKeys.size > 0
                        ? qsTr("Add %n member(s)", "", root.selectedKeys.size)
                        : qsTr("Add")
            }

            onClicked: root.addButtonClicked()
        }
    }
}
