occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'

occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'

occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json
