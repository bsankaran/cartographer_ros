--
--  Author: Bharath Sankaran
--  file: assets_writer_3d.lua
--  author: Bharath Sankaran 
--  date: December 2018
--
-- Supplemental tracking frames /base_link /chassis_link

VOXEL_SIZE = 3e-2

include "transform.lua"

options = {
  tracking_frame = "base_link",
  pipeline = {
    -- This controls the amount of range data used to build map
    -- helps optimize the size of the bag file
    {
      action = "min_max_range_filter",
      min_range = 0.5,
      max_range = 60.,
    },
    -- Help remove moving objects and filter by voxel
    -- check documentation for usage
    -- {
    --   action = "voxel_filter_and_remove_moving_objects",
    --  voxel_size = VOXEL_SIZE
    --},
    {
      action = "dump_num_points",
    },

    -- Gray X-Rays. These only use geometry to color pixels.
    {
      action = "write_xray_image",
      voxel_size = VOXEL_SIZE,
      filename = "xray_yz_all",
      transform = YZ_TRANSFORM,
    },
    {
      action = "write_xray_image",
      voxel_size = VOXEL_SIZE,
      filename = "xray_xy_all",
      transform = XY_TRANSFORM,
    },
    {
      action = "write_xray_image",
      voxel_size = VOXEL_SIZE,
      filename = "xray_xz_all",
      transform = XZ_TRANSFORM,
    },

    -- Now we recolor our points by frame and write another batch of X-Rays. It
    -- is visible in them what was seen by the horizontal and the vertical
    -- laser.
    {
      action = "color_points",
      frame_id = "velodyne",
      color = { 255., 0., 0. },
    },
    {
      action = "color_points",
      frame_id = "rslidar",
      color = { 0., 255., 0. },
    },
    --{
    --  action = "write_pcd",
    --  filename = "points.pcd",
    --},
    {
      action = "write_xray_image",
      voxel_size = VOXEL_SIZE,
      filename = "xray_yz_all_color",
      transform = YZ_TRANSFORM,
    },
    {
      action = "write_xray_image",
      voxel_size = VOXEL_SIZE,
      filename = "xray_xy_all_color",
      transform = XY_TRANSFORM,
    },
    {
      action = "write_xray_image",
      voxel_size = VOXEL_SIZE,
      filename = "xray_xz_all_color",
      transform = XZ_TRANSFORM,
    },
  }
}

return options
