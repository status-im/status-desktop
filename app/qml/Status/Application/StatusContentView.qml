import QtQml
import QtQuick
import QtQuick.Controls

import Status.Application
import Status.Onboarding

import Status.Controls.Navigation

/*! Has entry responsibility for the main workflows
  */
Item {
    id: root

    required property ApplicationState appState
    required property ApplicationController appController

    implicitWidth: d.isViewLoaded ? d.loadedView.implicitWidth : 800
    implicitHeight: d.isViewLoaded ? d.loadedView.implicitHeight : 600

    QtObject {
        id: d

        readonly property bool isViewLoaded: contentLoader.status === Loader.Ready
        readonly property Item loadedView: isViewLoaded ? contentLoader.item : null
    }

    Component {
        id: onboardingViewComponent

        OnboardingView {
            onUserLoggedIn: {
                splashScreenPopup.open()
                contentLoader.sourceComponent = mainViewComponent
            }
        }
    }

    Component {
        id: mainViewComponent

        MainView {
            onReady: splashScreenPopup.close()
            appController: root.appController
        }
    }

    Popup {
        id: splashScreenPopup

        onAboutToShow: splashScreenLoader.active = true
        onClosed: splashScreenLoader.active = false
        anchors.centerIn: Overlay.overlay

        Loader {
            id: splashScreenLoader
            active: false
            sourceComponent: SplashScreen {
                id: splasScreen
                onAnimationFinished: splashScreenPopup.close()
            }
            onStatusChanged: if(status === Loader.Ready) item.show()
        }
        background: Item {}
    }

    Loader {
        id: contentLoader

        anchors.fill: parent
        sourceComponent: onboardingViewComponent
    }
}
