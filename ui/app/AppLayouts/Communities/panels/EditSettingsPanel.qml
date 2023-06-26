import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0

StatusScrollView {
    id: root
    objectName: "communityEditPanelScrollView"

    property alias name: nameInput.text
    property alias description: descriptionTextInput.text
    property alias introMessage: introMessageTextInput.text
    property alias outroMessage: outroMessageTextInput.text
    property alias color: colorPicker.color
    property alias tags: tagsPicker.tags
    property alias selectedTags: tagsPicker.selectedTags
    property alias options: options

    property alias logoImageData: logoPicker.imageData
    property alias logoImagePath: logoPicker.source
    property alias logoCropRect: logoPicker.cropRect
    property alias bannerImageData: bannerPicker.imageData
    property alias bannerPath: bannerPicker.source
    property alias bannerCropRect: bannerPicker.cropRect

    property size bottomReservedSpace: Qt.size(0, 0)
    property bool bottomReservedSpaceActive: false

    readonly property bool saveChangesButtonEnabled: !((nameInput.input.dirty && !nameInput.valid) ||
                                                       (descriptionTextInput.input.dirty && !descriptionTextInput.valid))

    ColumnLayout {
        id: layout

        width: 608
        spacing: 12

        NameInput {
            id: nameInput
            input.edit.objectName: "editCommunityNameInput"
            Layout.fillWidth: true
            Component.onCompleted: nameInput.input.forceActiveFocus(Qt.MouseFocusReason)
        }

        DescriptionInput {
            id: descriptionTextInput
            input.edit.objectName: "editCommunityDescriptionInput"
            Layout.fillWidth: true
        }

        LogoPicker {
            id: logoPicker
            objectName: "editCommunityLogoPicker"
            Layout.fillWidth: true
        }

        BannerPicker {
            id: bannerPicker
            objectName: "editCommunityBannerPicker"
            Layout.fillWidth: true
        }

        ColorPicker {
            id: colorPicker
            objectName: "editCommunityColorPicker"
            onPick: Global.openPopup(pickColorComponent)
            Layout.fillWidth: true

            Component {
                id: pickColorComponent

                StatusStackModal {
                    width: 640
                    anchors.centerIn: parent
                    leftButtons: []
                    replaceItem: ColorPanel {
                        clip: true
                        Component.onCompleted: color = colorPicker.color
                        onAccepted: {
                            colorPicker.color = color;
                            close();
                        }
                    }
                    onClosed: destroy()
                }
            }
        }

        TagsPicker {
            id: tagsPicker
            objectName: "editCommunityTagsPicker"
            onPick: Global.openPopup(pickTagsComponent)
            Layout.fillWidth: true

            Component {
                id: pickTagsComponent

                StatusStackModal {
                    anchors.centerIn: parent
                    leftButtons: []
                    width: 640
                    replaceItem: TagsPanel {
                        Component.onCompleted: {
                            tags = tagsPicker.tags;
                            selectedTags = tagsPicker.selectedTags;
                        }
                        onAccepted: {
                            tagsPicker.selectedTags = selectedTags;
                            close();
                        }
                    }
                    onClosed: destroy()
                }
            }
        }

        StatusModalDivider {
            Layout.fillWidth: true
            Layout.bottomMargin: -layout.spacing
        }

        Options {
            id: options
            Layout.fillWidth: true
        }

        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: -layout.spacing
            Layout.bottomMargin: 8
        }

        IntroMessageInput {
            id: introMessageTextInput
            input.edit.objectName: "editCommunityIntroInput"
            Layout.fillWidth: true
            minimumHeight: 108
            maximumHeight: 108
        }

        OutroMessageInput {
            id: outroMessageTextInput
            input.edit.objectName: "editCommunityOutroInput"
            Layout.fillWidth: true
        }

        Item {
            // settingsDirtyToastMessage placeholder
            visible: root.bottomReservedSpaceActive
            implicitWidth: root.bottomReservedSpace.width
            implicitHeight: root.bottomReservedSpace.height
        }
    }
}

