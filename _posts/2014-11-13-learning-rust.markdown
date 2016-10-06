---
layout: post
title: Learning Rust
date: '2014-11-13 19:29:31'
tags: rust
permalink: /learning-rust/
---

Recently, my various programming related social news feeds have been filled with, among other things, Rust & Go. Two relatively new players in the arena of the programming language.

A number of months ago, I was quite interested in Go. I had played with a few examples, written some small utilities with it and made several contributions to an open source project, [Vigo](https://github.com/kisielk/vigo), which is a VI clone written in Go. It was great fun, but after several months I found myself becoming bored with the language and retreated to my Python infested place of security.

Several months pass and I find myself emerging from my snake-cave once again with the smell of a new language in the air, this time – [Rust](http://rust-lang.org). I'd been hearing more and more about Rust in the recent weeks. A systems language which could be the modern day replacement for C. A big statement in itself. This alone was enough to spark my interest, so I decided to check it out. I had been interested in getting to grips with some system level programming and this seemed like the perfect opportunity to do so.

Thats the background of my decision to learn Rust. That was about 4 months ago, and so far I love it!

Many people told me that there was no point learning Rust right now due to the fact that its so young (still pre 1.0), and because of that the ecosystem is largely un-developed which means no libraries and so on. I decided to not listen to these people and learn it anyway.

The first thing I realised was that most of the articles that were already online were out of date, despite being only a few months, or in some cases a few weeks old. This was mainly due to the fact that the language was still being developed, syntax was being changed, design tweaked and so on. This was initially quite difficult to overcome as it meant that regular Google searches weren't going to help much. It did however lead me to delve right in to the docs and IRC. So far I've found both of these to be super helpful. The people on the #rust have always been quick to respond and I always come away having learned something.

After a couple of weeks of playing around with Rust I was confident enough in my abilities to take on creating some kind of application. Something beyond just simple scripts. So, with my experience in working on Vigo in hand, I decided to start writing a text editor in Rust.

Two disclaimers here;

1. I don't really know what I'm doing - writing a text editor is hard!
2. I'm still learning Rust as I go.

You can have a look at the current state of the editor on the [Github repo](https://github.com/gchp/rdit). Right now it just loads files, and lets you move a cursor around. I'm still trying to figure out the best way to structure the data internally, so it might be a while before I get past that. So far I've rewritten the buffer implementation four or five times trying to get it to work the way I want. Not luck yet, but I'm learning alot on the way!

So far its been fun though, and I'm excited to share the things I learn here.
