#!/usr/bin/env - /bin/bash
# $Id: T-002.sh,v 1.1.2.2 2004/06/01 07:01:56 lars Exp $

Start RS_1 Node_1

sleep 10

Fail_Disk Disk_1

sleep 5

Relocate RS_1 Node_2

sleep 5

Heal_Disk Disk_1

# ToDo write a wrapper for this, and integrate with Heal_Disk ...
on $Node_1: drbd_reattach minor=0 name=r0

sleep 5

Relocate RS_1 Node_1

sleep 10

Stop RS_1
