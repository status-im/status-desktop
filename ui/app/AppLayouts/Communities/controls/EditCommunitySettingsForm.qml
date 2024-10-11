import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Popups 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0

Control {
    id: root

    property alias nameLabel: nameInput.label
    property alias descriptionLabel: descriptionTextInput.label

    readonly property alias isNameValid: nameInput.valid
    readonly property alias isNameDirty: nameInput.input.dirty
    readonly property alias isDescriptionValid: descriptionTextInput.valid
    readonly property alias isDescriptionDirty: descriptionTextInput.input.dirty
    readonly property alias isLogoSelected: logoPicker.hasSelectedImage
    readonly property alias isBannerSelected: bannerPicker.hasSelectedImage
    readonly property alias areTagsSelected: tagsPicker.hasSelectedTags

    property alias name: nameInput.text
    property alias description: descriptionTextInput.text
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
    
    implicitWidth: 608

    function validate(isDevBuild = false) {
        if (!nameInput.validate(true))
            nameInput.input.dirty = true
        if (!descriptionTextInput.validate(true))
            descriptionTextInput.input.dirty = true
        if (!isDevBuild) {
            logoPicker.validate()
            bannerPicker.validate()
            tagsPicker.validate()
        }

        return nameInput.valid && descriptionTextInput.valid &&
                (isDevBuild ? true : logoPicker.hasSelectedImage && bannerPicker.hasSelectedImage && tagsPicker.hasSelectedTags)
    }

    contentItem: ColumnLayout {
        spacing: 16

        NameInput {
            id: nameInput
            input.edit.objectName: "communityNameInput"
            Layout.fillWidth: true
            input.tabNavItem: descriptionTextInput.input.edit
            Component.onCompleted: nameInput.input.forceActiveFocus()
        }

        DescriptionInput {
            id: descriptionTextInput
            input.edit.objectName: "communityDescriptionInput"
            input.tabNavItem: nameInput.input.edit
            Layout.fillWidth: true
        }

        LogoPicker {
            id: logoPicker
            objectName: "communityLogoPicker"
            onHasSelectedImageChanged: validate()
            Layout.fillWidth: true
        }

        BannerPicker {
            id: bannerPicker
            objectName: "communityBannerPicker"
            onHasSelectedImageChanged: validate()
            Layout.fillWidth: true
            Layout.topMargin: -8 //Closer by design
        }

        ColorPicker {
            id: colorPicker
            objectName: "communityColorPicker"
            onPick: Global.openPopup(pickColorComponent)
            Layout.fillWidth: true
            Layout.topMargin: 2

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
            objectName: "communityTagsPicker"
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
                            tags = tagsPicker.tags
                            selectedTags = tagsPicker.selectedTags
                        }
                        onAccepted: {
                            tagsPicker.selectedTags = selectedTags
                            tagsPicker.validate()
                            close()
                        }
                    }
                    onClosed: destroy()
                }
            }
        }

        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: -root.spacing
        }

        Options {
            id: options
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4
        }
    }
}
