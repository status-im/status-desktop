import QtQuick 2.14
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.14
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

    stackTitle: qsTr("Create New Community")
    width: 640

    nextButton: StatusButton {
        text: qsTr("Next")
        enabled:  nameInput.valid && descriptionTextInput.valid
        onClicked: currentIndex++
    }

    finishButton: StatusButton {
        text: qsTr("Create Community")
        enabled: introMessageInput.valid && outroMessageInput.valid
        onClicked: d.createCommunity()
    }

    stackItems: [
        Flickable {
            id: generalView
            clip: true
            contentHeight: generalViewLayout.height
            implicitHeight: generalViewLayout.implicitHeight
            interactive: contentHeight > height
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: generalViewLayout
                width: generalView.width
                spacing: 12

                CommunityNameInput {
                    id: nameInput
                    Layout.fillWidth: true
                    Component.onCompleted: nameInput.input.forceActiveFocus(
                                                Qt.MouseFocusReason)
                }

                CommunityDescriptionInput {
                    id: descriptionTextInput
                    Layout.fillWidth: true
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
            spacing: 12

            CommunityIntroMessageInput {
                id: introMessageInput

                Layout.fillWidth: true
                Layout.fillHeight: true

                input.maximumHeight: 0
            }

            CommunityOutroMessageInput {
                id: outroMessageInput

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
