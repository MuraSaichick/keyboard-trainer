import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts

Rectangle {
    id: root
    anchors.fill: parent
    color: themeManager.background
    property var speedData: []
    property int elapsedTime: 0
    property double accuracy: 0
    property double speed: 0
    property int stability: 0
    property int lessonId
    property bool isLesson
    property string testType
    property int testDetail
    property string language
    property int keyCount: 0
    signal goHardLesson(int lessonId, string language)

    Timer {
        id: saveDelay
        interval: 0
        running: false
        repeat: false

        onTriggered: {
            calculateAverage();
            calculateTypingStability();

            if (speedData && speedData.length > 0) {
                yAxis.max = Math.max.apply(null, speedData.map(Number)) + 10;
                yAxis.min = Math.min.apply(0, speedData.map(Number)) - 10;
                console.log("Линия строится")
                for (var i = 0; i < speedData.length; i++) {
                    var x = i + 1;
                    var y = Number(speedData[i]);
                    if (!isNaN(y)) {
                        series.append(x, y);
                        scatterSeries.append(x, y);
                    } else {
                        console.warn("Некорректное значение:", speedData[i]);
                    }
                }
            } else {
                console.warn("speedData пустой");
            }

            if (isLesson) {
                UserStats.saveLessonResult(root.lessonId, root.language, root.speed, root.accuracy);
                UserStats.updateLessonLockStatus(root.lessonId,root.language);
            } else {
                UserStats.saveTestResult(root.testType, root.language, root.testDetail, root.speed, root.accuracy, root.stability);
            }
            UserStats.update_time_and_presses(root.keyCount, root.elapsedTime);
        }
    }
    property alias saveDelay: saveDelay

    SettingsButton { id: settingButton }
    AppName { id: sigmaTap }

    ChartView {
        id: chart
        anchors.top: sigmaTap.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        width: parent.width
        height: parent.height * 0.6
        antialiasing: true
        backgroundColor: themeManager.background

        legend.visible: false

        ValuesAxis {
            id: xAxis
            min: 1
            max: root.speedData.length + 1
            labelsColor: themeManager.text
            lineVisible: true
            gridVisible: true
            tickCount: max % 15
            gridLineColor: Qt.alpha(themeManager.border, 0.7)
            titleText: qsTr("Время")
            titleVisible: true
            titleFont.pixelSize: 14
            color: themeManager.text
        }

        ValuesAxis {
            id: yAxis
            min: 0
            max: 300
            labelsColor: themeManager.text
            lineVisible: true
            gridVisible: true
            tickCount: max % 15
            gridLineColor: Qt.alpha(themeManager.border, 0.7)
            titleText: qsTr("Скорость")
            titleVisible: true
            titleFont.pixelSize: 14
            color: themeManager.text
        }

        SplineSeries {
            id: series
            name: "Данные"
            axisX: xAxis
            axisY: yAxis
            color: themeManager.text
            width: 2
            pointLabelsVisible: false
        }

        SplineSeries {
            id: rawSeries
            name: "Средние Данные"
            axisX: xAxis
            axisY: yAxis
            color: themeManager.border
            width: 2
            pointLabelsVisible: false
        }

        ScatterSeries {
            id: scatterSeries
            axisX: xAxis
            axisY: yAxis
            markerSize: 6
            color: themeManager.button
            borderColor: themeManager.border
            pointLabelsVisible: false

            onHovered: (point, state) => {
                           tooltip.visible = state
                           if (state) {
                               // Обновление текста
                               tooltipSpeedText.text = qsTr("Скорость") + ": " + point.y.toFixed(1);
                               tooltipTimeText.text = qsTr("Время") + ": " + point.x;

                               // Получение позиции
                               var pos = chart.mapToPosition(point, scatterSeries);

                               // Центрирование по X и отступ вверх по Y
                               tooltip.x = Math.max(0, Math.min(chart.width - tooltip.width, pos.x - tooltip.width / 2));
                               tooltip.y = Math.max(0, pos.y - tooltip.height - 10);
                           }
                       }
        }

        Rectangle {
            id: tooltip
            width: Math.max(tooltipSpeedText.width, tooltipTimeText.width) + 5
            height: tooltipTimeText.height + tooltipSpeedText.height + 5
            color: themeManager.figure
            border.color: themeManager.border
            border.width: 1
            radius: 4
            opacity: 0.9
            visible: false
            z: 10
            Column {
            spacing: 5
            Text {
                id: tooltipSpeedText
                color: themeManager.text
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 12
            }
            Text {
                id: tooltipTimeText
                text: qsTr("Время")
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                color: themeManager.text
            }
            }
        }

    }

    // Верхняя панель с показателями
    Row {
        id: statsRow
        anchors.top: chart.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 40

        Column {
            spacing: 2
            Text {
                text: qsTr("Скорость печати")
                color: themeManager.text
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: speedValue
                text: root.speedData[root.speedData.length - 1] + " " + qsTr("зн/мин")
                color: themeManager.text
                font.bold: true
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Text {
                text: qsTr("Аккуратность")
                color: themeManager.text
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: accuracyValue
                text: root.accuracy + "%"
                color: themeManager.text
                font.bold: true
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Text {
                text: qsTr("Стаблильность")
                color: themeManager.text
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: consistency
                text: stability + "%"
                color: themeManager.text
                font.bold: true
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Text {
                text: qsTr("Время")
                color: themeManager.text
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: time
                text: root.elapsedTime
                color: themeManager.text
                font.bold: true
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    // Панель управления
    Rectangle {
        id: backgroundControlPanel
        width: parent.width * 0.4
        height: 50
        radius: width / 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: statsRow.bottom
        anchors.topMargin: height / 2

        // Полупрозрачный цвет фона панели
        color: Qt.alpha(themeManager.figure, 0.6)
        border.color: Qt.alpha(themeManager.border, 0.5)
        border.width: 1

        Row {
            spacing: 40
            anchors.centerIn: parent
            // Кнопка: Заново (иконка в виде круговой стрелки)
            Rectangle {
                id: restartWord
                width: 40
                height: width
                color: themeManager.button
                radius: 5
                border.color: themeManager.border

                Text {
                    anchors.centerIn: parent
                    text: "\u21bb" // Unicode символ: ↻
                    font.pixelSize: 28
                    color: themeManager.text
                }

                MouseArea {
                    id: areaRestart
                    anchors.fill: parent
                    hoverEnabled: true

                    Rectangle {
                        visible: areaRestart.containsMouse
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: againText.width + 10
                        height: 30
                        color: themeManager.figure
                        border.color: themeManager.border
                        radius: 5
                        Text {
                            id: againText
                            anchors.centerIn: parent
                            text: qsTr("Повторить текст")
                            color: themeManager.text
                            font.pixelSize: 14
                        }
                    }

                    onClicked: {
                        root.isLesson ? goHardLesson(lessonId, root.language) : pageLoader.source = "TypingTrainerTest.qml"
                    }
                }
            }

            // Кнопка: Новый текст (иконка в виде карандаша)
            Rectangle {
                width: restartWord.width
                height: width
                color: themeManager.button
                radius: 5
                border.color: themeManager.border

                Text {
                    anchors.centerIn: parent
                    text: "\u270E" // ✎
                    font.pixelSize: 28
                    color: themeManager.text
                }

                MouseArea {
                    id: areaNewText
                    anchors.fill: parent
                    hoverEnabled: true

                    Rectangle {
                        visible: areaNewText.containsMouse
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: newText.width + 10
                        height: 30
                        color: themeManager.figure
                        border.color: themeManager.border
                        radius: 5
                        Text {
                            id: newText
                            anchors.centerIn: parent
                            text: qsTr("Следующий текст")
                            color: themeManager.text
                            font.pixelSize: 14
                        }
                    }

                    onClicked: {
                        root.isLesson ? goHardLesson(lessonId + 1, root.language) : pageLoader.source = "TypingTrainerTest.qml"
                    }
                }
            }

            // Кнопка: Главное меню (иконка домика)
            Rectangle {
                width: restartWord.width
                height: width
                color: themeManager.button
                radius: 5
                border.color: themeManager.border

                Text {
                    anchors.centerIn: parent
                    text: "\u2302" // ⌂
                    font.pixelSize: 28
                    color: themeManager.text
                }

                MouseArea {
                    id: areaMainMenu
                    anchors.fill: parent
                    hoverEnabled: true

                    Rectangle {
                        visible: areaMainMenu.containsMouse
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: mainMenu.width + 10
                        height: 30
                        color: themeManager.figure
                        border.color: themeManager.border
                        radius: 5
                        Text {
                            id: mainMenu
                            anchors.centerIn: parent
                            text: qsTr("Главное меню")
                            color: themeManager.text
                            font.pixelSize: 14
                        }
                    }

                    onClicked: {
                        pageLoader.source = "MainMenu.qml"
                    }
                }
            }
        }
    }
    Setting { id: settingsWindow }

    function calculateAverage() {
        for (var i = 0; i < root.speedData.length; i++) {
            root.speed += root.speedData[i]
        }
        var average = (root.speedData.length > 0) ? root.speed / root.speedData.length : 0;
        root.speed = average.toFixed(1) // Округляем до 2 знаков после запятой
    }
    function calculateTypingStability() {
        if(speedData.length == 0) {
            return 0;
        }
        const variance = speedData.reduce((sum,val) => sum + Math.pow(val - speed, 2), 0) / speedData.length;
        const stdDev = Math.sqrt(variance);
        const cv = (stdDev / speed) * 100;
        root.stability = Math.max(0, 100 - cv);
    }

}
