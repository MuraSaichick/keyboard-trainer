import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material 2.15  // если используешь Material, опционально


Window {
    id: root
    visible: false
    height: 700
    width: 1000
    minimumHeight: 700
    minimumWidth: 1000

    title: qsTr("Клавиатурный тренажёр") + " SigmaTap"

    Loader {
        id: pageLoader
        anchors.fill: parent
        onLoaded: {
            console.log("Page загрузился с themeManager:", themeManager)
            if (pageLoader.item.finishedTest) {
                pageLoader.item.finishedTest.connect(function(list, time, accuracy, testType, detail,language, keyCount) {
                    pageLoader.sourceComponent = null
                    pageLoader.source = "TypingResults.qml"

                    // Задержка до конца текущего кадра, чтобы подождать загрузку
                    Qt.callLater(function() {
                        if (pageLoader.item) {
                            pageLoader.item.speedData = list
                            pageLoader.item.elapsedTime = time
                            pageLoader.item.accuracy = accuracy
                            pageLoader.item.isLesson = false
                            pageLoader.item.testType = testType
                            pageLoader.item.testDetail = detail
                            pageLoader.item.language = language
                            pageLoader.item.keyCount = keyCount
                            pageLoader.item.saveDelay.start()
                            console.log("Время: ", time)
                        }
                    })
                })
            }
            else if(pageLoader.item.printLessonRequested) {
                pageLoader.item.printLessonRequested.connect(function(idLesson, textLesson, language) {
                    pageLoader.sourceComponent = null
                    pageLoader.source = "TypingLesson.qml"
                    Qt.callLater(function() {
                        if (pageLoader.item) {
                            pageLoader.item.lessonId = idLesson
                            pageLoader.item.lessonText = textLesson
                            pageLoader.item.language = language
                            console.log("Передали id и текст урока:" , idLesson, textLesson);
                        }
                    })
                })
            }
            else if(pageLoader.item.finishedLesson) {
                pageLoader.item.finishedLesson.connect(function(list, time, accuracy, id, language, keyCount) {
                    pageLoader.sourceComponent = null
                    console.log("Приняли сигнал и загружаем результат")
                    pageLoader.source = "TypingResults.qml"

                    // Задержка до конца текущего кадра, чтобы подождать загрузку
                    Qt.callLater(function() {
                        if (pageLoader.item) {
                            pageLoader.item.speedData = list
                            pageLoader.item.elapsedTime = time
                            pageLoader.item.accuracy = accuracy
                            pageLoader.item.lessonId = id
                            pageLoader.item.isLesson = true
                            pageLoader.item.language = language
                            pageLoader.item.keyCount = keyCount
                            pageLoader.item.saveDelay.start()
                            console.log("Время: ", time)
                        }
                    })
                })
            }
            else if(pageLoader.item.goHardLesson) {
                pageLoader.item.goHardLesson.connect(function(id, language) {
                    pageLoader.sourceComponent = null
                    pageLoader.source = "TypingLesson.qml"
                    Qt.callLater(function() {
                        if (pageLoader.item) {

                            pageLoader.item.language = language
                            pageLoader.item.lessonId = id
                            console.log("Передали id урока:" , id);
                        }
                    })
                })
            }
        }
    }
    Component.onCompleted: {
        if (UserStats.findUserIdBySessionId()) {
            pageLoader.source = "MainMenu.qml"
        } else {
            pageLoader.source = "LoginScreen.qml"
        }
        root.visible = true
    }

    function switchToMenu() {
        visibility = Window.FullScreen
        pageLoader.source = "MainMenu.qml"
    }

}
