---
layout: page
title: Iota - A text editor written in Rust
permalink: /projects/iota/
excerpt: Iota is a simple terminal based text editor written in Rust.
---

Iota is a simple text editor written in [Rust](https://rust-lang.org/).

![Iota screenshot](/assets/img/iota.jpg)

Right now it is terminal-based, but I will probably eventually add some sort
of GUI version too. 

You can find the source code [on Github](https://github.com/gchp/iota).

Subscribe to project updates [via RSS](/projects/iota/atom.xml) or view past
updates below.

## Project updates

{% assign posts=site.tags["iota"] %}
{% include post-list.html posts=posts %}
