import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

StatusDialog {
    id: root

    title: qsTr("Can not connect to mailserver")

    StatusBaseText {
        anchors.fill: parent
        text: qsTr("The mailserver you're connecting to is unavailable.")
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Pick another")
                onClicked: {
                    Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging)
                    root.close()
                }
            }
            StatusButton {
                text: qsTr("Retry")
                onClicked: {
                    // Retrying already happens automatically, so doing nothing
                    // here is the same as retrying...
                    root.close()
                }
            }
        }
    }
}
