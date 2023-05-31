import QtQuick 2.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0

/*!
   \qmltype TransactionDataTile
   \inherits StatusListItem
   \inqmlmodule shared.controls
   \since shared.controls 1.0
   \brief It displays data for wallet activity.

   The \c TransactionDataTile can display wallet activity data as a tile.
   To show button fill \l{buttonIcon} property.

   \qml
        TransactionDataTile {
            width: parent.width
            title: qsTr("From")
            buttonIcon: "more"
        }
   \endqml
*/

StatusListItem {
    id: root

    /*!
       \qmlproperty int TransactionDataTile::topPadding
       This property holds spacing between top and content item in tile.
    */
    property int topPadding: 12
    /*!
       \qmlproperty int TransactionDataTile::bottomPadding
       This property holds spacing between bottom and content item in tile.
    */
    property int bottomPadding: 12

    /*!
       \qmlproperty bool TransactionDataTile::smallIcon
       This property holds information about icon state. Setting it to true will display small icon before subtitle.

       Default value is false.
    */
    property bool smallIcon: false
    /*!
       \qmlproperty string TransactionDataTile::buttonIconName
       This property holds button icon source string.
       To show button icon source must be filled
    */
    property string buttonIconName

    signal buttonClicked()

    leftPadding: 12
    rightPadding: 12
    height: implicitHeight + bottomPadding
    radius: 0
    sensor.cursorShape: Qt.ArrowCursor

    // Title
    statusListItemTitle.customColor: Theme.palette.directColor5
    statusListItemTitle.enabled: false
    statusListItemTitleArea.anchors {
        left: statusListItemTitleArea.parent.left
        top: statusListItemTitleArea.parent.top
        topMargin: topPadding
        right: statusListItemTitleArea.parent.right
        verticalCenter: undefined
    }

    // Subtitle
    statusListItemTagsRowLayout.anchors.topMargin: 8
    statusListItemTagsRowLayout.width: statusListItemTagsRowLayout.parent.width - (!!root.buttonIconName ? 36 : 0)
    statusListItemSubTitle.customColor: Theme.palette.directColor1

    // Tertiary title
    statusListItemTertiaryTitle.anchors.topMargin: -statusListItemTertiaryTitle.height
    statusListItemTertiaryTitle.horizontalAlignment: Qt.AlignRight

    // Icon
    asset.isImage: false
    statusListItemTagsRowLayout.spacing: 8
    subTitleBadgeComponent: !!asset.name ? iconComponent : null
    statusListItemIcon.asset: StatusAssetSettings {}

    Component {
        id: iconComponent
        StatusRoundIcon {
            asset: StatusAssetSettings {
                name: root.asset.name
                color: "transparent"
                width: root.smallIcon ? 20 : 36
                height: root.smallIcon ? 20 : 36
                bgWidth: width
                bgHeight: height
            }
        }
    }

    components: Loader {
        active: !!root.buttonIconName
        sourceComponent: StatusRoundButton {
            width: 32
            height: 32
            icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            icon.name: root.buttonIconName
            type: StatusRoundButton.Type.Quinary
            radius: 8
            visible: root.sensor.containsMouse
            onClicked: root.buttonClicked()
        }
    }

    Separator {
        anchors.bottom: parent.bottom
    }
}
