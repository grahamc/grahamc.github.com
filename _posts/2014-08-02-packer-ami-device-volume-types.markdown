---
layout: post
title: Packer: Create AMI with EBS Volumes with VolumeType
---

When creating an AMI through Packer, you're able to describe what type of
devices you want to attach to the device.

Using `launch_block_device_mappings` will cause the devices to be mounted for
the server the AMI will be created from. Using `ami_block_device_mappings` will
attach the devices to the server when it launches.

It is recommended to start `device_name` at `sde`.

## VolumeTypes

 - `standard`: magnetic disk
 - `gp2`: SSD
 - `io1`: Provisioned IOPS on SSD (requires `iops` to be specified.)

## Example

```json
{
  "builders": [{
    "ami_block_device_mappings": [
      {
        "device_name": "/dev/sde",
        "volume_type": "standard"
      },
      {
        "device_name": "/dev/sdf",
      },
      {
        "device_name": "/dev/sdg",
        "volume_type": "gp2"
      },
      {
        "device_name": "/dev/sdh",
        "volume_type": "io1",
        "iops": 1000
      }

    ]
  }]
}
```

