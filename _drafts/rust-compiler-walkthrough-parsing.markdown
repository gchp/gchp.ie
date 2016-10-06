---
layout: post
title: "Rust Compiler Walkthrough - Parsing"
---

This is the second post in the [Rust compiler walkthrough][series] series where
we take a simple Rust program and track its journey through the compiler to
learn about what goes on under the hood. If you haven't already read [the
introduction][intro] I encourage you to check that out.

This post will focus on the parsing phase, but before we get going on that I'd
like to make one small update from the previous post.

[Jethro Beekman (@JethroGB)][beekman] tweeted me [here][tweet] suggesting that
I use an official nightly for this series, rather than going from a random
commit. This would allow those following along to install the desired nightly
build rather than having to build from source at my randomly chosen commit.
This makes sense to me, so for the remainder of the series we will be working
off the nighly from August 9th 2016. You can install this with [rustup][rustup]:

```bash
$ rustup toolchain add nightly-2016-08-09
```

If you still want to work from source (as I will be) you can find the commit
used for the nightly on your system by running:

```bash
$ rustup run nightly-2016-08-09 rustc -V
rustc 1.12.0-nightly (080e0e072 2016-08-08)
```

For me, the nightly was build from commit `080e0e072`. This may be different
on your system.

Now that that's taken care of, let's get to it. As I mentioned above we are
going to be looking at the parsing phase of the compilation process.

The parsing phase is initiated through a call to the `phase_1_parse_input`
function [here][parse_invoc]. Let's look at the [signature of this function
][p1_sig]:

``` rust
pub fn phase_1_parse_input<'a>(sess: &'a Session,
                               cfg: ast::CrateConfig,
                               input: &Input)
                                -> PResult<'a, ast::Crate> {
```

So, `phase_1_parse_input` takes three arguments and returns some sort of result
which if successful will contain something called `ast::Crate`. We'll come to
this later. First, let's look at the inputs.

## Inputs

The first is a `Session`. The definition of this type can be found in
[`src/librustc/session/mod.rs` on line 54][session_def]. Essentially, this
object contains information and data which is associated with the entire
compilation session for a crate. It stores information such as the compilation
target, available macros, a list of lints and much more.

One field that stands out to me here in relation to parsing is the [`parse_sess`
field][parse_sess] which contains a [`ParseSess`][parse_sess_def] instance.
This type stores information on a parsing session. We'll see how this is used
later.

The second input here is `ast::CrateConfig` which comes from
[`src/libsyntax/ast.rs` on line 431][crate_config]. The definition is pretty
simple:

```rust
/// The set of MetaItems that define the compilation environment of the crate,
/// used to drive conditional compilation
pub type CrateConfig = Vec<P<MetaItem>>;
```

Right now, I don't have much more to add to this. `CrateConfig` is used to drive
conditional compilation. We're not doing any conditional compilation in our
small programme, so I doubt we will come across this much in the series.

The final input to `phase_1_parse_input` is the actual input to the compiler in
the form of an enum called `Input` which can be found in
[`src/librustc/session/config.rs` on line 181][input_enum]. This enum has two
variants, `File` and `Str`. For us in this case the input to the compiler is
coming from a file, so the input argument for us is `Input::File(path)` where
`path` is a `PathBuf` object referencing the filepath of our input file.

## Output

The output of `phase_1_parse_input` is an `ast::Crate` which is defined in
[`src/libsyntax/ast.rs` on line 434][crate_def]. This, as far as I can tell
at the moment is the parsed representation of the input. TODO: come back to this....

## Parsing

Now that we have some idea of our inputs and outputs for the parsing phase,
let's get to the actual parsing. Back in `phase_1_parse_input` we enter a match
expression on the `Input` for the compiler. For us in this case the match
expression [lands on line 487][parser_call] which calls the
`parse_crate_from_file` function in [`src/libsyntax/parse/mod.rs`][pc_from_file].
This function takes the file path we want to compile, the
`CrateConfig` object, and the `ParseSess` object from the compilation session.

The first thing this function does is start to create a parser. Before that
can happen however, there are some pre-requisites. In order to construct a
Parser, we need to first construct a token stream from our source code. To
get a token stream, let's first look at how our source code is initially
represented inside the compiler.

### CodeMap

One of the fundamental data structures used throughout the entire process is a
`CodeMap`. To quote a docstring from [`src/libsyntax/codemap.rs`][codemap_doc]:

> The CodeMap tracks all the source code used within a single crate, mapping
> from integer byte positions to the original source code location. Each bit
> of source parsed during crate parsing (typically files, in-memory strings,
> or various bits of macro expansion) cover a continuous range of bytes in the
> CodeMap and are represented by FileMaps. Byte positions are stored in
> `spans` and used pervasively in the compiler. They are absolute positions
> within the CodeMap, which upon request can be converted to line and column
> information, source code snippets, etc.

So the `CodeMap` keeps track of all our source code. For us then this is just
a single file.

### FileMap

A `FileMap` is a single source inside a `CodeMap`. It keeps track of the source
code for an individual file, along with information on where that file fits
into the `CodeMap`. It stores information such as the location of the start of
lines inside the file, position of multi-byte characters, the file name and the
absolute path of the file.

The full definition can be found in [`src/libsyntax_pos/lib.rs` lines 292-308][
filemap_def]

### Span

Another structure we will see used throughout the entire process is `Span`. To
again quote [a docstring][span_doc]:

> Spans represent a region of code, used for error reporting. Positions in spans
> are *absolute* positions from the beginning of the codemap, not positions
> relative to FileMaps. Methods on the CodeMap can be used to relate spans back
> to the original source.

So `Span`s give us a way to reference regions of code, potentially across files.
An example of where these are used is for pulling code snippets out to be
displayed in error messages. We will see this specific case later in the
series.

### TokenTree

A `TokenTree` is an enum which can be one of three variants

- `Token`: A single token.
- `Delimited`: A delimited sequence of tokens.
- `Sequence`: A sequence of `TokenTree`s.

### Parser


[series]: /tags/compiler-walkthrough/
[intro]: /2016/08/09/rust-compiler-walkthrough-introduction/
[beekman]: https://twitter.com/JethroGB
[tweet]: https://twitter.com/JethroGB/status/763090361384210432
[rustup]: https://rustup.rs
[parse_invoc]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/librustc_driver/driver.rs#L92
[p1_sig]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/librustc_driver/driver.rs#L477-L480
[session_def]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/librustc/session/mod.rs#L54-L106
[parse_sess]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/librustc/session/mod.rs#L60
[parse_sess_def]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/libsyntax/parse/mod.rs#L43
[crate_config]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/libsyntax/ast.rs#L431
[input_enum]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/librustc/session/config.rs#L181
[crate_def]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/libsyntax/ast.rs#L434-L440
[parser_call]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/librustc_driver/driver.rs#L487
[pc_from_file]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/libsyntax/parse/mod.rs#L79-L85
[codemap_doc]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/libsyntax/codemap.rs#L11-L18
[filemap_def]: https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/libsyntax_pos/lib.rs#L292-L308
[span_doc]:  https://github.com/rust-lang/rust/blob/080e0e072f9c654893839cf1f7ea71dc153b08a9/src/libsyntax_pos/lib.rs#L46-53
