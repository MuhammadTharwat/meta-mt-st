#!/bin/sh

module="$1"
command="$2"
raw_partition="$3"

STATUS_TEST="TEST"
STATUS_NORMAL="NORM"
STATUS_TESTING="TING"

DEV="/dev/mmcblk0"
FIRST_BOOT_OFFSET="524288"

FIT_STATUS_OFFSET="524292"
FIT_ACTIVE_PART_OFFSET="524296"
FIT_A_PART="2"
FIT_B_PART="3"


ROOTFS_STATUS_OFFSET="524300"
ROOTFS_ACTIVE_PART_OFFSET="524304"
ROOTFS_A_PART="5"
ROOTFS_B_PART="6"

case "$command" in
    install_update)
        case "$module" in
            fit)
                BYTE_HEX=$(dd if="$DEV" bs=1 skip="$FIT_ACTIVE_PART_OFFSET" count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')
                BYTE_DEC=$((16#$BYTE_HEX))
                if [ "$BYTE_DEC" = "$FIT_A_PART" ]; then
                    BYTE_DEC="$FIT_B_PART"
                else 
                    BYTE_DEC="$FIT_A_PART"
                fi
                echo "Update Target FIT"
        	    dd if="$raw_partition" of=/dev/mmcblk0p$BYTE_DEC bs=4MB
                printf "%s" "$STATUS_TEST" | dd of="$DEV" bs=1 seek="$FIT_STATUS_OFFSET" 2>/dev/null
                sync
                ;;
            rootfs)
                BYTE_HEX=$(dd if="$DEV" bs=1 skip="$ROOTFS_ACTIVE_PART_OFFSET" count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')
                BYTE_DEC=$((16#$BYTE_HEX))
                if [ "$BYTE_DEC" = "$ROOTFS_A_PART" ]; then
                    BYTE_DEC="$ROOTFS_B_PART"
                else 
                    BYTE_DEC="$ROOTFS_A_PART"
                fi
                echo "Update Target RootFS"
        	    dd if="$raw_partition" of=/dev/mmcblk0p$BYTE_DEC bs=4MB
                printf "%s" "$STATUS_TEST" | dd of="$DEV" bs=1 seek="$ROOTFS_STATUS_OFFSET" 2>/dev/null
                sync
                ;;
        esac
        ;;

    cancel_update)
        case "$module" in
            fit)
                echo "Cancelling FIT Update"
                printf "%s" "$STATUS_NORMAL" | dd of="$DEV" bs=1 seek="$FIT_STATUS_OFFSET" 2>/dev/null
                sync
                ;;
            rootfs)
                echo "Cancelling RootFS Update"
                printf "%s" "$STATUS_NORMAL" | dd of="$DEV" bs=1 seek="$ROOTFS_STATUS_OFFSET" 2>/dev/null
                sync
                ;;
        esac
        ;;
        
    confirm_update)
        echo "Confirm Update"
        case "$module" in
            fit)
                CURRENT_STATUS=$(dd if="$DEV" bs=1 skip="$FIT_STATUS_OFFSET" count=4 2>/dev/null)
                echo "Current $CURRENT_STATUS"
                if [ "$CURRENT_STATUS" = "$STATUS_NORMAL" ]; then
                    echo "FIT Normal, ignore"
                elif [ "$CURRENT_STATUS" = "$STATUS_TEST" ]; then
                    echo "FIT Test Not Started, ignore"
                    exit 1
                elif [ "$CURRENT_STATUS" = "$STATUS_TESTING" ]; then
                    BYTE_HEX=$(dd if="$DEV" bs=1 skip="$FIT_ACTIVE_PART_OFFSET" count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')
                    BYTE_DEC=$((16#$BYTE_HEX))
                    if [ "$BYTE_DEC" = "$FIT_A_PART" ]; then
                        BYTE_DEC="$FIT_B_PART"
                    else 
                        BYTE_DEC="$FIT_A_PART"
                    fi
                    printf "\\x$(printf '%02x' "$BYTE_DEC")" | dd of="$DEV" bs=1 seek="$FIT_ACTIVE_PART_OFFSET" 2>/dev/null
                    echo "$STATUS_NORMAL" | dd of="$DEV" bs=1 seek="$FIT_STATUS_OFFSET" 2>/dev/null
                    sync
                    echo "FIT Confirmed"
                else
                    echo "FIT Unknown Status"
                fi
                ;;
            rootfs)
                CURRENT_STATUS=$(dd if="$DEV" bs=1 skip="$ROOTFS_STATUS_OFFSET" count=4 2>/dev/null)
                echo "Current $CURRENT_STATUS"
                if [ "$CURRENT_STATUS" = "$STATUS_NORMAL" ]; then
                    echo "RootFS Normal, ignore"
                elif [ "$CURRENT_STATUS" = "$STATUS_TEST" ]; then
                    echo "RootFS Test Not Started, ignore"
                    exit 1
                elif [ "$CURRENT_STATUS" = "$STATUS_TESTING" ]; then
                    BYTE_HEX=$(dd if="$DEV" bs=1 skip="$ROOTFS_ACTIVE_PART_OFFSET" count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')
                    BYTE_DEC=$((16#$BYTE_HEX))
                    if [ "$BYTE_DEC" = "$ROOTFS_A_PART" ]; then
                        BYTE_DEC="$ROOTFS_B_PART"
                    else 
                        BYTE_DEC="$ROOTFS_A_PART"
                    fi
                    printf "\\x$(printf '%02x' "$BYTE_DEC")" | dd of="$DEV" bs=1 seek="$ROOTFS_ACTIVE_PART_OFFSET" 2>/dev/null
                    echo "$STATUS_NORMAL" | dd of="$DEV" bs=1 seek="$ROOTFS_STATUS_OFFSET" 2>/dev/null
                    sync
                    echo "ROOTFS Confirmed"
                else
                    echo "ROOTFS Unknown Status"
                fi
                ;;
        esac
        ;;
esac
exit 0
