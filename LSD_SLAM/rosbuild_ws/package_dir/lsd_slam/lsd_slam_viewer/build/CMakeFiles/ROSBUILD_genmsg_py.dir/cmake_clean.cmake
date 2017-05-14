FILE(REMOVE_RECURSE
  "../msg_gen"
  "../msg_gen"
  "../src/lsd_slam_viewer/msg"
  "CMakeFiles/ROSBUILD_genmsg_py"
  "../src/lsd_slam_viewer/msg/__init__.py"
  "../src/lsd_slam_viewer/msg/_keyframeMsg.py"
  "../src/lsd_slam_viewer/msg/_keyframeGraphMsg.py"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/ROSBUILD_genmsg_py.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
