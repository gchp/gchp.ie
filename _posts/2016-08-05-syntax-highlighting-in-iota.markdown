---
layout: post
title: "Syntax highlighting in Iota"
date: 2016-08-05T11:17:18+01:00
tags: iota syntax-highlighting programming
image: /assets/img/iota.jpg
---

![Iota with syntax highlighting](/assets/img/iota.jpg)
*Iota editing itself with syntax-highlighting enabled*

For the past few months I've been thinking about syntax-highlighting in
[Iota](/projects/iota/). I did a good bit of research into how this is acheived
in other editors to see how I should go about implementing it for myself.

### Regex

What I found was that many text editors use a regex based system for syntax
highlighting. A package might define a set of patterns which the editor uses
to pull out and highlight particular parts of a blob of text. What I like about
this approach is that it allows people to easily define & tweak new syntax
highlighting patterns without having to dive into the depths of the editor
itself.

I started off by investigating this approach in more depth. I came across a
crate called [syntect](https://github.com/trishume/syntect) which provides
syntax-highlighting using Sublime Text syntax definitions. The obvious benefit
of this is that out of the box I could get highglighting for a whole range of
languages. What I found however is that the highlighting was not quite granular
enough for me. I wanted to be able to get pretty specific with what portions of
text I could highlight, and the Sublime regex patterns just didn't operate at
that level.

I'm used to using [neovim](https://neovim.org) for my day-to-day editing, and
the highlighting it provides is pretty much the level that I am aiming for with
Iota.

After exploring syntect some more, and looking around for other solutions I
found myself getting a little discouraged by not finding something that was
"up to scratch" - I was being pretty picky! I decided to park the regex-based
approach for now with the view to revisit later, and instead began working on
my own alternate approach.

### My approach - a lexer

What I decided to do was to implement a very simple lexer. The lexer creates a
stream of tokens from the source text and the editor uses those tokens to draw
text in different colors. Each language definition can override the handler for
a particular character in the source text and produce a different token than
the default. For instance, when encountering the `#` character, the Rust lexer
will being to parse an attribute (`#[cfg(feature="foo")]`, for instance),
whereas the Python lexer will beging to parse a single line comment.

The thing I like about this approach is that language lexers can get as granular
as they want. The big downside is that defining syntax highlighting for a new
language means writing a new lexer implementation. Which is a pain. There also
is no way to configure the colors for various identifiers - they're all hard
coded. This will definitely need to be changed in the future.

In reality, the regex approach is probably going to be the most feasible going
forward, however I haven't yet found the best way to do it. For now I've added
the lexer approach just so there is some highlighting function available, but I
do plan on replacing it at a later time. My short-term goal for Iota is that it
would be in place where I can use it on a day-to-day basis, and this brings me
one step closer to that place. Once I achieve that goal, I'll shift gears into
making it work the way it *should*.

### Try it out

If you want to try out the syntax-highlighting, you'll need to enable that
feature when building (it's disabled by default). First, get the latest source
from [Github](https://github.com/gchp/iota) using either:

```bash
$ git clone https://github.com/gchp/iota # for a fresh clone
$ git pull origin master # if you already have the source checked out
```

Then, you need to enable syntax-highlighting. You can do this by either building
directly with cargo:

```bash
$ cargo build --release --features syntax-highlighting
```

Or by using the provided configuration script:

```bash
$ ./configure --enable-syntax-highlighting
$ make
```

I've also [opened a ticket](https://github.com/gchp/iota/issues/127) on the
Github page to track improvements & ideas to syntax highlighting.
