import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    anchors.fill: parent
    color: themeManager.background

    Image {
        width: 500
        height: width
        anchors.centerIn: parent
        id: standartImage
        source: "qrc:/img/Assets/image/SigmaTap.png"
    }

    // Профиль пользователя
    Rectangle {
        id: profile
        property real defaultWidth: parent.width / 5
        property real defaultHeight: parent.height / 6
        width: defaultWidth
        height: defaultHeight
        anchors {
            left: parent.left
            top: parent.top
            margins: 12
        }
        color: themeManager.figure
        radius: 10
        border.width: 2
        border.color: Qt.darker(themeManager.border, 1.2)

        // Плавный переход цвета при наведении
        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        Behavior on height {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        // Контейнер для текста
        Column {
            id: contentColumn
            anchors {
                fill: parent
                margins: 8
            }
            spacing: Math.min(parent.height * 0.02, 6)

            // Логин
            Text {
                id: loginText
                width: parent.width
                text: qsTr("Логин") + ": " + UserStats.login
                elide: Text.ElideRight
                font {
                    pixelSize: Math.min(profile.defaultHeight * 0.13, profile.defaultWidth * 0.09)
                    bold: true
                }
                color: themeManager.text
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            // Айди пользователя
            Text {
                width: parent.width
                text: qsTr("Айди") + ": " + UserStats.userId
                elide: Text.ElideRight
                font.pixelSize: Math.min(profile.defaultHeight * 0.13, profile.defaultWidth * 0.09)
                color: themeManager.text
                wrapMode: Text.WordWrap
                maximumLineCount: 1
            }

            // Разделительная линия
            Rectangle {
                width: parent.width
                height: 1
                color: themeManager.border
                opacity: 0.6
            }

            // Средняя скорость печати на русском
            Text {
                width: parent.width
                text: qsTr("Ср. скорость RU") + ": " + UserStats.getTypingSpeed("ru") + " " + qsTr("зн/мин")
                elide: Text.ElideRight
                font.pixelSize: Math.min(profile.defaultHeight * 0.13, profile.defaultWidth * 0.09)
                color: themeManager.text
                wrapMode: Text.WordWrap
                maximumLineCount: 1
            }

            // Средняя скорость печати на английском
            Text {
                width: parent.width
                text: qsTr("Ср. скорость EN") + ": " + UserStats.getTypingSpeed("en") + " " + qsTr("зн/мин")
                elide: Text.ElideRight
                font.pixelSize: Math.min(profile.defaultHeight * 0.13, profile.defaultWidth * 0.09)
                color: themeManager.text
                wrapMode: Text.WordWrap
                maximumLineCount: 1
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                profile.width = profile.defaultWidth * 1.15
                profile.height = profile.defaultHeight * 1.15
            }
            onExited: {
                profile.width = profile.defaultWidth
                profile.height = profile.defaultHeight
            }
            onClicked: {
                console.log("Нажали на профиль")
                profileWindow.visible = true
            }
        }
    }

    // Вкладки языков
    Row {
        id: languageTabs
        anchors {
            top: parent.top
            margins: 20
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 30

        property var pageMapping: [
            "TypingTrainerRU.qml",   // Русский
            "TypingTrainerEN.qml",   // Английский
            "TypingTrainerTest.qml"  // Тест
        ]

        Repeater {
            model: [qsTr("Русский"), qsTr("Английский"), qsTr("Тест")]

            Rectangle {
                width: 110
                height: 50
                color: "transparent"
                border {
                    color: "transparent"
                    width: 2
                }
                radius: 12

                // Индикатор активной вкладки
                Rectangle {
                    id: tabIndicator
                    width: parent.width
                    height: 3
                    color: themeManager.border
                    anchors.bottom: parent.bottom
                    opacity: 0
                    radius: 1.5

                    // Анимация появления индикатора
                    PropertyAnimation on opacity {
                        id: indicatorAnimation
                        running: false
                        from: 0
                        to: 0.8
                        duration: 200
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        parent.border.color = themeManager.border
                        indicatorAnimation.running = true
                    }

                    onExited: {
                        parent.border.color = "transparent"
                        tabIndicator.opacity = 0
                    }

                    onClicked: {
                        // Загрузка соответствующего QML файла по индексу
                        pageLoader.source = languageTabs.pageMapping[index]
                        console.log("Загружен модуль: " + languageTabs.pageMapping[index])
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: themeManager.text
                    font {
                        pixelSize: 16
                        bold: true
                    }
                }
            }
        }
    }

    // Кнопка настроек
    SettingsButton {
        id: settingsButton
    }

    // Кнопка выхода из приложения
    Rectangle {
        id: exitButton
        width: 60
        height: width
        color: themeManager.figure
        radius: width / 2
        anchors {
            top: settingsButton.bottom
            right: parent.right
            topMargin: 12
            rightMargin: 12
        }

        // Вместо тени используем обводку
        border.width: 1.5
        border.color: Qt.darker(themeManager.figure, 1.3)

        // Иконка выхода (крестик)
        Item {
            id: exitIcon
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: width

            Rectangle {
                width: parent.width
                height: 3
                radius: 1.5
                anchors.centerIn: parent
                color: exitMouseArea.containsMouse ? "#E74C3C" : themeManager.text
                rotation: 45

                // Анимация изменения цвета
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            Rectangle {
                width: parent.width
                height: 3
                radius: 1.5
                anchors.centerIn: parent
                color: exitMouseArea.containsMouse ? "#E74C3C" : themeManager.text
                rotation: -45

                // Анимация изменения цвета
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }

        MouseArea {
            id: exitMouseArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                exitScaleAnimation.running = true
            }

            onExited: {
                exitIcon.scale = 1
            }

            onClicked: {
                console.log("Выход из приложения")
                Qt.quit()
            }
        }

        PropertyAnimation {
            id: exitScaleAnimation
            target: exitIcon
            property: "scale"
            from: 1
            to: 1.3
            duration: 200
            easing.type: Easing.OutBack
        }
    }

    Setting {
        id: settingsWindow
    }

    ProfileWindow {
        id: profileWindow
    }
}
