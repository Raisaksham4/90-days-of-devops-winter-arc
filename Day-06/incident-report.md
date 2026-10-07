# Day 6 — Controlled Storage Incident Report

## PROBLEM

A 100 MB ext4 test image mounted at `/mnt/day6disk` reached 97% usage, leaving 2.6 MB available. This was a controlled near-full condition. No application write failure or `No space left on device` error was observed.

## EVIDENCE

- `findmnt -M /mnt/day6disk -t ext4` confirmed the test filesystem was mounted at the intended path.
- `df -h /mnt/day6disk` showed `/dev/loop0` at 81 MB used, 2.6 MB available, and 97% usage.
- `df -i /mnt/day6disk` showed 14 of 25,600 inodes used (1%), ruling out inode exhaustion.
- `sudo du -ah /mnt/day6disk | sort -h | tail -20` showed `testfile` and `fill1` at 40 MB each.
- `sudo lsof +L1` showed unrelated zero-byte deleted MySQL temporary files under `/tmp`. They were not the cause of this test filesystem's usage.

## ROOT CAUSE

The two files I intentionally created on the test filesystem, `/mnt/day6disk/testfile` and `/mnt/day6disk/fill1`, each contained 40 MiB of data. Together they consumed nearly all usable blocks on the small ext4 filesystem.

## FIX

After confirming `/mnt/day6disk` was still the ext4 test mount, I removed only `testfile` and `fill1` and ran `sync`. I left the filesystem image and its mount configuration in place.

## VERIFICATION

`df -h /mnt/day6disk` returned to 152 KB used, 83 MB available, and 1% usage. `sudo du -sh /mnt/day6disk` reported 20 KB. This confirmed that the test files were gone and free space had returned.

The `/etc/fstab` entry also passed `findmnt --verify`, and `mount -a` remounted the filesystem after an unmount. Restart persistence was not tested.
