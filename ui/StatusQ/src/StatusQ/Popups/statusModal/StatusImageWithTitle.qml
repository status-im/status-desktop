import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Row {
    id: statusImageWithTitle

    property alias title: headerTitle.text
    property alias subTitle: headerSubTitle.text
    property int titleElide: Text.ElideRight
    property int subTitleElide: Text.ElideRight
    property bool editable: false

    signal editButtonClicked

    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
        isIdenticon: false
    }

    property StatusIconSettings icon: StatusIconSettings {
        width: 40
        height: 40
        isLetterIdenticon: false
    }

    spacing: 8

    Loader {
        id: iconOrImage
        anchors.verticalCenter: parent.verticalCenter
        width: active ? 40 : 0
        sourceComponent: {
            if (statusImageWithTitle.icon.isLetterIdenticon) {
                return statusLetterIdenticon
            }
            return statusRoundedImageCmp
        }
        active: statusImageWithTitle.icon.isLetterIdenticon || 
                !!statusImageWithTitle.image.source.toString()
    }

    Component {
        id: statusLetterIdenticon
        StatusLetterIdenticon {
            width: statusImageWithTitle.icon.width
            height: statusImageWithTitle.icon.height
            color: statusImageWithTitle.icon.background.color
            name: statusImageWithTitle.title
        }
    }

    Component {
        id: statusRoundedImageCmp
        Item {
            width: statusImageWithTitle.image.width
            height: statusImageWithTitle.image.height
            StatusRoundedImage {
                id: statusRoundedImage
                image.source:  statusImageWithTitle.image.source
                width: statusImageWithTitle.image.width
                height: statusImageWithTitle.image.height
                color: statusImageWithTitle.image.isIdenticon ?
                    Theme.palette.statusRoundedImage.backgroundColor :
                    "transparent"
                border.width: statusImageWithTitle.image.isIdenticon ? 1 : 0
                border.color: Theme.palette.directColor7
                showLoadingIndicator: true
            }
            Loader {
                sourceComponent: statusLetterIdenticon
                active: statusRoundedImage.image.status === Image.Error
            }
        }
    }

    Column {
        id: textLayout
        width: !iconOrImage.active ? parent.width :
              parent.width - iconOrImage.width - parent.spacing
        Row {
            id: headerTitleRow
            width: parent.width
            spacing: 4
            StatusBaseText {
                id: headerTitle
                font.family: Theme.palette.baseFont.name
                font.pixelSize: 17
                font.bold: true
                elide: statusImageWithTitle.titleElide
                color: Theme.palette.directColor1
                width: !editButton.visible ? parent.width : 
                      parent.width - editButton.width - parent.spacing
            }
            StatusFlatRoundButton {
                id: editButton
                visible: statusImageWithTitle.editable
                anchors.bottom: headerTitle.bottom
                anchors.bottomMargin: -1
                height: 24
                width: 24
                type: StatusFlatRoundButton.Type.Secondary
                icon.name: "pencil"
                icon.color: Theme.palette.directColor1
                icon.width: 12.5
                icon.height: 12.5

                onClicked: statusImageWithTitle.editButtonClicked()
            }
        }

        StatusBaseText {
            id: headerSubTitle
            font.family: Theme.palette.baseFont.name
            font.pixelSize: 15
            color:Theme.palette.baseColor1
            width: parent.width
            elide: statusImageWithTitle.subTitleElide
        }
    }
}
