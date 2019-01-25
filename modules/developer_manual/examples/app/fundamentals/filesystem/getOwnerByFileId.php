<?php

$mountCache = \OC::$server->getMountProviderCollection()->getMountCache();

$mounts = $mountCache->getMountsForFileId($fileId);
$userWithAccessToFile = array_map(function(ICachedMountInfo $mount) {
    return $mount->getUser();
}, $mounts);

$mounts = $mountCache->getMountsForFileId($fileId);
if (count($mounts) > 0) {
    $node = $mounts[0]->getMountPointNode();
    $owner = $node->getOwner();
}
