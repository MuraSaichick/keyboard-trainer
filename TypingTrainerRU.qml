import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import LessonManager

Item {
    id: rootItem
    width: 1200
    height: 800
    signal printLessonRequested(int lessonId, string lessonText, string language)
    Rectangle {
        anchors.fill: parent
        color: themeManager.background
    }

    SettingsButton {
        id: settingsButton
    }

    LessonManager {
        id: lessonManager
    }

    // Кнопка назад
    Rectangle {
        id: backButton
        width: 120
        height: 40
        anchors {
            left: parent.left
            top: parent.top
            margins: 20
        }
        color: backMouseArea.containsMouse ? themeManager.buttonHoverColor : themeManager.button
        radius: 5
        border.color: themeManager.border
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        layer.enabled: true

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "←"
                font.pixelSize: 18
                font.bold: true
                color: themeManager.text
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Назад"
                font.pixelSize: 16
                color: themeManager.text
            }
        }

        MouseArea {
            id: backMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                pageLoader.source = "MainMenu.qml"
            }
        }
    }

    ScrollView {
        anchors {
            left: parent.left
            right: parent.right
            top: backButton.bottom
            bottom: parent.bottom
            topMargin: 20
        }
        contentWidth: rootItem.width
        contentHeight: lessonGrid.height + 40
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        GridLayout {
            id: lessonGrid
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 20
            }
            width: rootItem.width - 40
            columns: 6
            columnSpacing: 15
            rowSpacing: 15

            Repeater {
                model: lessonManager.getLessonsCount("ru")

                Rectangle {
                    id: lessonCard
                    Layout.preferredWidth: (rootItem.width - 40 - (5 * 15)) / 6
                    Layout.preferredHeight: 150
                    color: themeManager.figure
                    radius: 8
                    border.color: themeManager.border
                    border.width: 1

                    scale: lessonMouseArea.containsMouse ? 1.05 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }

                    layer.enabled: true

                    // Верхний заголовок "АО ПЛ"
                    Rectangle {
                        id: headerRect
                        width: parent.width
                        height: 30
                        color: Qt.darker(themeManager.figure, 1.1)
                        radius: 8

                        // Убираем закругление для нижних углов
                        Rectangle {
                            width: parent.width
                            height: parent.height / 2
                            color: parent.color
                            anchors.bottom: parent.bottom
                        }

                        Text {
                            anchors.centerIn: parent
                            text: lessonManager.getLessonType("ru", index + 1)
                            font.bold: true
                            font.pixelSize: 14
                            color: themeManager.text
                        }
                    }

                    // Номер модели по центру
                    Text {
                        anchors.centerIn: parent
                        text: (index + 1)
                        font.bold: true
                        font.pixelSize: 32
                        color: themeManager.text
                    }

                    // Нижний блок с иконками
                    Rectangle {
                        id: footerRect
                        width: parent.width
                        height: 40
                        anchors.bottom: parent.bottom
                        color: Qt.darker(themeManager.figure, 1.1)
                        radius: 8

                        // Убираем закругление для верхних углов
                        Rectangle {
                            width: parent.width
                            height: parent.height / 2
                            color: parent.color
                            anchors.top: parent.top
                        }

                        // Секция для иконок и значений
                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            height: parent.height
                            color: "transparent"

                            // Иконка и значение скорости (молния) слева
                            Rectangle {
                                id: speedSection
                                width: parent.width * 0.45
                                height: 30
                                anchors {
                                    left: parent.left
                                    leftMargin: 8
                                    verticalCenter: parent.verticalCenter
                                }
                                color: Qt.rgba(1, 0.84, 0, 0.1)  // светло-золотистый фон
                                radius: 4

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Text {
                                        text: "⚡"  // Значок молнии
                                        font.pixelSize: 16
                                        color: "#FFD700"  // Золотистый цвет
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: lessonManager.getUserLessonSpeed(UserStats.getUserId(), index + 1, "ru")
                                        font.pixelSize: 14
                                        color: themeManager.text
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // Иконка и значение точности (мишень) справа
                            Rectangle {
                                id: accuracySection
                                width: parent.width * 0.45
                                height: 30
                                anchors {
                                    right: parent.right
                                    rightMargin: 8
                                    verticalCenter: parent.verticalCenter
                                }
                                color: Qt.rgba(1, 0.4, 0.28, 0.1)  // светло-красный фон
                                radius: 4

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Text {
                                        text: lessonManager.getUserLessonAccuracy(UserStats.getUserId(), index + 1, "ru")
                                        font.pixelSize: 14
                                        color: themeManager.text
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "🎯"  // Значок мишени
                                        font.pixelSize: 16
                                        color: "#FF6347"  // Томатный цвет
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: lessonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Выбран урок:", index + 1);
                            rootItem.printLessonRequested(index + 1, lessonManager.getLessonText(index + 1, "ru"), "ru");
                        }
                    }
                }
            }
        }
    }
    Setting {
        id: settingsWindow
    }
}
