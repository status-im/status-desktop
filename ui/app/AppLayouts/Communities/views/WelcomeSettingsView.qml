import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components

import AppLayouts.Communities.panels

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design

    property alias image: introPanel.image
    property alias title: introPanel.title
    property alias subtitle: introPanel.subtitle
    property alias checkersModel: introPanel.checkersModel

    property alias infoBoxVisible: infoBox.visible
    property alias infoBoxTitle: infoBox.title
    property alias infoBoxText: infoBox.text
    property alias buttonText: infoBox.buttonText
    property alias buttonVisible: infoBox.buttonVisible

    signal clicked

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: 20

        IntroPanel {
            id: introPanel

            Layout.fillWidth: true
        }

        StatusInfoBoxPanel {
            id: infoBox

            Layout.fillWidth: true
            Layout.bottomMargin: 20
            horizontalPadding: 16
            verticalPadding: 20

            onClicked: root.clicked()
        }
    }
}
