import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

Item {
    id: root

    property alias source: bannerPreview.source
    property alias cropRect: bannerPreview.cropRect
    /*required*/ property alias aspectRatio: bannerPreview.aspectRatio

    property bool roundedImage: true

    /*required*/ property string imageFileDialogTitle: ""
    /*required*/ property string title: ""
    /*required*/ property string acceptButtonText: ""

    property string dataImage: ""

    property bool userSelectedImage: false
    readonly property bool nothingToShow: state === d.noImageState

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight


    states: [
        State {
            name: d.dataImageState
            when: root.dataImage.length > 0 && !userSelectedImage
        },
        State {
            name: d.noImageState
            when: root.dataImage.length === 0 && !userSelectedImage
        },
        State {
            name: d.imageSelectedState
            when: userSelectedImage
        }
    ]

    QtObject {
        id: d

        readonly property string dataImageState: "dataImage"
        readonly property string noImageState: "noImage"
        readonly property string imageSelectedState: "imageSelected"
    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: !bannerEditor.visible

            StatusRoundedImage {
                id: profilePic

                anchors.fill: parent

                visible: root.state === d.dataImageState

                image.source: root.dataImage
                showLoadingIndicator: true
                border.width: 1
                border.color: Style.current.border
            }

            StatusImageCropPanel
            {
                id: bannerPreview

                anchors.fill: parent

                visible: root.state === d.imageSelectedState

                interactive: false
                wallColor: Theme.palette.statusAppLayout.backgroundColor
                wallTransparency: 1
                margins: 0

                windowStyle: roundedImage ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
            }

            StatusRoundButton {
                id: editButton

                icon.name: "edit"

                // bottom-right corner
                x: root.userSelectedImage
                    ? bannerPreview.cropWindow.x + bannerPreview.cropWindow.width - (roundedImage ? editButton.width : editButton.width/2 + bannerPreview.radius)
                    : parent.width - editButton.width
                y: (root.userSelectedImage
                    ? bannerPreview.cropWindow.y + bannerPreview.cropWindow.height - (roundedImage ? editButton.height + Style.current.smallPadding : editButton.height/2)
                    : parent.width - editButton.height) - Style.current.smallPadding

                type: StatusRoundButton.Type.Secondary

                onClicked: bannerCropperModal.chooseImageToCrop()
            }
        }

        Rectangle {
            id: bannerEditor

            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: root.state === d.noImageState

            radius: roundedImage ? Math.max(width, height)/2 : bannerPreview.radius
            color: Style.current.inputBackground

            StatusRoundButton {
                id: addButton

                icon.name: "add"

                // top-right corner
                x: parent.width - (roundedImage ? editButton.width : editButton.width/2 + bannerEditor.radius)
                y: roundedImage ? addButton.height/2 : -addButton.height/2 + bannerEditor.radius

                type: StatusRoundButton.Type.Secondary

                onClicked: bannerFileDialog.open()
                z: bannerEditor.z + 1
            }

            BannerCropperModal {
                id: bannerCropperModal
                onImageCropped: {
                    bannerPreview.source = image
                    bannerPreview.setCropRect(cropRect)
                    root.userSelectedImage = true
                }
            }
        }
    }
}
