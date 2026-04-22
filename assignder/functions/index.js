const admin = require("firebase-admin");
const {logger} = require("firebase-functions");
const {setGlobalOptions} = require("firebase-functions/v2");
const {onSchedule} = require("firebase-functions/v2/scheduler");

admin.initializeApp();
setGlobalOptions({region: "asia-southeast1", maxInstances: 1});

const db = admin.firestore();
const messaging = admin.messaging();

const SCHEDULE_TIME_ZONE = "Asia/Bangkok";
const REMINDER_WINDOW_MS = 15 * 60 * 1000;
const MAX_REMINDER_OFFSET_MS = 7 * 24 * 60 * 60 * 1000;

const REMINDER_OFFSETS = {
  "1_week_before": 7 * 24 * 60 * 60 * 1000,
  "3_days_before": 3 * 24 * 60 * 60 * 1000,
  "24h_before": 24 * 60 * 60 * 1000,
  "2h_before": 2 * 60 * 60 * 1000,
  "1h_before": 60 * 60 * 1000,
  "30m_before": 30 * 60 * 1000,
};

function getReminderLabel(offset) {
  switch (offset) {
    case "1_week_before":
      return "1 week";
    case "3_days_before":
      return "3 days";
    case "24h_before":
      return "24 hours";
    case "2h_before":
      return "2 hours";
    case "1h_before":
      return "1 hour";
    case "30m_before":
      return "30 minutes";
    default:
      return "soon";
  }
}

function shouldSendReminder(dueDate, offset, nowMs) {
  const offsetMs = REMINDER_OFFSETS[offset];
  if (!offsetMs) return false;

  const reminderAtMs = dueDate.getTime() - offsetMs;
  return (
    reminderAtMs <= nowMs &&
    reminderAtMs > nowMs - REMINDER_WINDOW_MS
  );
}

exports.sendAssignmentReminders = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: SCHEDULE_TIME_ZONE,
    retryCount: 0,
  },
  async () => {
    const nowMs = Date.now();
    const earliestDueDate = new Date(nowMs);
    const latestDueDate = new Date(
      nowMs + MAX_REMINDER_OFFSET_MS + REMINDER_WINDOW_MS,
    );

    const assignmentsSnapshot = await db
      .collectionGroup("assignments")
      .where("status", "==", "pending")
      .where("dueDate", ">=", earliestDueDate)
      .where("dueDate", "<=", latestDueDate)
      .get();

    logger.info(
      `Checking ${assignmentsSnapshot.size} assignments for reminder pushes.`,
    );

    for (const assignmentDoc of assignmentsSnapshot.docs) {
      const assignment = assignmentDoc.data();
      const reminder = assignment.reminder || {};
      const offsets = Array.isArray(reminder.offsets) ? reminder.offsets : [];
      const sentOffsets = Array.isArray(assignment.sentReminderOffsets)
        ? assignment.sentReminderOffsets
        : [];

      if (!reminder.enabled || offsets.length === 0 || !assignment.dueDate) {
        continue;
      }

      const dueDate = assignment.dueDate.toDate();
      const dueOffsets = offsets.filter(
        (offset) =>
          !sentOffsets.includes(offset) &&
          shouldSendReminder(dueDate, offset, nowMs),
      );

      if (dueOffsets.length === 0) {
        continue;
      }

      const userRef = assignmentDoc.ref.parent.parent;
      if (!userRef) {
        logger.warn(`Assignment ${assignmentDoc.id} has no parent user ref.`);
        continue;
      }

      const userSnapshot = await userRef.get();
      const deviceTokens = Array.isArray(userSnapshot.get("deviceTokens"))
        ? userSnapshot.get("deviceTokens")
        : [];

      if (deviceTokens.length === 0) {
        logger.info(
          `Skipping ${assignmentDoc.id}; user ${userRef.id} has no device tokens.`,
        );
        continue;
      }

      const primaryOffset = dueOffsets[0];
      const label = getReminderLabel(primaryOffset);
      const response = await messaging.sendEachForMulticast({
        tokens: deviceTokens,
        notification: {
          title: "Assignment Due Soon!",
          body: `${assignment.title} is due in ${label}.`,
        },
        data: {
          assignmentId: assignmentDoc.id,
          userId: userRef.id,
          reminderOffset: primaryOffset,
          reminderType: "assignment_reminder",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "assignment_reminders",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          headers: {
            "apns-priority": "10",
          },
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      });

      const invalidTokens = [];
      response.responses.forEach((result, index) => {
        if (!result.success) {
          const code = result.error?.code || "unknown";
          logger.warn(
            `Failed to send token ${index} for ${assignmentDoc.id}: ${code}`,
          );
          if (
            code === "messaging/invalid-registration-token" ||
            code === "messaging/registration-token-not-registered"
          ) {
            invalidTokens.push(deviceTokens[index]);
          }
        }
      });

      if (invalidTokens.length > 0) {
        await userRef.set(
          {
            deviceTokens: admin.firestore.FieldValue.arrayRemove(
              ...invalidTokens,
            ),
          },
          {merge: true},
        );
      }

      if (response.successCount > 0) {
        await assignmentDoc.ref.set(
          {
            sentReminderOffsets: admin.firestore.FieldValue.arrayUnion(
              ...dueOffsets,
            ),
            lastReminderSentAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true},
        );
      }
    }
  },
);
