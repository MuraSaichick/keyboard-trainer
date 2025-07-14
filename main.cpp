#include <QApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>


#include "thememanager.h"
#include "languagemanager.h"
#include "windowmanager.h"
#include "authmanager.h"
#include "userstatsmanager.h"
#include "randomtextgenerator.h"
#include "keyboardhandler.h"
#include "timetracker.h"
#include "lessonmanager.h"

/*
 * Отче наш, Иже еси на небесех!
Да святится имя Твое,
да приидет Царствие Твое,
да будет воля Твоя,
яко на небеси и на земли.
Хлеб наш насущный даждь нам днесь;
и остави нам долги наша,
якоже и мы оставляем должником нашим;
и не введи нас во искушение,
но избави нас от лукаваго.
 */

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // Устанавливаем стиль для приложения
    QQuickStyle::setStyle("Fusion");  // Используем стиль Fusion

    qmlRegisterType<AuthManager>("AuthManager", 1,0, "AuthManager");
    qmlRegisterType<RandomTextGenerator>("RandText", 1,0, "RandText");
    qmlRegisterType<KeyboardHandler>("KeyboardHandler", 1,0, "KeyboardHandler");
    qmlRegisterType<TimeTracker>("TimeTracker", 1,0, "TimeTracker");
    qmlRegisterType<LessonManager>("LessonManager",1,0, "LessonManager");

    QQmlApplicationEngine engine;

    ThemeManager themeManager;
    LanguageManager languageManager;
    WindowManager windowManager;
    UserStatsManager userStatManager;

    engine.rootContext()->setContextProperty("windowManager", &windowManager);
    engine.rootContext()->setContextProperty("themeManager", &themeManager);
    engine.rootContext()->setContextProperty("languageManager", &languageManager);
    engine.rootContext()->setContextProperty("UserStats", &userStatManager);

    QObject::connect(&languageManager, &LanguageManager::languageChanged, [&engine]() {
        qDebug() << "Перевод должен измениться";
        engine.retranslate();
        qDebug() << "retranslate() выполнен";
    });


    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("SigmaTap", "Main");

    if (!engine.rootObjects().isEmpty()) {
        QObject *rootObject = engine.rootObjects().first();
        QQuickWindow *window = qobject_cast<QQuickWindow *>(rootObject);
        if (window) {
            windowManager.setWindow(window);
        }
    }

    return app.exec();
}
