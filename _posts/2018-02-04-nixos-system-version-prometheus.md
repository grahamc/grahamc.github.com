---
layout: post
title: Prometheus and the NixOS System Version
bigimg: /resources/2018-02-04-grafana-prometheus-nixos-version.png
tags: nix
---

Use the Prometheus Node Exporter Textfile collector to help
correlate changes in your application's behavior with NixOS
deployments.

First, configure Prometheus's NodeExporter to enable Textfile
collection:

{% highlight nix %}
services.prometheus.nodeExporter = {
  enable = true;
  enabledCollectors = [
    "textfile"
  ];
  extraFlags = [
    "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
  ];
};
{% endhighlight %}

Second, populate the textfile directory with the current system
version on every boot and deployment:

{% highlight nix %}
system.activationScripts.node-exporter-system-version = ''
  mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
  (
    cd /var/lib/prometheus-node-exporter-text-files
    (
      echo -n "system_version ";
      readlink /nix/var/nix/profiles/system | cut -d- -f2
    ) > system-version.prom.next
    mv system-version.prom.next system-version.prom
  )
'';
{% endhighlight %}

Then, configure Grafana to use the `system_version` as an Annotation
with the following query:

    changes(system_version[5m])
