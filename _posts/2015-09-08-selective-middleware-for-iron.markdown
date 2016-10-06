---
layout: post
title: Selective Middleware for Iron
date: '2015-09-08 12:25:08'
tags: iron rust
permalink: /selective-middleware-for-iron/
---

Recently I've been spending some time working in a web application written in Rust using the [iron](https://github.com/iron/iron) framework. Largely it's been a pretty positive experience. There are some areas where the lack of functionality is a bit annoying (sessions, for example), but it also provides a good learning platform for various parts of the HTTP stack. Not having a good library to use for sessions for instance, gives me a reason to attempt to write my own, thus learning more about how sessions work!

I've been doing some work on the middleware for my application, and came across a case where I needed to selectively add middleware to specific handlers. By default, Iron lets you use the `Chain` structure to link middleware before or after your handlers:

```rust
extern crate router;
extern crate iron;

use router::Router;
use iron::Chain;
use iron::Iron;

fn main() {
    let mut router = Router::new();

    router.get("/", my_handler)
    router.get("/foo", my_handler)

    let chain = Chain::new(router);
    chain.link_before(MyMiddleware);

    Iron::new(chain).http("localhost:3000").unwrap();
}
```

The above example will apply the `MyMiddleware` middleware to each handler in the router. You can selectively add middleware by creating multiple `Chain` instances.

```rust
extern crate router;
extern crate iron;

use router::Router;
use iron::Chain;
use iron::Iron;

fn main() {
    let mut router = Router::new();

    let index_chain = Chain::new(my_handler);
    index_chain.link_before(MyMiddleware);

    router.get("/", index_chain)
    router.get("/foo", my_handler)

    Iron::new(router).http("localhost:3000").unwrap();
}
```

This example applies the `MyMiddleware` middleware to only the index route ("/"). This works well, but it can get pretty verbose when you have lots of routes. I decided to extract this functionality to a separate crate, so others don't need to spend time figuring it out.

## SelectiveMiddleware

The [selective_middleware](https://crates.io/crates/selective_middleware) crate allows you to achieve the same functionality as above, but with less work.

```rust
extern crate router;
extern crate iron;
extern crate selective_middleware;

use router::Router;
use iron::Chain;
use iron::Iron;
use selective_middleware::SelectiveMiddleware;

fn main() {
    let mut router = Router::new();

    router.get("/", SelectiveMiddleware::new(my_handler, vec!(MyMiddleware)))
    router.get("/foo", my_handler)

    Iron::new(router).http("localhost:3000").unwrap();
}
```

`SelectiveMiddleware::new` takes your handler as the first argument, and a `Vec` of middlewares as a second argument. Each of the given middlewares should implement `BeforeMiddleware`. Future updates will support passing `AfterMiddleware` here too, but for now its just `BeforeMiddleware`.

There is also the `with_middleware!` macro, which is merely for convenience. It gives a nicer syntax in my opinion:

```rust
extern crate router;
extern crate iron;
#[macro_use(with_middleware)] extern crate selective_middleware;

use router::Router;
use iron::Chain;
use iron::Iron;

fn main() {
    let mut router = Router::new();

    router.get("/", with_middleware!(my_handler, [MyMiddleware]))
    router.get("/foo", my_handler)

    Iron::new(router).http("localhost:3000").unwrap();
}
```

It's a small abstraction, but I think it goes a good way towards readability, and it's solved my use-case. Hopefully it can do the same for others. Feel free to open issues for bugs/suggestions on the [Github page](https://github.com/gchp/selective_middleware)!
