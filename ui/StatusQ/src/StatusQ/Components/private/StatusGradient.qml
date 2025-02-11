import QtQuick 2.15
import QtGraphicalEffects 1.15  
  
LinearGradient {
    id: root
    start: Qt.point(-0.48*width, 0.46*height)
    end: Qt.point(1.36*width, 0.42*height)
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#2A799B" }
        GradientStop { position: 0.25; color: "#F6B03C" }
        GradientStop { position: 0.84; color: "#FF33A3" }
    }
}