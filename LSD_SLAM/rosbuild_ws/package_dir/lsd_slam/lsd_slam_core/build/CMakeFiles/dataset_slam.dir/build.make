# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/build

# Include any dependencies generated for this target.
include CMakeFiles/dataset_slam.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/dataset_slam.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/dataset_slam.dir/flags.make

CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: CMakeFiles/dataset_slam.dir/flags.make
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: ../src/main_on_images.cpp
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: ../manifest.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/cpp_common/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/catkin/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/genmsg/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/gencpp/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/genlisp/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/genpy/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/message_generation/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rostime/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/roscpp_traits/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/roscpp_serialization/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/message_runtime/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosbuild/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosconsole/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/cv_bridge/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/std_msgs/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosgraph_msgs/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/xmlrpcpp/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/roscpp/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rospack/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/roslib/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosgraph/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rospy/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/roslz4/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosbag_storage/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/topic_tools/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosbag/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosmsg/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/rosservice/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/dynamic_reconfigure/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/geometry_msgs/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /opt/ros/indigo/share/sensor_msgs/package.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_viewer/manifest.xml
CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o: /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_viewer/msg_gen/generated
	$(CMAKE_COMMAND) -E cmake_progress_report /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o -c /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/src/main_on_images.cpp

CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/src/main_on_images.cpp > CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.i

CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/src/main_on_images.cpp -o CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.s

CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.requires:
.PHONY : CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.requires

CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.provides: CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.requires
	$(MAKE) -f CMakeFiles/dataset_slam.dir/build.make CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.provides.build
.PHONY : CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.provides

CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.provides.build: CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o

# Object files for target dataset_slam
dataset_slam_OBJECTS = \
"CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o"

# External object files for target dataset_slam
dataset_slam_EXTERNAL_OBJECTS =

../bin/dataset_slam: CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o
../bin/dataset_slam: CMakeFiles/dataset_slam.dir/build.make
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_videostab.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_video.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_superres.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_stitching.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_photo.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_ocl.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_objdetect.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_ml.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_legacy.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_imgproc.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_highgui.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_gpu.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_flann.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_features2d.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_core.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_contrib.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_calib3d.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_program_options.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/liblz4.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_signals.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_filesystem.so
../bin/dataset_slam: /usr/lib/liblog4cxx.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_regex.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_date_time.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_system.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_thread.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libpthread.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libconsole_bridge.so
../bin/dataset_slam: ../lib/liblsdslam.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_videostab.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_video.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_superres.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_stitching.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_photo.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_ocl.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_objdetect.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_ml.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_legacy.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_imgproc.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_highgui.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_gpu.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_flann.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_features2d.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_core.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_contrib.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libopencv_calib3d.so.2.4.8
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_program_options.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/liblz4.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_signals.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_filesystem.so
../bin/dataset_slam: /usr/lib/liblog4cxx.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_regex.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_date_time.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_system.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libboost_thread.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libpthread.so
../bin/dataset_slam: /usr/lib/x86_64-linux-gnu/libconsole_bridge.so
../bin/dataset_slam: CMakeFiles/dataset_slam.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable ../bin/dataset_slam"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/dataset_slam.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/dataset_slam.dir/build: ../bin/dataset_slam
.PHONY : CMakeFiles/dataset_slam.dir/build

CMakeFiles/dataset_slam.dir/requires: CMakeFiles/dataset_slam.dir/src/main_on_images.cpp.o.requires
.PHONY : CMakeFiles/dataset_slam.dir/requires

CMakeFiles/dataset_slam.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/dataset_slam.dir/cmake_clean.cmake
.PHONY : CMakeFiles/dataset_slam.dir/clean

CMakeFiles/dataset_slam.dir/depend:
	cd /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/build /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/build /home/hady/rosbuild_ws/package_dir/lsd_slam/lsd_slam_core/build/CMakeFiles/dataset_slam.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/dataset_slam.dir/depend

