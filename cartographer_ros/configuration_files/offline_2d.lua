--
--  Author: Bharath Sankaran
--  file: jackal_3d.lua
--  author: Bharath Sankaran
--  date: December 2018
--
-- Supplemental tracking frames /base_link /chassis_link
include "map_builder.lua"
include "trajectory_builder.lua"

NUM_SCANS_PER_SUBMAP = 125
VOXEL_SIZE = 0.03

options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map",
  tracking_frame = "imu_link",
  published_frame = "base_link",
  odom_frame = "odom",
  provide_odom_frame = true,
  publish_frame_projected_to_2d = false,
  use_odometry = false,
  use_nav_sat = false,
  use_landmarks = false,
  num_laser_scans = 0,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 2,
  lookup_transform_timeout_sec = 0.2,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 5e-3,
  trajectory_publish_period_sec = 30e-3,
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 0.5,
  landmarks_sampling_ratio = 1.0,
}

-- The more often Cartographer gets measurements, the better it becomes at unwarping
-- the measurements to assemble a single coherent scan that could have been captured instantly.
-- Provide as many accumulated range data as possible to optimize better (for scan matching)
-- this is the number of range measurements so a small number like 1 or 2 should suffice
-- if you are using a driver that gives access to individual UDP packets then the number should
-- reflect one revolution of the sensor
MAP_BUILDER.use_trajectory_builder_2d = true
TRAJECTORY_BUILDER_2D.num_accumulated_range_data = 2
-- TRAJECTORY_BUILDER_2D.use_imu_data = false

-- Minimum and Maximum range beyond which you throw out laser data, i.e bandpass filter
TRAJECTORY_BUILDER_2D.min_range = 0.5
TRAJECTORY_BUILDER_2D.max_range = 30

-- IMU Time constant information - this value is apparently not changed even
-- by carto people, high value intergation of angular errors, low values acceleration
-- due to non gravity increased
TRAJECTORY_BUILDER_2D.imu_gravity_time_constant = 10.

-- Voxel size to ensure high density data doesn't dominate results, small voxel size more data
TRAJECTORY_BUILDER_2D.voxel_filter_size = VOXEL_SIZE
TRAJECTORY_BUILDER_2D.min_z = 0.2
TRAJECTORY_BUILDER_2D.max_z = 1.5

-- Adaptive Voxel size to ensure target number of 3D points
-- TRAJECTORY_BUILDER_3D.high_resolution_adaptive_voxel_filter.max_length = VOXEL_SIZE
-- TRAJECTORY_BUILDER_3D.high_resolution_adaptive_voxel_filter.min_num_points = 100.
-- TRAJECTORY_BUILDER_3D.high_resolution_adaptive_voxel_filter.max_range = 3.
-- TRAJECTORY_BUILDER_3D.low_resolution_adaptive_voxel_filter.max_length = 3 * VOXEL_SIZE
-- TRAJECTORY_BUILDER_3D.low_resolution_adaptive_voxel_filter.min_num_points = 300.

-- This dictates the number of submaps required for optimization higher the better
TRAJECTORY_BUILDER_2D.submaps.num_range_data = NUM_SCANS_PER_SUBMAP
-- TRAJECTORY_BUILDER_3D.submaps.high_resolution = VOXEL_SIZE
-- TRAJECTORY_BUILDER_3D.submaps.high_resolution_max_range = 3.
-- TRAJECTORY_BUILDER_3D.submaps.low_resolution = 3 * VOXEL_SIZE

-- TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.hit_probability = 0.55
-- TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.miss_probability = 0.49

-- To prevent deviation from the prior, i.e moving backward or forward
-- The scan matcher needs to generate a high score to deviate from prior
-- for a fast moving robot we need a low score
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.translation_weight = 4
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.rotation_weight = 6

TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.num_threads = 16
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.max_num_iterations = 20

MAP_BUILDER.num_background_threads = 16

-- This reduces the effects of outliers, function is quadratic
-- for small numbers and linear for large numbers
POSE_GRAPH.optimization_problem.huber_scale = 5e3

-- Setting this parameter to zero only looks at the performance of local SLAM
POSE_GRAPH.optimize_every_n_nodes = 50

-- If you are happy with IMU optimization and want to trust extrinsics
-- POSE_GRAPH.optimization_problem.use_online_imu_extrinsics_in_3d
-- High sampling ratio will slow down mapping but provide better solutions
POSE_GRAPH.constraint_builder.sampling_ratio = 0.7
POSE_GRAPH.constraint_builder.min_score = 0.70
POSE_GRAPH.constraint_builder.global_localization_min_score = 0.66

--- Pose graph
-- POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 200
-- POSE_GRAPH.optimization_problem.acceleration_weight = 1e3
-- POSE_GRAPH.optimization_problem.rotation_weight = 3e3
-- POSE_GRAPH.optimization_problem.local_slam_pose_translation_weight = 1e3
-- POSE_GRAPH.optimization_problem.local_slam_pose_rotation_weight = 2e3

-- Use when using odometry information
-- POSE_GRAPH.optimization_problem.odometry_translation_weight = 2e2
-- POSE_GRAPH.optimization_problem.odometry_rotation_weight = 0.0

-- POSE_GRAPH.max_num_final_iterations = 1000

return options
