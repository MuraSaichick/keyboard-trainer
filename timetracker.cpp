#include "TimeTracker.h"

TimeTracker::TimeTracker(QObject* parent)
    : QObject(parent),
    m_elapsedTime(0),
    m_remainingTime(0),
    m_isTimer(false),
    m_timerStarted(false)
{
    m_timer.setInterval(1000); // 1 секунда
    connect(&m_timer, &QTimer::timeout, this, &TimeTracker::onTimeout);
    m_keyboardHandler = nullptr;
}

void TimeTracker::setIsTimer(bool isTimer)
{
    if(m_isTimer == isTimer) {
        return;
    }
    m_isTimer = isTimer;
}

void TimeTracker::setKeyboardHandler(KeyboardHandler *keyboardHandler)
{
    if(m_keyboardHandler &&  m_keyboardHandler != keyboardHandler) {
        delete m_keyboardHandler;
    }
    if(m_keyboardHandler == keyboardHandler) {
        return;
    }
    m_keyboardHandler = keyboardHandler;
}

int TimeTracker::getTime()
{
    return m_elapsedTime;
}

QList<double> TimeTracker::getListSpeed()
{
    return m_speedLog;
}

void TimeTracker::start(int endTime)
{
    if(m_timerStarted) {
        return;
    }
    m_elapsedTime = 0;
    m_speedLog.clear();
    if (m_isTimer) {
        m_remainingTime = endTime;
        emit timeChanged(m_remainingTime);
    } else {
        emit timeChanged(m_elapsedTime);
    }
    m_timer.start();
    m_timerStarted = true;
}

void TimeTracker::stop()
{
    m_timer.stop();
    m_timerStarted = false;
}

void TimeTracker::reset()
{
    stop();
    m_elapsedTime = 0;
    m_remainingTime = 0;
    emit timeChanged(0);
}

void TimeTracker::onTimeout()
{
    m_elapsedTime++;
    m_speed = static_cast<double>(m_keyboardHandler->getCorrectKeyCount()) / static_cast<double>(m_elapsedTime) * 60.0;
    m_speed = std::floor(m_speed * 10) / 10.0;
    m_speedLog.push_back(m_speed);
    if (m_isTimer) {
        if (m_remainingTime > 0) {
            m_remainingTime--;
            emit timeChanged(m_remainingTime);
            if (m_remainingTime == 0) {
                m_timer.stop();
                m_timerStarted = false;
                emit timerFinished();
            }
        }
    } else {
        emit timeChanged(m_elapsedTime);
    }
}


