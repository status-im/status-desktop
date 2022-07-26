import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQml

import Qt.labs.platform

import Status.Containers
import Status.Controls.Navigation
import Status.Onboarding

/** \brief Drives the onboarding workflow
 *
 */
Item {
    id: root

    /// \c NewAccountController
    required property var newAccountController

    signal userLoggedIn()
    signal abortAccountCreation()

    QtObject {
       id: d

        function goToPreviousPage() {
            if(swipeView.currentItem === setUserNameAndPicturePage)
                root.abortAccountCreation()
            else
                swipeView.currentIndex--
        }
        function goToNextPage() {
            if(swipeView.currentItem === confirmPasswordPage)
                root.userLoggedIn()
            else
                swipeView.currentIndex++
        }
    }

    ObjectModel {
        id: pagesModel

        SetUserNameAndPicturePage {
            id: setUserNameAndPicturePage
            newAccountController: root.newAccountController
        }
        CreatePasswordPage {
            newAccountController: root.newAccountController
        }
        ConfirmPasswordPage {
            id: confirmPasswordPage
            newAccountController: root.newAccountController
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent

        interactive: false

        Repeater {
            id: pageRepeater
            model: pagesModel

            Loader {
                id: pageLoader
                active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                source: modelData
            }
        }
        Connections {
            target: pageRepeater.itemAt(swipeView.currentIndex)
            function onPageDone() { d.goToNextPage() }
            function onGoBack() { d.goToPreviousPage() }
        }
    }

    PageIndicator {
        count: swipeView.count
        currentIndex: swipeView.currentIndex

        anchors.bottom: swipeView.bottom
        anchors.horizontalCenter: swipeView.horizontalCenter
    }
}
