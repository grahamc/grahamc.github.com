---
title: "How I Use a Ship's Bell Clock to Know My Software is Broken"
layout: post

disqus_id:  6661a7887ae4ed34381fa2cb8bc8009e
vimeo: 21573156
---

My father is a horologist, and as such I grew up with clocks ticking and chiming at all hours - their great strikes cooing me to sleep at night. I remember laying on the floor as a boy studying a clock in the dining room, practicing reading the roman numerals on its octagonal dial.

This early exposure to these beautiful, precision instruments has always inspired me to work with them - I just never knew how, or what I would use them for.

About a year ago I saw the [GitHub stoplight](http://urbanhonking.com/ideasfordozens/2010/05/19/the_github_stoplight/) pass along my feed reader, and I was hooked. I began researching stoplights and how to incorporate them, but it was too easy; no challenge after my [Price is Right, Cliff Hanger clone](http://www.youtube.com/itrebal#p/a/u/1/desD5os8iuE).

I wanted a similar system to inform me of my mistake on my software, but I also wanted a challenge, and I wanted it to be unique. Ultimately, I decided on using an Arduino with a motor control shield to control the chiming of a Ship's bell: One strike meant success, a second strike meant a failure.

### Controlling the Strike
![2011 03 27 Clock Tugs](/resources/2011-03-27-clock-tugs.png)
As it turns out, a clock's chime isn't rocket science. Something mechanical triggers the chime, and it runs autonomously. In this case, every half hour a trip rotating pin pushes the strike trigger out, allowing the process to begin.

Brilliantly enough, in order for the strike to do one chime (instead of two), the second strike lever falls and prevents the hammer from hitting the bell a second time.

By mechanically pulling the strike trigger, and lifting (or dropping) the second strike lever, I could reliably and fairly easily trigger the clock to strike once or twice.

### Controlling the Strike... Electronically
![2011 03 27 Clock Sensors](/resources/2011-03-27-clock-sensors.png)
Setting up a couple of motors to tug on the strike trigger and the second strike lever was fairly easy. I used a [SparkFun Dual Motor Driver](http://www.sparkfun.com/products/9457) along with a couple of [geared motors](http://www.sparkfun.com/products/8911) and the hub from a [wheel](http://www.sparkfun.com/products/8899). Using a bent paper clip and some dental floss, I was able to trigger both actions without much motor movement.

I knew from the get-go I needed a way to know if I had moved the levers far enough, but I wasn't sure how to go about it.

#### Sensing the Levers
![2011 03 27 Clock Sensors2](/resources/2011-03-27-clock-sensors2.png)
I discovered by mistake that I could ground both levers from the same point, and that placing a wire at the right point would allow me to know for certain when I had pulled a lever far enough. By waiting for these circuits to be completed, I could stop pulling the lever at the precise moment.

![2011 03 27 Clock Chimebar](/resources/2011-03-27-clock-chimebar.png)
> I used copper desoldering braid wrapped around an insulated peg to sense when the second strike lever was all the way up.

### All Together Now
![2011 03 27 Clock Attachedtop](/resources/2011-03-27-clock-attachedtop.png)

Possibly the hardest part of this project was figuring out a way to know when to stop pulling on the levers. This took by far the longest, but looking back, was the most pivotal in having it be successful. In fact, additional value would be gained by adding feedback systems to know exactly when they are in their "off" position too, as these are still done via a timer.

All in all, I'm fairly pleased with the results - all that is functionally left now is having my testing server push notifications to the chime. Eventually, I would like to clean it up; put the electronics away, mount it on wood and possibly put a quartz movement in there as if it were a real clock.