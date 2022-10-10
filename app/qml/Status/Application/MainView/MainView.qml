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
            currentIndex: 1
        }

        ColumnLayout {
            // Not visible all the time
            StatusBanner {
                Layout.fillWidth: true

                //statusText:   // TODO: appController.bannerController.text
                //type:         // TODO: appController.bannerController.type
                visible: false  // TODO: appController.bannerController.visible
            }

            StackLayout {
                id: container
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex: navBar.currentIndex

                Repeater{
                    model: appSections.sections

                    delegate: Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        active: navBar.currentIndex === index

                        sourceComponent: modelData.content
                    }
                }
            }
        }
    }

    StatusApplicationSections {
        id: appSections
        appController: root.appController
    }
}
