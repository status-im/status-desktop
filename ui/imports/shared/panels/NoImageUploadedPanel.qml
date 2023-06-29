import QtQuick 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
  /brief Image icon and ulopad text hints for banner and logo
 */
Control {
    id: root

    /*!
       \qmlproperty alias NoImageUploadedPanel::uploadText.
       This property holds the main image upload text value.
    */
    property alias uploadText: uploadText.text

    /*!
       \qmlproperty alias NoImageUploadedPanel::additionalText.
       This property holds an additional text value.
    */
    property alias additionalText: additionalText.text

    /*!
       \qmlproperty alias NoImageUploadedPanel::showAdditionalInfo.
       This property holds if the additional text is shown or not.
    */
    property alias showAdditionalInfo: additionalText.visible

    /*!
       \qmlproperty alias NoImageUploadedPanel::additionalTextPixelSize.
       This property holds the additional text font pixel size value.
    */
    property alias additionalTextPixelSize: additionalText.font.pixelSize

    /*!
       \qmlproperty color NoImageUploadedPanel::uploadTextColor.
       This property sets the upload text color.
    */
    property color uploadTextColor: Theme.palette.baseColor1

    /*!
       \qmlproperty color NoImageUploadedPanel::imgColor.
       This property sets the image color.
    */
    property color imgColor: Theme.palette.baseColor1

    /*!
       \qmlproperty alias NoImageUploadedPanel::contentSpacing.
        This property sets the content spacing.
    */
    property alias contentSpacing: content.spacing
    
    /*!
       \qmlproperty alias NoImageUploadedPanel::iconWidth.
        This property sets the content icon width.
    */
    property alias iconWidth: imageImg.width

    /*!
       \qmlproperty alias NoImageUploadedPanel::iconHeight.
        This property sets the content icon height.
    */
    property alias iconHeight: imageImg.height

    QtObject {
        id: d

        readonly property int imageSelectorPadding: 75
    }

    contentItem: ColumnLayout {
        id: content
        Image {
            id: imageImg
            source: Style.svg("images_icon")
            width: 20
            height: 18
            sourceSize.width: width || undefined
            sourceSize.height: height || undefined
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            layer.enabled: !Qt.colorEqual(root.imgColor, Theme.palette.baseColor1)
            layer.effect: ColorOverlay {
                color: root.imgColor
            }
        }

        StatusBaseText {
            id: uploadText

            text: qsTr("Upload")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.preferredWidth: root.width - 2 * d.imageSelectorPadding
            font.pixelSize: Theme.primaryTextFontSize
            color: root.uploadTextColor
            wrapMode: Text.WordWrap
            lineHeight: 1.2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        StatusBaseText {
            id: additionalText

            text: qsTr("Wide aspect ratio is optimal")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            visible: false
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.baseColor1
        }
    }
}
