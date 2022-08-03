import QtQuick 2.14
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.14
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import "../../Chat/controls/community"

import "../controls"
import "../panels"

StatusStackModal {
    id: root

    property var store
    property string finishButtonLabel: qsTr("Create Community")

    stackTitle: qsTr("Create New Community")
    width: 640

    nextButton: StatusButton {
        objectName: "createCommunityNextBtn"
        text: qsTr("Next")
        enabled:  typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof(nextAction) == "function") {
                return nextAction()
            }
            root.currentIndex++
        }
    }

    finishButton: StatusButton {
        objectName: "createCommunityFinalBtn"
        text: finishButtonLabel
        enabled:  typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof (nextAction) == "function") {
                return nextAction()
            }
            root.close()
        }
    }

    onAboutToShow: nameInput.input.edit.forceActiveFocus()

    stackItems: [
        StatusScrollView {
            id: generalView

            readonly property bool canGoNext: nameInput.valid && descriptionTextInput.valid

            ColumnLayout {
                id: generalViewLayout
                width: generalView.availableWidth
                spacing: 16

                CommunityNameInput {
                    id: nameInput
                    input.edit.objectName: "createCommunityNameInput"
                    Layout.fillWidth: true
                    input.tabNavItem: descriptionTextInput.input.edit
                }

                CommunityDescriptionInput {
                    id: descriptionTextInput
                    input.edit.objectName: "createCommunityDescriptionInput"
                    Layout.fillWidth: true
                    input.tabNavItem: nameInput.input.edit
                }

                CommunityLogoPicker {
                    id: logoPicker
                    Layout.fillWidth: true
                }

                CommunityColorPicker {
                    id: colorPicker
                    onPick: root.replace(colorPanel)
                    Layout.fillWidth: true

                    Component {
                        id: colorPanel

                        CommunityColorPanel {
                            Component.onCompleted: color = colorPicker.color
                            onAccepted: {
                                colorPicker.color = color;
                                root.replace(null);
                            }
                        }
                    }
                }

                CommunityTagsPicker {
                    id: communityTagsPicker
                    tags: root.store.communityTags
                    onPick: root.replace(tagsPanel)
                    Layout.fillWidth: true

                    Component {
                        id: tagsPanel

                        CommunityTagsPanel {
                            Component.onCompleted: {
                                tags = communityTagsPicker.tags;
                                selectedTags = communityTagsPicker.selectedTags;
                            }
                            onAccepted: {
                                communityTagsPicker.selectedTags = selectedTags;
                                root.replace(null);
                            }
                        }
                    }
                }

                StatusModalDivider {
                    Layout.fillWidth: true
                }

                CommunityOptions {
                    id: options

                    archiveSupportOptionVisible: root.store.isCommunityHistoryArchiveSupportEnabled
                    archiveSupportEnabled: archiveSupportOptionVisible
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        },
        ColumnLayout {
            id: introOutroMessageView
            spacing: 11
            readonly property bool canGoNext: introMessageInput.valid && outroMessageInput.valid

            CommunityIntroMessageInput {
                id: introMessageInput
                input.edit.objectName: "createCommunityIntroMessageInput"

                Layout.fillWidth: true
                Layout.fillHeight: true

                minimumHeight: height
                maximumHeight: (height - Style.current.xlPadding)
            }

            CommunityOutroMessageInput {
                id: outroMessageInput
                input.edit.objectName: "createCommunityOutroMessageInput"

                Layout.fillWidth: true
            }
        }
    ]

    QtObject {
        id: d

        function createCommunity() {
            const error = store.createCommunity({
                    name: Utils.filterXSS(nameInput.input.text),
                    description: Utils.filterXSS(descriptionTextInput.input.text),
                    introMessage: Utils.filterXSS(introMessageInput.input.text),
                    outroMessage: Utils.filterXSS(outroMessageInput.input.text),
                    color: colorPicker.color.toString().toUpperCase(),
                    tags: communityTagsPicker.selectedTags,
                    image: {
                        src: logoPicker.source,
                        AX: logoPicker.cropRect.x,
                        AY: logoPicker.cropRect.y,
                        BX: logoPicker.cropRect.x + logoPicker.cropRect.width,
                        BY: logoPicker.cropRect.y + logoPicker.cropRect.height,
                    },
                    options: {
                        historyArchiveSupportEnabled: options.archiveSupportEnabled,
                        checkedMembership: options.requestToJoinEnabled ? Constants.communityChatOnRequestAccess : Constants.communityChatPublicAccess,
                        pinMessagesAllowedForMembers: options.pinMessagesEnabled
                    }
            })
            if (error) {
                errorDialog.text = error.error
                errorDialog.open()
            }
            root.close()
        }
    }

    MessageDialog {
        id: errorDialog

        title: qsTr("Error creating the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}
