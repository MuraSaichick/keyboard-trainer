import QtQuick

// Кнопка настроек
Rectangle {
    id: settingsButton
    width: 60
    height: width
    color: themeManager.figure
    radius: width / 2
    anchors {
        top: parent.top
        right: parent.right
        topMargin: 12
        rightMargin: 12
    }

    // Вместо тени используем обводку
    border.width: 1.5
    border.color: Qt.darker(themeManager.figure, 1.3)

    Image {
        id: settingsIcon
        width: parent.width * 0.7
        height: width
        anchors.centerIn: parent
        source: "qrc:/img/Assets/image/SettingIcon.png"
        fillMode: Image.PreserveAspectFit
        scale: 1

        // Без ColorOverlay - просто меняем непрозрачность
        opacity: settingsMouseArea.containsMouse ? 1.0 : 0.8

        // Анимация изменения непрозрачности
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: settingsMouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            rotationAnimation.running = true
            scaleAnimation.running = true
        }

        onExited: {
            rotationAnimation.running = false
            scaleAnimation.running = false
            settingsIcon.scale = 1
        }

        onClicked: {
            console.log("Нажалась кнопка Настроек")
            settingsWindow.visible = true
        }
    }

    RotationAnimation {
        id: rotationAnimation
        target: settingsIcon
        property: "rotation"
        from: 0
        to: -360
        duration: 1750
        loops: Animation.Infinite
    }

    PropertyAnimation {
        id: scaleAnimation
        target: settingsIcon
        property: "scale"
        from: 1
        to: 1.2
        duration: 500
    }
}
