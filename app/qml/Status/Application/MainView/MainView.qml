import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Status.Application

import Status.Containers
import Status.Controls

import Status.Controls.Navigation

/// Responsible for setup of user workflows after onboarding
Item {
    id: root

    required property ApplicationController appController

    /// Emitted when everything is loaded and UX ready
    signal ready()

    Component.onCompleted: root.ready()

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    RowLayout {
        id: mainLayout

        anchors.fill: parent

        NavigationBar {
            id: navBar

            Layout.fillHeight: true

            sections: appSections.sections
        }

        ColumnLayout {
            // Not visible all the time
            StatusBanner {
                Layout.fillWidth: true

                //statusText:   // TODO: appController.bannerController.text
                //type:         // TODO: appController.bannerController.type
                visible: false  // TODO: appController.bannerController.visible
            }
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true

                sourceComponent: navBar.currentSection
            }
        }
    }

    StatusApplicationSections {
        id: appSections
    }
}
