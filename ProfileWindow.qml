import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform


ApplicationWindow {
    id: profileWindow
    width: 915
    height: 700
    minimumHeight: 700
    minimumWidth: 915
    maximumHeight: 700
    maximumWidth: 915
    visible: false
    title: "SigmaTap - " + qsTr("Профиль")

    property string selectedLanguage: "ru"

    Rectangle {
        anchors.fill: parent
        color: themeManager.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            clip: false

            // Заголовок профиля
            Rectangle {
                Layout.fillWidth: true
                height: 100
                color: themeManager.inputBackground
                radius: 15
                border.color: themeManager.border
                border.width: 1

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    spacing: 20

                    // Аватар
                    Rectangle {
                        id: avatarRect
                        width: 50
                        height: 50
                        radius: 25
                        color: themeManager.highlight
                        clip: true

                        property url avatarSource: ""  // путь к выбранной аватарке
                        property string userInitial: login.text.length > 0 ? login.text[0] : "U"

                        FileDialog {
                            id: fileDialog
                            title: "Выберите фотографию"
                            nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp)"]
                            onAccepted: {
                                console.log("Выбран файл:", fileDialog.file)
                                avatarRect.avatarSource = fileDialog.file
                            }
                        }

                        // Вложенный прямоугольник для обрезки Image по кругу
                        Rectangle {
                            anchors.fill: parent
                            radius: avatarRect.radius
                            clip: true
                            color: "transparent"  // чтоб не перекрывать

                            Image {
                                id: avatarImage
                                anchors.fill: parent
                                source: avatarRect.avatarSource
                                visible: avatarRect.avatarSource !== ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }
                        }

                        Text {
                            id: userInitialText
                            anchors.centerIn: parent
                            text: avatarRect.userInitial
                            color: themeManager.text
                            font.pixelSize: 20
                            font.bold: true
                            visible: avatarRect.avatarSource.toString() === ""
                        }

                        Rectangle {
                            id: overlay
                            anchors.fill: parent
                            color: mouseArea.containsMouse && avatarRect.avatarSource !== "" ? "#80000000" : "transparent"
                            visible: mouseArea.containsMouse && avatarRect.avatarSource !== ""
                            radius: 25
                        }

                        Text {
                            id: plusIcon
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 24
                            font.bold: true
                            color: themeManager.highlightedText
                            visible: mouseArea.containsMouse
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: fileDialog.open()
                        }
                    }

                    // Информация о пользователе
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            id: login
                            text: UserStats.login
                            font.pixelSize: 20
                            font.bold: true
                            color: themeManager.text
                        }

                        Text {
                            text: qsTr("ID") + ": " + UserStats.getUserId()
                            font.pixelSize: 14
                            color: themeManager.placeHolderText
                        }
                        Text {
                            id: registrationDate
                            text: qsTr("Дата регистрации") + ": " + UserStats.getRegistrationDate();
                            font.pixelSize: 14;
                            color: themeManager.text
                        }
                    }
                }
                // Выбор языка
                SettingItem {
                    id: languageItem
                    width: 100
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 50
                    height: 50
                    iconText: "🌐"
                    settingText: qsTr("Язык")

                    ComboBox {
                        id: languageComboBox
                        width: 140
                        height: 36
                        font.pixelSize: 15
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        onCurrentIndexChanged: {
                            if(currentIndex) {
                                profileWindow.selectedLanguage = "en";
                            } else {
                                profileWindow.selectedLanguage = "ru";
                            }
                        }


                        background: Rectangle {
                            color: themeManager.inputBackground
                            radius: 8
                            border.color: languageComboBox.hovered ? themeManager.buttonHoverColor : themeManager.border
                            border.width: languageComboBox.hovered ? 2 : 1

                            Behavior on border.color {
                                ColorAnimation { duration: 150 }
                            }

                            Behavior on border.width {
                                NumberAnimation { duration: 150 }
                            }
                        }

                        contentItem: Text {
                            text: languageComboBox.currentText
                            font.pixelSize: 15
                            color: themeManager.inputTextColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        indicator: Text {
                            text: "▼"
                            font.pixelSize: 12
                            color: themeManager.text
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        model: [qsTr("Русский"), qsTr("Английский")]
                        currentIndex: 0
                        delegate: ItemDelegate {
                            width: parent.width
                            height: 36

                            background: Rectangle {
                                color: highlighted ? themeManager.button : themeManager.background
                                radius: 5
                                border.color: themeManager.border
                                border.width: 1
                            }

                            contentItem: Text {
                                text: modelData
                                font.pixelSize: 14
                                color: themeManager.text
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        popup: Popup {
                            y: languageComboBox.height
                            width: languageComboBox.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 1

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: languageComboBox.popup.visible ? languageComboBox.delegateModel : null
                                currentIndex: languageComboBox.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                color: themeManager.background
                                radius: 8
                                border.color: themeManager.border
                                border.width: 1
                            }

                            enter: Transition {
                                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
                            }

                            exit: Transition {
                                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
                            }
                        }
                    }
                }
            }

            // Основной контент
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    width: parent.width
                    spacing: 25

                    // Тесты на слова
                    TestTypeSection {
                        title: qsTr("Тесты на слова")
                        icon: "📝"
                        testType: "words"
                        testData: [
                            { mode: "10", speed: "85", accuracy: "96.2%", maxSpeed: "92", stability: "87%" },
                            { mode: "25", speed: "78", accuracy: "94.8%", maxSpeed: "86", stability: "82%" },
                            { mode: "50", speed: "72", accuracy: "93.1%", maxSpeed: "81", stability: "78%" },
                            { mode: "100", speed: "68", accuracy: "91.5%", maxSpeed: "76", stability: "74%" }
                        ]
                    }

                    // Тесты на время
                    TestTypeSection {
                        title: qsTr("Тесты на время")
                        icon: "⏱️"
                        testType: "time"
                        testData: [
                            { mode: "15", speed: "92", accuracy: "97.1%", maxSpeed: "105", stability: "89%" },
                            { mode: "30", speed: "87", accuracy: "95.6%", maxSpeed: "98", stability: "85%" },
                            { mode: "60", speed: "81", accuracy: "94.2%", maxSpeed: "93", stability: "81%" },
                            { mode: "120", speed: "75", accuracy: "92.8%", maxSpeed: "87", stability: "77%" }
                        ]
                    }

                    // Тесты на текст
                    TestTypeSection {
                        title: qsTr("Тесты на текст")
                        icon: "📄"
                        testType: "text"
                        testData: [
                            { mode: "60", speed: "79", accuracy: "96.5%", maxSpeed: "89", stability: "83%" },
                            { mode: "120", speed: "76", accuracy: "94.8%", maxSpeed: "85", stability: "79%" },
                            { mode: "180", speed: "73", accuracy: "93.2%", maxSpeed: "82", stability: "76%" },
                            { mode: "300", speed: "70", accuracy: "91.7%", maxSpeed: "78", stability: "73%" }
                        ]
                    }

                    // Общая статистика
                    StatsSection {
                        id: overallStats
                        title: qsTr("Общая статистика")
                        icon: "📊"
                        property var results: UserStats.getBasicProfileStats()
                        GridLayout {
                            columns: 3
                            columnSpacing: 15
                            rowSpacing: 15
                            Layout.fillWidth: true

                            BigStatCard {
                                title: qsTr("Всего нажато клавиш")
                                value: overallStats.results.totalKeystrokes
                                icon: "⌨️"
                            }

                            BigStatCard {
                                title: qsTr("Всего пройдено тестов")
                                value: overallStats.results.totalTestsTaken
                                icon: "📝"
                            }
                            BigStatCard {
                                title: qsTr("Общее время печати")
                                value: overallStats.results.totalTypingTime + " " + qsTr("сек")
                                icon: "⏳"
                            }
                        }
                    }

                    // Уроки
                    StatsSection {
                        id: lessons
                        title: qsTr("Прогресс уроков")
                        icon: "📚"
                        property var resultLessons: UserStats.getLessonProgress(profileWindow.selectedLanguage)

                        Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            color: themeManager.inputBackground
                            radius: 10
                            border.color: themeManager.border
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: "📖"
                                    font.pixelSize: 32
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    RowLayout {
                                        Text {
                                            text: qsTr("Пройдено уроков") + ":"
                                            font.pixelSize: 14
                                            color: themeManager.text
                                        }

                                        Text {
                                            text: lessons.resultLessons.finishedLessons + " " + qsTr("из") + " " + lessons.resultLessons.allLessons
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: themeManager.highlight
                                        }
                                    }
                                    ProgressBar {
                                        id: control
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 1
                                        value: lessons.resultLessons.lessonCompletionPercent
                                        padding: 2

                                        background: Rectangle {
                                            radius: 8
                                            color: themeManager.border
                                        }

                                        contentItem: Item {
                                            anchors.fill: parent
                                            implicitHeight: 4   // чуть тоньше заливка, как в примере выше

                                            Rectangle {
                                                width: parent.width * control.visualPosition
                                                height: parent.height
                                                radius: 8
                                                color: themeManager.highlight
                                                visible: true
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: (lessons.resultLessons.lessonCompletionPercent * 100).toFixed(2)+ "%"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: themeManager.highlight
                                }
                            }
                        }
                    }
                }
            }

            // Кнопка выхода
            Rectangle {
                id: escapeButton
                width: escapeButtonText.width + 20
                height: 50
                color: themeManager.button
                radius: 10
                border.color: themeManager.border
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: parent.color = themeManager.buttonHoverColor
                    onExited: parent.color = themeManager.button

                    onClicked: {
                        console.log("Выход из аккаунта")
                        UserStats.logout();
                        pageLoader.source = "LoginScreen.qml"
                    }
                }

                Text {
                    id: escapeButtonText
                    anchors.centerIn: parent
                    text: "🚪 " + qsTr("Выйти из аккаунта")
                    font.pixelSize: 16
                    color: themeManager.text
                }
            }
        }
    }

    // Компонент секции с типами тестов
    component TestTypeSection: ColumnLayout {
        property string title
        property string icon
        property string testType
        property var testData: []

        spacing: 15
        Layout.fillWidth: true

        // Заголовок секции
        RowLayout {
            spacing: 10

            Text {
                text: parent.parent.icon
                font.pixelSize: 24
            }

            Text {
                text: parent.parent.title
                font.pixelSize: 18
                font.bold: true
                color: themeManager.text
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: themeManager.border
            }
        }

        // Сетка карточек тестов
        GridLayout {
            columns: 4
            columnSpacing: 15
            rowSpacing: 10
            Layout.fillWidth: true

            Repeater {
                model: testData

                TestCard {
                    testMode: modelData.mode
                    property var testInfo: UserStats.getAverageTestResult(testType, profileWindow.selectedLanguage, testMode)
                    speed: testInfo.speed
                    accuracy: testInfo.accuracy
                    maxSpeed: testInfo.maxSpeed
                    stability: testInfo.consistency
                }
            }
        }
    }

    // Компонент карточки теста
    component TestCard: Rectangle {
        property string testMode
        property double speed
        property double accuracy
        property double maxSpeed
        property double stability

        Layout.preferredWidth: 200
        Layout.preferredHeight: 80
        color: themeManager.inputBackground
        radius: 10
        border.color: themeManager.border
        border.width: 1

        MouseArea {
            id: cardMouseArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                globalHoverInfo.showForCard(parent, cardMouseArea)
            }

            onExited: {
                globalHoverInfo.hide()
            }

            onPositionChanged: {
                if (containsMouse) {
                    globalHoverInfo.showForCard(parent, cardMouseArea)
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: speed + " " + qsTr("зн/мин")
                font.pixelSize: 20
                font.bold: true
                color: themeManager.highlight
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: testMode
                font.pixelSize: 12
                color: themeManager.placeHolderText
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Компонент секции статистики
    component StatsSection: ColumnLayout {
        property string title
        property string icon

        spacing: 15
        Layout.fillWidth: true

        // Заголовок секции
        RowLayout {
            spacing: 10

            Text {
                text: parent.parent.icon
                font.pixelSize: 24
            }

            Text {
                text: parent.parent.title
                font.pixelSize: 18
                font.bold: true
                color: themeManager.text
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: themeManager.border
            }
        }
    }

    // Компонент большой карточки статистики
    component BigStatCard: Rectangle {
        property string title
        property string value
        property string icon

        Layout.fillWidth: true
        Layout.preferredHeight: 100
        color: themeManager.inputBackground
        radius: 10
        border.color: themeManager.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Text {
                text: parent.parent.icon
                font.pixelSize: 40
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: parent.parent.parent.value
                    font.pixelSize: 28
                    font.bold: true
                    color: themeManager.highlight
                }

                Text {
                    text: parent.parent.parent.title
                    font.pixelSize: 14
                    color: themeManager.text
                }
            }
        }
    }

    // смена языка
    component SettingItem: Item {
        property string iconText: ""
        property string settingText: ""
        height: 50
        width: implicitWidth

        Row {
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: iconBg
                width: 36
                height: 36
                radius: 8
                color: themeManager.button
                opacity: 0.8

                Text {
                    anchors.centerIn: parent
                    text: iconText
                    font.pixelSize: 18
                }
            }

            Text {
                id: settingLabel
                text: settingText
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                font.family: "Arial"
                color: themeManager.text
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Крч вслыпающее окно
    Rectangle {
        id: globalHoverInfo
        width: 220
        height: 120
        color: themeManager.background
        radius: 10
        border.color: themeManager.border
        border.width: 1
        visible: false
        z: 10 // Максимальный z-order

        property var currentCard: null

        function showForCard(card, mouseArea) {
            if (!card) return

            currentCard = card
            visible = true

            // Получаем глобальные координаты карточки
            var globalPos = mouseArea.mapToItem(profileWindow.contentItem, 0, 0)

            // Позиционируем tooltip над карточкой
            x = globalPos.x + (mouseArea.width - width) / 2
            y = globalPos.y - height - 8

            // Проверяем границы окна и корректируем позицию
            if (x < 10) x = 10
            if (x + width > profileWindow.width - 10) x = profileWindow.width - width - 10
            if (y < 10) y = globalPos.y + mouseArea.height + 10
        }

        function hide() {
            visible = false
            currentCard = null
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8

            Text {
                text: "📊 " + qsTr("Подробная статистика")
                font.pixelSize: 13
                font.bold: true
                color: themeManager.text
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: themeManager.border
            }

            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 5
                Layout.fillWidth: true

                Text {
                    text: qsTr("Точность") + ":"
                    font.pixelSize: 11
                    color: themeManager.placeHolderText
                }
                Text {
                    text: globalHoverInfo.currentCard ? globalHoverInfo.currentCard.accuracy + "%" : ""
                    font.pixelSize: 11
                    color: themeManager.text
                    font.bold: true
                }

                Text {
                    text: qsTr("Макс. скорость") + ":"
                    font.pixelSize: 11
                    color: themeManager.placeHolderText
                }
                Text {
                    text: globalHoverInfo.currentCard ? globalHoverInfo.currentCard.maxSpeed + " " + qsTr("зн/мин") : ""
                    font.pixelSize: 11
                    color: themeManager.text
                    font.bold: true
                }

                Text {
                    text: qsTr("Стабильность") + ":"
                    font.pixelSize: 11
                    color: themeManager.placeHolderText
                }
                Text {
                    text: globalHoverInfo.currentCard ? globalHoverInfo.currentCard.stability + "%" : ""
                    font.pixelSize: 11
                    color: themeManager.text
                    font.bold: true
                }
            }
        }
        Rectangle {
            width: 10
            height: 10
            color: themeManager.background
            border.color: themeManager.border
            border.width: 1
            rotation: 45
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -5
        }
    }
}
