#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>
#include <QRandomGenerator>

class RandomTextGenerator : public QObject {
    Q_OBJECT

public:
    explicit RandomTextGenerator(QObject* parent = nullptr);

     Q_INVOKABLE void startTest(const QString &testType,const QString& language, int wordCount, int timeLimitSeconds, bool withPunctuation, bool withNumbers);


signals:
    void textChanged(const QString& newText);

private:
    QString m_language;
    QString m_testType;
    int m_wordCount;
    int m_timeLimitSeconds;
    bool m_withNumbers;
    bool m_withPunctuation;
    QString m_text;

    void generateRandomWords();
    void generateRandomText();
};
