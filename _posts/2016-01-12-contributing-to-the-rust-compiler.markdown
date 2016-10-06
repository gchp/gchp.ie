---
layout: post
title: Contributing to the Rust compiler
date: '2016-01-12 14:22:54'
tags: programming rust compiler
permalink: /contributing-to-the-rust-compiler/
---

Contributing to the Rust compiler can be a daunting prospect for some. A large code-base, a complex build system and endless tickets means finding a nice starting place can be tough. This article aims to shed light on some of the areas you should be aware of when contributing your first patch to the Rust compiler, and provide some useful links to find more information.

There are some areas you need to be aware of to effectively work inside the Rust project. These are:

- [The build system](#the-build-system)
- [Issues](#issues)
- [Tests](#tests)
- [Pull requests](#pull-requests)

## The build system
The build system for Rust is complex. It covers bootstrapping the compiler, running tests, building documentation and more. Unless you are familiar with Makefiles, I wouldn't suggest trying to understand everything going on in Rust's setup - there's a lot there, and you can get lost trying to understand it all.

If Makefiles are your thing, though, all the configuration lives in [the `mk` directory](https://github.com/rust-lang/rust/tree/1.5.0/mk) in the project root.

### Configuration 
Before you can start building the compiler you need to configure the build for your system. In most cases, that will just mean using the defaults provided for Rust. Configuring involves invoking the `configure` script in the project root.

```
./configure
```

There are large number of options accepted by this script to alter the configuration used later in the build process. Some options to note:

- `--enable-debug` - Build a debug version of the compiler (disables optimizations)
- `--disable-valgrind-rpass` - Don't run tests with valgrind
- `--enable-clang` - Prefer clang to gcc for building dependencies (ie LLVM)
- `--enable-ccache` - Invoke clang/gcc with ccache to re-use object files between builds

To see a full list of options, run `./configure --help`.

### Build stages
Building the Rust compiler from source involves four **stages**.

#### stage0
Because the source for the Rust compiler is itself written in Rust, it means that we can't just compile the source into the latest compiler. Instead, we need to download an older version of the compiler from the internet and use that to build a new version of the compiler from the source tree.

**stage0** downloads an older version of the compiler from the internet.

#### stage1
Once we have a version of the compiler downloaded, we start to compile a new version from source. We use the compiler from stage0 to build the **stage1** compiler.

The **stage1** compiler contains all new language features & optimizations, but are not used in the compiler itself. To build the compiler with these new features & optimizations, we need to build from source again using this version of the compiler.

#### stage2
Using the compiler from stage1 which contains all new language features & optimizations we build the **stage2** compiler. At this point, we have the latest, most advanced & optimized version of the compiler.

The final (and optional) build step is to re-build the compiler once more using the compiler from stage2 to produce the stage3 compiler.

#### stage3
The **stage3** compiler should be bitwise identical to the **stage2** compiler. We build it to ensure that we haven't introduced any new issues in the latest build.

<!-- NOTE: turns out this is not entirely true anymore...
This stage is not run by default, but will run as part of Rust's continuous integration system.
-->

### Useful targets
The most common targets I find myself using are:

- `make rustc-stage1` - build up to (and including) the first stage. For most cases we don't need to build the stage2 compiler, so we can save time by not building it. The stage1 compiler is a fully functioning compiler and (probably) will be enough to determine if your change works as expected.
- `make check` - build the full compiler & run all tests (takes a while). This is what gets run by the continuous integration system against your pull request. You should run this before submitting to make sure your tests pass & everything builds in the correct manner.
- `make check-stage1-std NO_REBUILD=1` - test the standard library without rebuilding the entire compiler
- `make check TESTNAME=<path-to-test-file>.rs` - Run a single test file
- `make check-stage1-rpass TESTNAME=<path-to-test-file>.rs` - Run a single rpass test with the stage1 compiler (this will be quicker than running the command above as we only build the stage1 compiler, not the entire thing). You can also leave off the `-rpass` to run all stage1 test types.

## Issues 
Once you have your local environment set up you need to find a task to work on. Rust uses [GitHub issues](https://github.com/rust-lang/rust/issues/) to track tasks.

The Rust team uses a series of issue labels to help sort through and categorize issues. These labels denote the area of the code-base to which this issue is related, the expected level of difficulty, priority, and so on.

All labels have a prefix which denote the label type.

- `A-` means this label indicates the **Area** of the code-base related to this ticket. For example, `A-parser` means this issue relates to the parser.
- `B-` indicates an issue which is a **Blocker**.
- `E-` indicates the **Experience** required to work on the ticket. **E-easy** suggests that this issue is a good entry-level ticket which should be easy enough to fix. **E-hard** is a more involved, more difficult task.
- `I-` indicates the **Importance** of the issue
- `P-` indicates the **Priority** of the issue
- `T-` denotes what [**Team**](https://rust-lang.org/team.html) to which the issue belongs.

For beginners, I recommend looking at issues marked with `E-easy` & `E-mentor`. These issues will be somewhat easy to work on, and have a member of the Rust team who will mentor you through the process, answering questions as they arise.

## Tests 
Most contributions to the Rust compiler will require a corresponding test. There are a few different kinds of tests to be aware of.

**NOTE:** _A more comprehensive guide to the Rust test suite can be found on the [rust-wiki-backup](https://github.com/rust-lang/rust-wiki-backup/blob/master/Note-testsuite.md#the-rust-test-suite)_

### Language & compiler tests

These tests test the compiler against Rust code. There are a few different types of test.

- compile-fail - tests which expect to fail to compile
- run-fail - tests which expect to fail at run time
- parse-fail - tests which expect to fail during parsing

For a full list of tests, see the [rust-wiki-backup](https://github.com/rust-lang/rust-wiki-backup/blob/master/Note-testsuite.md#the-rust-test-suite) or look in the [`src/tests/`](https://github.com/rust-lang/rust/tree/1.5.0/src/tests/) directory.

Language & compiler tests can be run with the `make check-stage1` command.

### Unit tests
Most crates include unit tests. These tests live inside an inner module called `test`. These tests are the same as the unit tests described [in the book](https://doc.rust-lang.org/book/testing.html)

Unit tests can be run with the `make check-stage1-crates` command.

### Documentation tests
The build system will also test Rust code snippets from documentation examples.

You can run documentation tests with the `make check-stage1-doc` command.

## Pull requests 
When you have a patch you feel is ready for submission, you should open a pull request against the master branch of the Rust project. [This GitHub guide](https://help.github.com/articles/using-pull-requests/) gives a great walk-through of submitting pull requests.

When you submit a new pull request, a reviewer will be automatically appointed by a bot called **rust-highfive**. Throughout the review process you may be asked to make further modifications to the code. If this happens, you should submit those modifications as new commits (don't amend commits!). This will make it easier for your reviewers to see what you have changed.

When your commit has been approved, a project member will leave a comment instructing the integration bot, called bors, to test & merge your commit. The comment will looks something like:

```
@bors: r+ <commit-hash>
```

For more information on pull requests, take a look at the [relevant section of the contributing guide](https://github.com/rust-lang/rust/blob/1.5.0/CONTRIBUTING.md#pull-requests)

---

Another useful resource is the internal compiler documentation, which you can find [here](http://manishearth.github.io/rust-internals-docs/rustc/middle/ty). Thanks to [/u/Manishearth](https://www.reddit.com/r/rust/comments/40nzkd/contributing_to_the_rust_compiler_a_short_guide/cyvrj8c) on Reddit for bringing it to my attention.

---

For more information on any of the above, feel free to [contact me on Twitter](https://twitter.com/greg_chapple). I'd also highly recommend checking out the [official contributing guide](https://github.com/rust-lang/rust/blob/1.5.0/CONTRIBUTING.md)

In future posts I will be exploring some of the internal workings of the compiler. If that sorf of thing interests you, check back here soon!
