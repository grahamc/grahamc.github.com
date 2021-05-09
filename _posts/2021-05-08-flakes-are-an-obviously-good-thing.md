---
layout: post
title: Flakes are such an obviously good thing
subtitle: ...but the design and development process should be better.
tags: nix
---

Flakes is a *major* development for Nix. I believe one of the most significant changes the project has ever seen. Flakes brings a standardized interchange format for expressions, and dramatically reduces the friction of depending on someone else's code. However, it needs the community involved to shape and evolve in to a final and wonderful tool. 

The Nix community is about 18 years old now. Until recently (~6 years ago) the community was quite small. The project is now much bigger, and growing. The result is that, organizationally, we're a bit immature. The RFC process is new, and only a few major changes have gone through it.

Unfortunately, Flakes was one of the very first major Nix features to go through the community's relatively young RFC process.

As a community, we're not accustomed to and practiced at breaking down large and fundamental changes to the ecosystem and shepherding them through RFCs. But there we were: we had a shiny new process and by golly, a change that deserves an RFC! We hadn't even tied our shoes and yet we were attempting our first triathalon.

I believe everybody approached that RFC with really good intentions and hope that it would go well and be a productive process. In a lot of ways, it was productive. But the end of that RFC was not good.

What was one RFC probably should have been very theoretical "this is an idea, should we explore it?" followed by several RFCs about specific subsections and details about how Flakes would work.

But... we were so new to RFCs, so new to being a large project, we didn't see the problems coming.

As a result, the RFC was closed, agreeing to make Flakes "experimental" but merge it into Nix anyway. Maybe in the future, a new RFC would be submitted to review the code as existed in Nix already.

This has caused quite a lot of bad feelings between all sorts of people. A lot of assumptions about motivations that I don't believe hold up. Probably a good bit of distrust in to RFCs and the legitimacy of the process.

I find this so unfortunate. I believe Flakes are astonishingly important and will be very powerful, but the RFC experience has turned so many people against it on principle. Flakes have a lot of potential, and needs a strong community to work through their problems and help it flourish.

The damage to the perception of RFCs is real and tragic. I believe so deeply in this project and its ability to grow, and the organizational distrust from this makes that much, much more difficult.

I feel so disappointed in myself for not seeing the dangers of sending such a fundamental change to Nix the tool through a nearly brand new process which was a fundamental change to the Nix community. The process wasn't ready for it, the participants weren't ready for it.

I regret that so much.

I believe we can, as a project and community, move past it. It will take leadership and effort from a lot of people. Project leadership will have to make the first moves there, to mend the distrust and sow new seeds of cooperation. I know we can do this.

I have so much love for this project and its community. I feel so grateful to be part of it, surrounded every day by people so much smarter than me.

I hope to be part of the solution, to be part of the healing and growth.

I have been part of this project for just over five years now, and I am incredibly excited to be part of the next five.

The future of Nix is so bright I can hardly look right at it without looking down at less ambitious futures.

_This was originally a series of tweets._
