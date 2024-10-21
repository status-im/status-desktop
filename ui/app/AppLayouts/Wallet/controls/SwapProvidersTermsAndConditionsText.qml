import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

RowLayout {
    id: root

    required property string serviceProviderName
    signal linkClicked()
    signal termsAndConditionClicked()

    spacing: 4

    StatusIcon {
        Layout.preferredWidth: 16
        Layout.preferredHeight: 16
        icon: "external-link"
        color: Theme.palette.directColor1
    }
    StatusBaseText {
        font.pixelSize: Theme.additionalTextSize
        text: qsTr("Powered by")
    }
    StatusLinkText {
        Layout.topMargin: 1 // compensate for the underline
        text: "%1.".arg(root.serviceProviderName)
        normalColor: Theme.palette.directColor1
        linkColor: Theme.palette.directColor1
        font.weight: Font.Normal
        onClicked: root.linkClicked()
    }
    StatusBaseText {
        font.pixelSize: Theme.additionalTextSize
        text: qsTr("View")
    }
    StatusLinkText {
        Layout.topMargin: 1 // compensate for the underline
        text: qsTr("Terms & Conditions")
        normalColor: Theme.palette.directColor1
        linkColor: Theme.palette.directColor1
        font.weight: Font.Normal
        onClicked: root.termsAndConditionClicked()
    }
}
