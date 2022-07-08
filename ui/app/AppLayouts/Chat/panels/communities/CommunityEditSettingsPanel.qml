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

import "../../controls/community"

import "../../../CommunitiesPortal/controls"
import "../../../CommunitiesPortal/panels"

Flickable {
    id: root

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

    readonly property bool saveChangesButtonEnabled: true

    contentWidth: layout.width
    contentHeight: layout.height
    clip: true
    interactive: contentHeight > height
    flickableDirection: Flickable.VerticalFlick

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        width: root.width
        spacing: 12

        CommunityNameInput {
            id: nameInput
            Layout.fillWidth: true
            Component.onCompleted: nameInput.input.forceActiveFocus(Qt.MouseFocusReason)
        }

        CommunityDescriptionInput {
            id: descriptionTextInput
            Layout.fillWidth: true
        }

        CommunityLogoPicker {
            id: logoPicker
            Layout.fillWidth: true
        }

        CommunityBannerPicker {
            id: bannerPicker
            Layout.fillWidth: true
        }

        CommunityColorPicker {
            id: colorPicker
            onPick: Global.openPopup(pickColorComponent)
            Layout.fillWidth: true

            Component {
                id: pickColorComponent

                StatusStackModal {
                    anchors.centerIn: parent
                    width: 640
                    replaceItem: CommunityColorPanel {
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

        CommunityTagsPicker {
            id: tagsPicker
            onPick: Global.openPopup(pickTagsComponent)
            Layout.fillWidth: true

            Component {
                id: pickTagsComponent

                StatusStackModal {
                    anchors.centerIn: parent
                    width: 640
                    replaceItem: CommunityTagsPanel {
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

        CommunityOptions {
            id: options
        }

        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: -layout.spacing
            Layout.bottomMargin: 8
        }

        CommunityIntroMessageInput {
            id: introMessageTextInput
            Layout.fillWidth: true
        }

        CommunityOutroMessageInput {
            id: outroMessageTextInput
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

