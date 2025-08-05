#!/bin/bash
set -e

sleep 2

# # setup ros environment
source /opt/ros/${ROS_DISTRO}/setup.bash
source "/workspace/ros2_ws/install/setup.bash"
unset RMW_IMPLEMENTATION
unset ROS_DISTRO

exec "$@"
