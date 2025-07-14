#include "languagemanager.h"
#include <QCoreApplication>
#include <QDebug>

LanguageManager::LanguageManager(QObject *parent)
    : QObject(parent), translator(new QTranslator(this)) {
    loadLanguage("SigmaTap_ru_RU");
}

void LanguageManager::loadLanguage(const QString &languageCode) {

    qDebug() << "Вывалась смена языка на" << languageCode;
    // Удаляем старые переводы, если они существуют
    if (QCoreApplication::removeTranslator(translator)) {
        qDebug() << "Removed old translation";
    }

    // Формируем путь к файлу перевода
    QString translationFile = "./translations/" + languageCode + ".qm";
    qDebug() << "Присвоили m_currentLanguage: " << languageCode;
    m_currentLanguage = languageCode;
    // Загружаем новый перевод
    if (translator->load(translationFile)) {
        // Устанавливаем новый перевод
        QCoreApplication::installTranslator(translator);
        qDebug() << "загружен перевод с " << translationFile;
        qDebug() << "Загрузился перевод на язык: " << languageCode;
        emit languageChanged();  // Испускаем сигнал, что язык изменен
    } else {
        qDebug() << "Не получилось загрузить перевод на: " << languageCode;
    }
}

QString LanguageManager::currentLanguage()
{
    qDebug() << "вернули язык: " << m_currentLanguage;
    return m_currentLanguage;
}
