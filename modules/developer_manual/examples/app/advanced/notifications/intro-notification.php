<?php

/** @var \OCP\Notification\INotification $notification */
$notification = $this->notificationManager->createNotification();

// Populate the notification object
$notification
    ->setApp('customgroups')
    ->setDateTime(new \DateTime())
    ->setObject(
        'customgroup',
        $memberInfo['group_id']
    )
    ->setSubject(
        'changed_member_role',
        [
            $user->getDisplayName(),
            $groupInfo['display_name'],
            $memberInfo['role']
        ]
    )
    ->setMessage(
        'changed_member_role',
        [
            $user->getDisplayName(),
            $groupInfo['display_name'],
            $memberInfo['role']
        ]
    )
    ->setUser($targetUserId)
    ->setLink($link);

// Send the notification
$this->notificationManager->notify($notification);
