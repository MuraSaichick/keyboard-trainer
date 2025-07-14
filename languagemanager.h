#ifndef LANGUAGEMANAGER_H
#define LANGUAGEMANAGER_H

#include <QObject>
#include <QTranslator>
#include <QString>

class LanguageManager : public QObject {
    Q_OBJECT
public:
    explicit LanguageManager(QObject *parent = nullptr);

    // Слот для смены языка
public slots:
    void loadLanguage(const QString &languageCode);  // Слот для загрузки языка
    QString currentLanguage();

signals:
    void languageChanged();  // Сигнал, который испускается при смене языка

private:
    QTranslator *translator;  // Объект для работы с переводами
    QString m_currentLanguage;
};


#endif // LANGUAGEMANAGER_H
