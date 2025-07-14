#include "LessonManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

LessonManager::LessonManager(QObject *parent)
    : QObject(parent)
{
    connectToDatabase();
}

bool LessonManager::connectToDatabase()
{
    if (QSqlDatabase::contains("qt_sql_default_connection")) {
        m_db = QSqlDatabase::database("qt_sql_default_connection");
        qDebug() << "подключились стандартно";
    } else {
        m_db = QSqlDatabase::addDatabase("QSQLITE");
        m_db.setDatabaseName("./Assets/database/UsersDB.db");  // указание относительного пути
        qDebug() << "подключились по пути";
    }

    if (!m_db.open()) {
        qWarning() << "Не удалось подключится к базе данных:" << m_db.lastError().text();
        return false;
    }
    return true;
}

int LessonManager::getLessonsCount(const QString& language)
{
    QString table = (language == "ru" ? "russian" : "english");
    table += "_lessons";
    QString sql = QString("SELECT COUNT(id) FROM %1").arg(table);
    QSqlQuery query(sql);

    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }
    qWarning() << "Не удалось получить количество уроков:" << query.lastError().text();

    return 0;
}

double LessonManager::getUserLessonSpeed(int userId, int lessonId, const QString& language) {
    QSqlQuery query;

    QString tableName = "UserLessons_" + language.toUpper();

    QString sql = QString("SELECT speed FROM %1 WHERE user_id = ? AND lesson_id = ?").arg(tableName);

    query.prepare(sql);
    query.addBindValue(userId);
    query.addBindValue(lessonId);

    if (query.exec() && query.next()) {
        return query.value(0).toDouble();
    }
    return -1;  // или другой дефолт
}

double LessonManager::getUserLessonAccuracy(int userId, int lessonId, const QString& language) {
    QSqlQuery query;

    QString tableName = "UserLessons_" + language.toUpper();

    QString sql = QString("SELECT accuracy FROM %1 WHERE user_id = ? AND lesson_id = ?").arg(tableName);
    query.prepare(sql);
    query.addBindValue(userId);
    query.addBindValue(lessonId);

    if (query.exec() && query.next()) {
        return query.value(0).toDouble();
    }
    return -1;  // или другой дефолт
}

QString LessonManager::getLessonText(int lessonId, const QString& language) {
    QSqlQuery query;
    qDebug() << "language: " << language;
    QString tableName;
    if (language == "ru") {
        tableName = "russian_lessons";
    } else if (language == "en") {
        tableName = "english_lessons";
    } else {
        qWarning() << "Неизвестный язык:" << language;
        return "Ошибка: неизвестный язык";
    }

    QString sql = QString("SELECT lesson_text FROM %1 WHERE id = ?").arg(tableName);
    query.prepare(sql);
    query.addBindValue(lessonId);

    if (query.exec() && query.next()) {
        return query.value(0).toString();
    }

    qWarning() << "Не удалось получить текст урока. Ошибка:" << query.lastError().text();
    return "Ошибка";  // или можно вернуть "Ошибка" / "---" и т.д.
}

QString LessonManager::getLessonType(const QString &language, int lessonId) {
    QSqlQuery query;

    QString tableName;
    if (language == "ru") {
        tableName = "russian_lessons";
    } else if (language == "en") {
        tableName = "english_lessons";
    } else {
        qWarning() << "Неизвестный язык:" << language;
        return "Ошибка: неизвестный язык";
    }

    QString sql = QString("SELECT lesson_type FROM %1 WHERE id = ?").arg(tableName);
    query.prepare(sql);
    query.addBindValue(lessonId);

    if (query.exec() && query.next()) {
        return query.value(0).toString();
    }

    qWarning() << "Не удалось получить текст урока. Ошибка:" << query.lastError().text();
    return "Ошибка: не найден урок";
}



