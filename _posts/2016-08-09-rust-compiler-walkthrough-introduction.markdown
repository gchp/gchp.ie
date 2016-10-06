---
layout: post
title: "Rust compiler walk-through - Introduction"
date: 2016-08-09T14:56:09+01:00
tags: rust compiler compiler-walkthrough
---

This post is the introduction to a new series which aims to give a walk-through
of the Rust compiler, starting from the initial entry point and going right
the way through the compilation process. The goal is to give a decent
understanding of what exactly is happening behind the scenes when you invoke
`rustc` on a source file.

I've decided to undertake this for one main reason - I want to know what the
compiler is doing and how it works.

I've decided to go for this "full stack" approach rather than dig into
one particular area mainly because I don't know what all the areas of
the compiler are and I want to discover as much about it as I can. I'm
sure there are plenty of super interesting parts that I could very easily
never encounter if I was to just dive in and focus on one particular
area over another. So, I'm going right from the start all the way down
to see what I find. I'm sure I'll learn lots, and perhaps some others
will find it beneficial too.

Firstly, if you haven't worked with the source of the compiler before,
I enourange you to check out my article on [contributing to the Rust
compiler](/contributing-to-the-rust-compiler) which gives an overview
on how to build the compiler from source which is useful to know if you
want to dig into this sort of stuff.

## Series overview

As I mentioned above, in this series I want to journey right through the
entire compilation process. Throughout this series I'll be taking the
following (very simple) Rust program from source through to executable:

```rust
use std::io::{Write, stdout};

fn main() {
    let mut out = stdout();
    writeln!(&mut out, "Hello world");
}
```

This is a pretty simple "Hello world" Rust program. It's more complex
than it needs to be however. The "typical" hello world program in Rust
looks some thing like:

```rust
fn main() {
    println!("Hello world");
}
```

This is obviously more concise than my first example, so why have I
chosen to go with the more verbose option? There are a couple of
reasons. Primarily because it uses a few different language features which
I'm curious about, and my hope is that I'll get to learn about how they work
throughout the series. Namely, the things my simple program displays:

- Imports (`use std::io::{...};`)
- Variable assignment (`let mut out = ...`)
- Function calls (`stdout();`)
- Macros (`writeln!(...)`)
- Warnings (`writeln!()` produces a result which I've intentionally
ignored here so we can investigate how the compiler identifies & outputs
warning messages)

Throughout the series we will track the various changes to &
representations of our simple Rust program and how the compiler deals
with each representation internally.

## Compiler version

For the duration of this series I will be working against the version of the
compiler as it was at [this commit][rustc-commit]. All references to files in
the compiler source will use this version of the compiler to ensure the links
always point to the correct portions of code. There's no particular reason I've
chosen this version other than the fact this was the latest commit when I
started writing the series.

If you want to follow along and build the compiler with the same version I'm
using throughout the series I encourage you to checkout and build from that
commit. I built my version like so:

```bash
$ ./configure --enable-rustbuild
$ python src/bootstrap/bootstrap.py --stage 1 --jobs 2
```

Which results in `rustc` version `1.12.0-nightly (58c5716e2 2016-08-08)`.

## Compilation overview

Starting off, how do we even know what happens when the compiler runs? A while
back I stumbled across the `-Z time-passes` option. When `rustc` gets this
option it prints the time taken for each pass of the compiler. For our purposes
here this is a good starting place. Throughout the series we will track our
program through as many of these passes as we can.

For my version of `rustc`, this is the output when compiling our sample
program:

```
time: 0.001; rss: 56MB	parsing
time: 0.000; rss: 56MB	configuration
time: 0.000; rss: 56MB	recursion limit
time: 0.000; rss: 56MB	crate injection
time: 0.000; rss: 56MB	plugin loading
time: 0.000; rss: 56MB	plugin registration
time: 0.275; rss: 93MB	expansion
time: 0.000; rss: 93MB	maybe building test harness
time: 0.000; rss: 93MB	assigning node ids
time: 0.000; rss: 93MB	checking for inline asm in case the target doesn't support it
time: 0.000; rss: 93MB	complete gated feature checking
time: 0.000; rss: 93MB	collecting defs
time: 0.035; rss: 93MB	external crate/lib resolution
time: 0.000; rss: 93MB	early lint checks
time: 0.000; rss: 97MB	AST validation
time: 0.004; rss: 97MB	name resolution
time: 0.000; rss: 97MB	lowering ast -> hir
time: 0.000; rss: 97MB	indexing hir
time: 0.000; rss: 97MB	attribute checking
time: 0.000; rss: 97MB	language item collection
time: 0.000; rss: 97MB	lifetime resolution
time: 0.000; rss: 97MB	looking for entry point
time: 0.000; rss: 97MB	looking for plugin registrar
time: 0.000; rss: 97MB	region resolution
time: 0.000; rss: 97MB	loop checking
time: 0.000; rss: 97MB	static item recursion checking
time: 0.000; rss: 101MB	load_dep_graph
time: 0.000; rss: 101MB	type collecting
time: 0.000; rss: 101MB	variance inference
time: 0.095; rss: 107MB	coherence checking
time: 0.001; rss: 107MB	wf checking
time: 0.003; rss: 109MB	item-types checking
time: 0.042; rss: 110MB	item-bodies checking
time: 0.000; rss: 110MB	drop-impl checking
time: 0.003; rss: 110MB	const checking
time: 0.000; rss: 110MB	privacy checking
time: 0.000; rss: 110MB	stability index
time: 0.000; rss: 110MB	intrinsic checking
time: 0.000; rss: 110MB	effect checking
time: 0.000; rss: 110MB	match checking
time: 0.000; rss: 110MB	liveness checking
time: 0.001; rss: 110MB	rvalue checking
time: 0.001; rss: 113MB	MIR dump
time: 0.014; rss: 114MB	MIR passes
time: 0.002; rss: 114MB	borrow checking
time: 0.000; rss: 114MB	reachability checking
time: 0.000; rss: 114MB	death checking
time: 0.000; rss: 114MB	stability checking
time: 0.000; rss: 114MB	unused lib feature checking
<std macros>:2:1: 2:54 warning: unused result which must be used, #[warn(unused_must_use)] on by default 
<std macros>:2 $ dst . write_fmt ( format_args ! ( $ ( $ arg ) * ) ) )
               ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
<std macros>:2:1: 2:46 note: in this expansion of write! (defined in <std macros>)
/home/gchp/test.rs:5:5: 5:39 note: in this expansion of writeln! (defined in <std macros>)
time: 0.002; rss: 114MB	lint checking
time: 0.018; rss: 114MB	resolving dependency formats
time: 0.001; rss: 114MB	Prepare MIR codegen passes
  time: 0.000; rss: 117MB	write metadata
  time: 0.472; rss: 124MB	translation item collection
  time: 0.005; rss: 124MB	codegen unit partitioning
  time: 0.011; rss: 131MB	internalize symbols
time: 0.965; rss: 131MB	translation
time: 0.000; rss: 131MB	assert dep graph
time: 0.000; rss: 132MB	serialize dep graph
  time: 0.001; rss: 129MB	llvm function passes [0]
  time: 0.001; rss: 129MB	llvm module passes [0]
  time: 0.039; rss: 133MB	codegen passes [0]
  time: 0.000; rss: 133MB	codegen passes [0]
time: 0.043; rss: 133MB	LLVM passes
time: 0.000; rss: 133MB	serialize work products
  time: 0.297; rss: 133MB	running linker
time: 0.300; rss: 134MB	linking
```

The above output can be somewhat daunting, so let's categorize them a little.
There are six main phases in the compilation process.

1. Parsing input
2. Configuration & expansion
3. Analysis passes
4. Translation to LLVM
5. LLVM passes
6. Linking

My initial plan is to write one post per phase, though I may end up breaking
some of them into several posts if they become too long.

The first one will cover parsing, which is the first phase. You can
[subscribe to this series]( /tags/compiler-walkthrough/atom.xml) to be notified
when that lands!

In the mean time, let's look at the entrypoint for the compiler.

## Entry point

After a few levels of indirection while looking through the compiler source
you'll come to the [`main` function in `librustc_driver`][driver-main]. This
is the main entry point which kicks off the entire process.

Elsewhere in this file there is code for handling command-line options, building
configuration for the compilation session, getting the input source, and
eventually [calling out to `compile_input`][driver-compile-input] . This
[`compile_input`][compile-input] function is what drives the various stages
listed above, and will be the starting point of the next post.

[rustc-commit]: https://github.com/rust-lang/rust/tree/58c5716e2d2b89c18cf2ac996376c9720b65b51d
[driver-main]: https://github.com/rust-lang/rust/blob/58c5716e2d2b89c18cf2ac996376c9720b65b51d/src/librustc_driver/lib.rs#L1113-L1116
[driver-compile-input]: https://github.com/rust-lang/rust/blob/58c5716e2d2b89c18cf2ac996376c9720b65b51d/src/librustc_driver/lib.rs#L226-L227
[compile-input]: https://github.com/rust-lang/rust/blob/58c5716e2d2b89c18cf2ac996376c9720b65b51d/src/librustc_driver/driver.rs#L66
