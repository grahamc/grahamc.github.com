Below are some notes to the team at [Clarify](http://clarify.io) in response
to this [flame bait](http://iops.io/blog/docker-hype/).

# Dockerfile

 - Restrictions let you reason about how a system works. It is how Heroku is so
   popular and reliable. Having a smaller API is frequently a good choice.
 - It is true that you can't extend a docker file without some effort, but it
   is worth noting that the whole point of Docker adding your service-level
   code to a foundational layer.
 - You can now have have many dockerfiles with your choice of name, using the
   `-f` option to `docker build`.
 - His bit about `$HOME` disappearing is because, I presume, he's never run
   commands outside of a shell...

# Docker cache / layers

 - It is true that there are some issues with their COW filesystem, and it is a
   bit slow to have many small layers. You'll notice most of our container
   have layers with many operations happening. IE: all the dependencies
   installed in one go.
 - The surprising side effects issue they note is pretty silly. Currently the
   cache name calculation is based on (`prior_layer_sha`, `command_to_run`). Their
   example is appending `|| true` to a step causes the step to rebuild. What
   they are proposing is when the command changed:

1. Build the layer again
2. Compare the filesystem against the previous version which they would somehow
   look up (given how the layer ID is calculated, this would not be easy.)
3. If the FS was identical, use the other layer to preserve caching

There are numerous flaws though. For example, time changes, and if any files
are created or modified, the FS would be in a different state.

Also, attempting to do a "smart" cache strategy is just asking for far more
bugs.

 - There are proposals in the works to "merge" layers, but none of them have
   been merged yet. Also, I'm not convinced it is a "poor architectural
   design".

# Docker Hub

 - Multiple FROM operations doesn't really make sense. It is saying what FS to
   start with. Merging two would be â€¦ well, near impossible. Multiple
   inheritance is hard enough in a programming language with an extremely
   limited set of possible collisions.
 - It is true you can update a tag on Dockerhub, `ubuntu:14.04` does change
   from time to time, like when security patches are released. If someone
   cared enough, they could mirror the image and then not update their mirrored
   copy.
 - Their observations about the limitations of the docker hub builder around
   file placement are not correct.
 - It is true they don't do pre/post script hooks, but how does that make
   sense, when you only can perform operations in your own container, and you
   have full power to do whatever you want? Also, they have web hooks to notify
   you when it is built.
 - Setting up a Docker Registry is not "ridiculously complex". We do it, it
   takes 4 configuration options:

    environment ({
      'STORAGE_PATH'        => '/path/on/disk',
      'SETTINGS_FLAVOR'     => 'local',
      'MIRROR_SOURCE'       => 'https://registry-1.docker.io',
      'MIRROR_SOURCE_INDEX' => 'https://index.docker.io'
    })

# Security

 - He makes a few good points, but let's not forget about the deluge of
   vulnerabilities that have been discovered over the past year in cornerstones
   of internet security. In short, it isn't good that there are some issues,
   but we don't run just anybody's code on our systems.
 - It is true that running inside a linux kernel is more risky than running a
   hypervisor. But, again, we're not running a public code hosting service.

# Containers are not VMs

 - He seems to really want containers to be a VM.
 - Linux containers are not VMs
 - Using a hypervisor requires your deployed server also take care of
   networking, whereas docker and the host linux machine do that for you.
 - A running docker container is ONLY running your application - no dhcpd or
   pickup or cron or syslog, which all increases attack surfaces. Reducing the
   amount of things your container has to worry about is a Good Thing(tm).
 - There are some performance issues

# Docker is unnecessary

 - Docker is pretty great for debugging. Having the identical binaries from the
   app code to the interpreter to glibc is really nice. Making "debugging
   frustratingly difficult" seems like a load of bullocks.
 - `baseimage-docker` which runs SSH is a bad idea, and the greater Docker
   community resoundingly rejects it.


