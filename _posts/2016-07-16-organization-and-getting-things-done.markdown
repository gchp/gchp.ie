---
layout: post
title: "Iota: Organization & Getting Things Done"
date: 2016-07-16T22:08:03+01:00
tags: organization
---

On and off for the past few years I've been [working on a text editor called iota](https://github.com/gchp/iota). When I set out I had two goals, the first was to learn how text editors worked, and the other was to build an editor that I could use in my day to day development. Since then, I've suffered from severe feature creep. My goals have changed so many times that if I don't draw a line I will never finish.

I read an article the other day from [antirez](http://antirez.com) on how he [built a text editor](http://antirez.com/news/108) over the course of a few weeks. This made me realise how far off track I'd gotten. I was spending time looking at how to support plugins, server-client architecture and other things that I had not initially set out to support.

I've decided then to reign in the scope for the project and bring it back down to the original goal of having an editor that I can really use. With this in mind, there are only two real things that are missing. One is syntax highlighting, and the other is the ability to edit multiple files in a session.

The other things I've been pursuing are good, and I'd definitely like to pursue them a bit more, so I've decided to put together a release plan. The initial "release" will contain my bare minimum requirements for a text editor. After that, new things will be incrementally added as I validate ideas and implement them.

I've been challenged thinking about this. I didn't realise it before, but I've been reluctant to "ship" something that wasn't finished. The past few days though I've realised that my idea of finished had been skewed by the feature creep of the last few years. This is why I'm turning to small, incremental release from now on. I've come to the place with this project where it's ok for it not to be entirely ready, or as fast or optimal as it could be.

I think its more important right now just to ship something, to get that feeling of achievement back. To feel like I'm actually making progress, and not just going around in circles. To help myself towards this, I've created the [first milestone on the iota project (0.2.0)](https://github.com/gchp/iota/milestone/1). The completion of this milestone will mean iota will support:

- editing multiple buffers
- split view support (horizontal & vertical)
- syntax highlighting

I'm not too concerned right now on implementing these in the best, most efficient way (as much as I may not like it!). It can always be changed and improved in future releases. The goal is to just get organized and get it done.

