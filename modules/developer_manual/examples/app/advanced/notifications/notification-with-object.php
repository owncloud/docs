<?php

/** @var \OCP\Notification\INotification $notification */
$notification = $this->notificationManager->createNotification();
$action = $notification->createAction();
$action->setLabel(....)
    ->setLink(...)
$notification->setApp('customgroups')
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
    ->setLink($link)
    ->addAction($action);
$this->notificationManager->notify($notification);

