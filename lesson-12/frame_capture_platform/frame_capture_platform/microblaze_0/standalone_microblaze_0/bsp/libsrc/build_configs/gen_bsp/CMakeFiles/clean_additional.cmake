# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "C:\\work\\edu\\my\\FPGA\\lesson-12\\frame_capture_platform\\frame_capture_platform\\microblaze_0\\standalone_microblaze_0\\bsp\\include\\sleep.h"
  "C:\\work\\edu\\my\\FPGA\\lesson-12\\frame_capture_platform\\frame_capture_platform\\microblaze_0\\standalone_microblaze_0\\bsp\\include\\xiltimer.h"
  "C:\\work\\edu\\my\\FPGA\\lesson-12\\frame_capture_platform\\frame_capture_platform\\microblaze_0\\standalone_microblaze_0\\bsp\\include\\xtimer_config.h"
  "C:\\work\\edu\\my\\FPGA\\lesson-12\\frame_capture_platform\\frame_capture_platform\\microblaze_0\\standalone_microblaze_0\\bsp\\lib\\libxiltimer.a"
  )
endif()
