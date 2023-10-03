import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import AppLayouts.Communities.popups 1.0

import utils 1.0
import SortFilterProxyModel 0.2

import Storybook 1.0

SplitView {
    id: root

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        function isCompressedPubKey(publicKey) {
            return true
        }

        function getCompressedPk(publicKey) {
            return "compressed_" + publicKey
        }

        function getColorId(publicKey) {
            return Math.floor(Math.random() * 10)
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            globalUtilsReady = true

        }
        Component.onDestruction: {
            globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        function getContactDetailsAsJson() {
            return JSON.stringify({ ensVerified: true })
        }

        Component.onCompleted: {
            mainModuleReady = true
            Utils.mainModuleInst = this
        }
        Component.onDestruction: {
            mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }


    ListModel {
        id: members

        property int counter: 0

        function addMember() {
            const i = counter++
            const key = `pub_key_${i}`

            const firstLetters = ["a", "b", "c", "d"]
            const firstLetterIdx = Math.min(Math.floor(i / firstLetters.length),
                                            firstLetters.length - 1)
            const firstLetter = firstLetters[firstLetterIdx]

            append({
                alias: "",
                colorId: "1",
                displayName: `${firstLetter}contact ${i}`,
                ensName: "",
                icon: "",
                isContact: true,
                localNickname: "",
                onlineStatus: 1,
                pubKey: key,
                isVerified: true,
                isUntrustworthy: false,
                airdropAddress: `0x${firstLetter}${i}`
            })
        }

        Component.onCompleted: {
            for (let i = 0; i < 33; i++)
                addMember()
        }
    }

    Pane {
        id: container

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            id: startRect

            border.color: "green"
            color: "lightgreen"
            border.width: 3
            width: 50
            height: width

            x: 70
            y: 70

            radius: width / 2

            Drag.active: dragArea.drag.active

            MouseArea {
                id: dragArea

                anchors.fill: parent
                drag.target: parent
            }
        }

        Loader {
            id: loader

            anchors.centerIn: parent
            active: globalUtilsReady && mainModuleReady

            sourceComponent: MembersDropdown {
                id: membersDropdown

                closePolicy: Popup.NoAutoClose

                model: SortFilterProxyModel {
                    Binding on sourceModel {
                        when: globalUtilsReady && mainModuleReady
                        value: members
                        restoreMode: Binding.RestoreBindingOrValue
                    }

                    filters: [
                        ExpressionFilter {
                            enabled: membersDropdown.searchText !== ""

                            function matchesAlias(name, filter) {
                                return name.split(" ").some(p => p.startsWith(filter))
                            }

                            expression: {
                                membersDropdown.searchText

                                const filter = membersDropdown.searchText.toLowerCase()
                                return matchesAlias(model.alias.toLowerCase(), filter)
                                         || model.displayName.toLowerCase().includes(filter)
                                         || model.ensName.toLowerCase().includes(filter)
                                         || model.localNickname.toLowerCase().includes(filter)
                                         || model.pubKey.toLowerCase().includes(filter)
                            }
                        }
                    ]
                }

                onBackButtonClicked: {
                    logs.logEvent("MembersDropdown::backButtonClicked")
                }

                onAddButtonClicked: {
                    logs.logEvent("MembersDropdown::addButtonClicked, keys: "
                                  + [...membersDropdown.selectedKeys])
                }

                Component.onCompleted: open()
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 320

        logsView.logText: logs.logText

        Loader {
            active: loader.item

            anchors.left: parent.left
            anchors.right: parent.right

            sourceComponent: ColumnLayout {
                readonly property MembersDropdown membersDropdown: loader.item

                RowLayout {
                    RadioButton {
                        id: addModeRadioButton

                        text: "add mode"
                        checked: true

                        Binding {
                            target: membersDropdown
                            property: "mode"
                            value: addModeRadioButton.checked
                                   ? MembersDropdown.Mode.Add
                                   : MembersDropdown.Mode.Update
                        }
                    }

                    RadioButton {
                        text: "update mode"
                    }

                    CheckBox {
                        id: forceButtonDisabledCheckBox

                        text: "force button disabled"

                        Binding {
                            target: membersDropdown
                            property: "forceButtonDisabled"
                            value: forceButtonDisabledCheckBox.checked
                        }
                    }
                }

                RowLayout {
                    Label {
                        text: "maximum list height:"
                    }

                    Slider {
                        id: maxListHeightSlider
                        from: 100
                        to: 500
                        stepSize: 1

                        Component.onCompleted: {
                            value = membersDropdown.maximumListHeight
                            membersDropdown.maximumListHeight
                                    = Qt.binding(() => value)
                        }
                    }

                    Label {
                        text: maxListHeightSlider.value
                    }
                }

                RowLayout {
                    Label {
                        text: "margins:"
                    }

                    Slider {
                        id: marginsSlider
                        from: -1
                        to: 50
                        stepSize: 1

                        Component.onCompleted: {
                            value = membersDropdown.margins
                            membersDropdown.margins = Qt.binding(() => value)
                        }
                    }

                    Label {
                        text: marginsSlider.value
                    }
                }

                RowLayout {
                    Label {
                        text: "bottom inset:"
                    }

                    Slider {
                        id: bottomInsetSlider
                        from: 0
                        to: 50
                        stepSize: 1

                        Component.onCompleted: {
                            value = membersDropdown.bottomInset
                            membersDropdown.bottomInset = Qt.binding(() => value)
                        }
                    }

                    Label {
                        text: bottomInsetSlider.value
                    }
                }

                RowLayout {
                    RadioButton {
                        id: anchorToItemRadioButton
                        text: "anchor to item"

                        checked: true
                    }
                    RadioButton {
                        id: anchorToOverlayRadioButton
                        text: "anchor to overlay"

                    }

                    Binding {
                        target: membersDropdown
                        property: "parent"
                        value: anchorToItemRadioButton.checked
                               ? startRect : membersDropdown.Overlay.overlay
                    }

                    Binding {
                        target: membersDropdown.anchors
                        when: anchorToOverlayRadioButton.checked
                        property: "centerIn"
                        value: membersDropdown.parent
                        restoreMode: Binding.RestoreBindingOrValue
                    }

                    Binding {
                        target: membersDropdown
                        property: "x"
                        value: anchorToItemRadioButton.checked
                               ? startRect.width / 2 : 0
                    }

                    Binding {
                        target: membersDropdown
                        property: "y"
                        value: anchorToItemRadioButton.checked
                               ? startRect.height / 2 : 0
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: `selected members: ${[...membersDropdown.selectedKeys]}`
                    wrapMode: Label.Wrap
                }
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22647-498410
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22642-497015
