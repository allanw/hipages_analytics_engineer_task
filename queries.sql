// names and the number of messages sent by each user
SELECT
  u.Name,
  count(*) as msg_count
FROM User u
JOIN Messages msg
ON msg.UserIDSender = u.UserID
GROUP BY u.Name


// total number of messages sent stratified by weekday
SELECT
  DAYNAME(msg.DateSent),
  count(*) as send_count
FROM Messages msg
GROUP BY DAYNAME(msg.DateSent)
ORDER BY send_count DESC


// most recent message from each thread that has no response yet
// todo: test this out
WITH messages AS (
  SELECT
    FIRST_VALUE(msg.ThreadID) OVER (PARTITION BY msg.ThreadID ORDER BY msg.DateSent DESC) as thread_id,
    FIRST_VALUE(msg.MessageID) OVER (PARTITION BY msg.ThreadID ORDER BY msg.DateSent DESC) as msg_id,
    FIRST_VALUE(msg.MessageContent) OVER (PARTITION BY msg.ThreadID ORDER BY msg.DateSent DESC) as msg_content
  FROM Messages msg
),
thread_no_comments AS (
  SELECT
    ThreadID as thread_id,
  FROM Messages msg
  GROUP BY ThreadId
  HAVING COUNT(*) = 1
)
select * FROM messages m
JOIN thread_no_comments t on t.thread_id = m.thread_id


// For the conversation with the most messages: all user data and message contents ordered chronologically so one can follow the whole conversation. 
// todo: test this out
WITH conversation AS (
  SELECT
    msg.ThreadID as thread_id,
    msg.MessageID as message_id,
    msg.UserIDSender as sender_id,
    msg.UserIDRecipient as receipient_id,
    usr.UserID,
    usr.Name
  FROM Messages msg
  JOIN User usr on usr.UserID = msg.UserIDSender OR usr.UserID = msg.UserIDRecipient // use Union instead?
  ORDER BY msg.DateSent
),
conversation_most_messages AS (
  SELECT 
    msg.ThreadID as thread_id,
    count(*) as message_count
  FROM Messages msg
  GROUP BY msg.ThreadID
  ORDER BY message_count DESC
  LIMIT 1
)
SELECT * FROM conversation conv
JOIN conversation_most_messages cmm on cmm.thread_id = conv.thread_id


