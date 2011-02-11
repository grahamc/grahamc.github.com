---
title: 'How to Create a Super Nerdy Super Bowl Party That Everyone Will Love or: RFID + 1,000 Chicken Wings (Wait... What?)'
layout: post
bigimg: 'http://a5.sphotos.ak.fbcdn.net/hphotos-ak-ash1/hs897.ash1/180547_10150379207205371_731005370_16747401_756589_n.jpg'
---
To be quite frank, I don't care about football. I didn't even know who was playing in the Super Bowl until the day before when two people simultaneously expressed their excitement for _insert team here_ to kick _the other team_'s ass. Unfortunately I was being dragged into a party, but it wasn't without cause - we were going to eat 1,000 chicken wings before the night was out, and only 25 people were there to do it. We called it [KeepWinging](http://keepwinging.com).

Now this was pretty close to enough for me to enjoy it, but since [NationalField](http://nationalfield.org) is a data and analytics driven company, we needed to step it up.

### Thursday Night
Three days before the big day we decided that in order to really know for certain how many wings we've eaten, we needed an accurate count. We needed a great, fun, real-time dashboard of how many wings we've snarfed down, and an easy, BBQ-sauce friendly way to report that data. A solution that means no sticky fingers or beer on my laptop.

I had a lot to do in just 48 hours:

- build an easy reporting system that didn't involve a sticky mess.
- get anything that was necessary to build and implement this system.
- build a website to display this information in real time.

### The Dashboard
![The KeepWinging Dashboard](/resources/2011-02-11-dashboard.png)
> Note, this was taken after KeepWinging ended; otherwise the WPH would show a real number.

We wanted a very simple dashboard which would display only the most important stats in our venture to eat 250 chickens worth of buffalo wings. We also wanted it to be live-updating, and give some level of competition between users.

This was done with a simple jQuery `$.get()` call plus a `setTimeout` at the end. The polling was simple and quick, and for a guy who doesn't know Javascript very well - it was just perfect. I looked at Node.JS, however with only three days to go I didn't have the time to learn it.

#### What We Came Up With
- **Leaderboard**: The top nine users, showing their total wing consumption and how they compared to the people behind them. This seemed to encourage people who were five below a spot to eat more, and had people fighting to stay on the board.
- **Total Wings Consumed**: We actually had this in two places, in graph form (which for some reason didn't display accurately, but the trend was correct) and as a big number along the top. It was so exciting seeing it roll over to 900, we knew it had to be possible to finish. Below this we also displayed the total number of wings remaining.
- **Wings Per Hour (WPH)**: We thought it was very neat to know just how many wings we were eating per hour, and we also displayed the number of wings per hour which were necessary to complete the 1,000 wings by the end of the game. At one point we were up to 300 WPH.

Each of these items would automatically refresh every second or two, so feedback was almost instant. We knew exactly when consumption was falling off, as well as when fresh "meat" joined. This was displayed on a gigantic television screen next to the wings.

### The Feed
![The KeepWinging Feed](/resources/2011-02-11-feed.png)
> The feed would update every second.

Let's face it, the internet loves a good live-updating feed of what is going on. We love that instant feedback of change in our lives, so we couldn't resist building one.

The feed was extremely simple, and only updated when a user registered or ate more wings. This view however, was exciting to have and be able to see how quickly people were allocating themselves more wings.

## How It All Worked
The solution to mess-free reporting was pretty obvious: RFID (`Radio Frequency IDentification`, like what you might scan to open a keyless door.) Each participant would register an RFID tag with the system, and every time they threw out 5 wings they would be allowed to scan their tag. Since I already had a reader, this was feasible.

### KeepWinging.com
[KeepWinging](http://keepwinging.com) was written entirely in [Symfony](http://symfony-project.org) using [Propel](http://www.propelorm.org); it had a very simple `JSON RPC API` for providing the data we needed for the content pages - and a single reporting endpoint.

I started writing the code on Friday evening and finally pulled it all together at 2:50 PM, Sunday afternoon, with the party starting at 3:00PM. Perfect timing.

### The RFID Reader
![The RFID Process](/resources/2011-02-11-rfid-reader.png)
Thursday night was spent building the RFID reader: an [arduino](http://www.sparkfun.com/products/9950) with a [Parallax RFID reader](http://www.radioshack.com/product/index.jsp?productId=2906723) which I got from RadioShack, a couple of LEDS, all mushed into a used Korean [Bibimbop](http://en.wikipedia.org/wiki/Bibimbap) take-out dish. It was perfect. All we needed were the RFID tags.

I also incorporated some simple human feedback: users are used to visual _and _ audio feedback when reading a tag like this. I incorporated a visual cue
by having a red and blue LED. When the tag was scanned, the blue light would switch to red. Unfortunately I didn't have a buzzer loud enough to stand a chance at a party, so I removed this part of the feedback. (Yes, I did get complaints that it didn't beep or buzz.)

One note about RFID readers which I learned during this project:
> Since RFID readers use radio frequencies, the number of devices and signals we have going through the airways can cause false-positive matches. These codes would look like `F0000F0000` and were almost always obviously fake.
> 
> In order to reduce the number of false positives received, it is recommended to try reading the tag twice within a few seconds (I used 2) before it considers it a successful read. This will prevent almost all false positive reads.

### The RFID Tags
The tags were a little bit tricky. I only had the two which came with the kit, and we were expecting around 30 people. Now that wouldn't be fun, we'd only have two teams; we had to order more.

It was 10:00 PM on Thursday, the party was on Sunday, and I had to order 50 RFID tags. This meant overnight shipping. This meant Saturday delivery. This meant an AM delivery so I would have some time to make sure they worked. This meant that the cost of shipping was 2x the cost of the actual tags themselves. Boy, when I ordered these tags I committed myself to a lot; namely that they would work.

### The Glue (Arduino -> Laptop -> KeepWinging.com)
In order to get the tag data from the Arduino to the laptop, I had my brother and a friend help hack out a Perl based script to read from the serial port and execute a command when it received one. This would just execute a local Symfony task: `./symfony tag:reportRemote --env=prod $tag`

The code was simple enough: read 10 bytes from the reader, send it along through the USB serial port to my laptop using the Arduino's handy reader.

![The RFID Process](/resources/2011-02-11-rfid-process.png)
> By having the registered check, setting up a new RFID tag was a snap and nearly problem-free.

That task would perform the registration or the reporting through a very simple RPC API I built. This was no attempt at being RESTful; I just needed to get the thing done.

### Nearing the End
At the end of the night, we were about 20 away from finishing off a thousand - but the simple fact was that nobody could stand to eat five more. Solution: Reduce the report number down to 1, and everyone only has to eat one more wing to push us over. After a little bit of cheering and motivational speaking, we polished off an entire thousand buffalo wings right as the Super Bowl's clock ran out of time.

Success.