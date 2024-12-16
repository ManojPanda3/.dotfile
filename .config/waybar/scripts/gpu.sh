#!/bin/bash
# GPU_DETAILS
function percent() {
	echo "scale=1; $1 * 100 / $2" | bc; 
}
VMEM_USAGE=$(percent $(cat /sys/class/drm/card1/device/mem_info_vram_used) $(cat /sys/class/drm/card1/device/mem_info_vram_total))
GPU_USAGE=$(cat /sys/class/drm/card1/device/gpu_busy_percent)
TEMP=$(sensors | grep -m 1 "edge:" | awk '{print $2}' | tr -d '+')

echo "${GPU_USAGE}%   ${TEMP}  ${VMEM_USAGE}%  "
