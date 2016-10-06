---
layout: post
title: An Introduction to Node.js
date: '2013-02-25 12:00:00'
tags:
- node
- javascript
permalink: /an-introduction-to-node-js/
---

## What is Node.js?

> Node.js is a platform built on Chrome's JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.

So, what does that mean?

Basically, Node is built on Chrome's JavaScript runtime, otherwise known as V8, which was developed by Google. So if you build a Node.js application, it is being powered by the same engine that runs the JavaScript on a webpage in Chrome. That's the basic idea.


Unlike jQuery or YUI, Node.js is a JavaScript library that runs server side using an event based model, rather than a thread based model. This makes Node apps, very fast and highly scalable. That is my brief, 30 second explanation of what Node.js is, for the rest of this article, i'll show you how to get up and running with your first Node.js application.

## Installation
Install Node is very simple. Simply visit the [Node.js downloads page](http://nodejs.org/downloads) and choose the version for your specific platform. Run the installer and then thats it! Simples.

Another way you could do it is to use [NVM](https://github.com/creationix/nvm). NVM stands for Node Version Manager, and it does exactly that, manages your versions of Node. You can find details for installation of NVM on the GitHub page at the above link, so I won't waste time putting that here. Once you have installed NVM, you can install any version of Node using:

```bash
nvm install <version>
```

In this case, replace ```<version>``` with whatever version of Node you wish to install, i.e. 0.8.21. The advantage of using NVM is that you can easily install and switch between multiple versions of Node. This is extremely helpful when working on multiple projects, that may require different versions of Node in order to work.

## Your first Node.js application
So, now for the fun stuff! You have Node installed, now it's time to build and run your first Node application. 
Using your editor of choice, for me thats vim, create a new file called app.js and open it in your text-editor.

In this example, we are going to create a simple HTTP server, so we are going to require the 'http' module in our application. We can do that with the require function.

```js
var http = require('http');
```

Now that it's loaded, we want to do something with it. We can call the createServer method, which will of course, create a new server. Let do that;

```js
var server = http.createServer(function(request, response) {
	response.writeHead(200, {'Content-Type': 'text/plain'});
	response.end('Hello World!');
});
```

Let me explain what that little bit of code does. The createServer methods takes a callback function, which accepts request parameters and a response. In this case we don't need the request, so we are just working with the response. We use the writeHead method on the response to set the headers, we set the response code to 200, and the content-type to text/plain. Finally we call response.end passing in the string 'Hello World!'. Whenever anyone access this server, they will get the output of whatever we passed into response.end().

The final thing we need to do it tell the server to start listening. At the bottom of app.js, add this line:

```js
server.listen(9000, '127.0.0.1');
```

That tells the server to listen on port 9000 of 127.0.0.1 which is our Localhost.

Now, in order to start our server, we will need to open a command line, in my case Terminal, and navigate to wherever you created app.js. When you are there, run the following command, then open your browser of choice at localhost:9000.

```bash
node app.js
```

You should now see the text 'Hello World!' displayed in your browser, yay! If you see any errors output by Node in your command prompt, check to make sure you have typed all your code properly, and that everything is installed correctly before trying again.

As nice as this is however, it is not very useful, no one wants to just say 'Hello World!' to every user. Let's dig in a bit more and do something more useful.

In the same directory as app.js, create another file and call it server.js. Open up this file and stick in the following code.

```js
var express = require('express');
var app = express();

app.get('/hello', function(request, response) {
	response.send('Hello world!');
});

app.listen(9000);
console.log('Listening on port 9000');
```

Before we can run this however, we need to install express. [Express](http://expressjs.com) is a Node application framework, it allows us to create applications with simple routing and much more. To install express, open your command prompt and run:

```bash
npm install -g express
```

NPM stands for Node Packaged Modules. It allows us to install modules that don't already come with Node. Including the ```-g``` flag in the install command installs express globally on your system. Once that has finished installing you can run:

```bash
node server.js
```

If you see 'Server listening on port 9000' output in your shell then you know everything ran on, so open your browser on localhost:9000/hello and you should see 'Hello World!'.

Well, it's a little better now, you can create routes using app.get() and passing in your different routes as the first parameter. There are also different functions for the different HTTP verbs. Such as: app.get(), app.post(), app.put() etc. We still have the problem, of just saying 'Hello World', lets make our server display real web pages.

Create file called index.html and hello.html and paste in some HTML like this:

```html
<!DOCTYPE html>
<html>
	<head>
		<title>Home page</title>
	</head>
	<body>
		<h1>Hello from the home page</h1>
	</body>
</html>
```

Now in server.js, we need to replace the line containing ```response.send('Hello World!')``` with the following:

```js
response.sendfile('./home.html');
```

When you run this with ```node server.js``` and visit localhost:9000/hello, you should see the contents of your html file served to the browser, success!

Theres much more to Node and Express, so be sure to check out the documentation to both in the resources below if you are interested in finding out more. I also include a link to a blog I found very helpful in getting started with Node, called How to Node. I will be posting more articles in the future that go into more detail on some of the great features that Node provides so keep an eye out for that if you're interested!

### resources:
- [Node.js](http://nodejs.org)
- [Express](http://expressjs.com)
- [How To Node](http://howtonode.com)
