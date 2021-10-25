#!/bin/bash
./configure \
	--prefix=/usr \
	--enable-fhs \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--with-privatedir=/var/lib/samba/private \
	--with-smbpasswd-file=/etc/samba/smbpasswd \
	--with-piddir=/var/run/samba \
	--with-pammodulesdir=/lib/x86_64-linux-gnu/security \
	--libdir=/usr/lib/x86_64-linux-gnu \
	--with-modulesdir=/usr/lib/x86_64-linux-gnu/samba \
	--datadir=/usr/share \
	--with-lockdir=/var/run/samba \
	--with-statedir=/var/lib/samba \
	--with-cachedir=/var/cache/samba \
	--with-socketpath=/var/run/ctdb/ctdbd.socket \
	--with-logdir=/var/log/ctdb \
	--systemd-install-services \
	--without-ad-dc
