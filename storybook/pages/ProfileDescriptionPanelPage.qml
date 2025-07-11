import QtQuick
import QtQuick.Controls

import StatusQ.Core.Utils
import StatusQ.Controls

import AppLayouts.Profile.panels

import utils

import Storybook

Item {
    id: root

    property bool globalUtilsReady: false

    Frame {
        anchors.centerIn: parent
        implicitWidth: 500
        padding:20

        QtObject {
            function isAlias(name) {
                return false;
            }

            Component.onCompleted: {
                Utils.globalUtilsInst = this
                root.globalUtilsReady = true
            }

            Component.onDestruction: {
                root.globalUtilsReady = false
                Utils.globalUtilsInst = {}
            }
        }

        Loader {

            anchors.centerIn: parent
            active: root.globalUtilsReady

            sourceComponent: ProfileDescriptionPanel {
                anchors.centerIn: parent
                displayName.text: "Alba Theodor"
                displayName.validationMode: StatusInput.ValidationMode.Always
                bio.text: "29-year-old magitician 🤔who enjoys camping and binge-watching boxed sets. " +
                          "Kind and friendly 🤼, but can also be very unfriendly and a bit lazy. " +
                          "Started studying philosophy😎 and economics but never finished the course."
            }
        }
    }
}

// category: Panels
