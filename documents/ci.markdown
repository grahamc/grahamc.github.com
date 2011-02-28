---
title: Continuous Integration
layout: post
---

### Inertia
Projects have _inertia_. Bad practices lead to more bad practices. Bad code leads to more bad code. Fixing this is trivial.

#### Bad Code
> "I'm going to write bad code because everyone else is doing it."

When your source code is generally poor, it is tempting to simply go with the flow and continue writing bad code. This is precedent. This is easy. __This is disheartening.__

#### Good Code
> "I'm going to write good code because I don't want to be the only one with writing bad code."

You can _easily_ change the inertia of your project by simply following the __boyscout rule__:
> Leave the campground cleaner than you found it.

Our repository is our campground, and the cleanup doesn't have to be significant:

* Reformat a small chunk
* Rename a single variable
* Break up one function

Each of these things cleans up the code and makes that little bit easier to read. These small, incremental changes will automatically over time contribute to a much healthier codebase.

By performing small tasks like this you can feel confident that the project is in a better state than it was yesterday, and will continue improving over time.

These continuous improvements will help change the inertia of the project and help ensure a better tomorrow.

### Broken Window Theory
__the theory behind project inertia__
> Consider a building with a few broken windows. If the windows are not repaired, the tendency is for vandals to break a few more windows. Eventually, they may even break into the building, and if it's unoccupied, perhaps become squatters or light fires inside.
>
> Or consider a sidewalk. Some litter accumulates. Soon, more litter accumulates. Eventually, people even start leaving bags of trash from take-out restaurants there or breaking into cars.
> - [Wikipedia](http://en.wikipedia.org/wiki/Broken_window_theory)

__If you break tests and leave them broken, more will be broken.__

Continuous integration will tell you immediately if a window is broken. Broken tests _kill_ inertia. Fix tests immediately to maintain positive inertia. If a test is bad, fix it.

### Steps to Positive Inertia
With these analysis tools, it's quite possible that when they are first used the reports they generate are going to be massive, frightening, and unwieldy.

The important part about these reports is __not necessarily the specific problems__, but the __trend of the data over time__; are things getting worse? Or getting better? As the size of my project grows, does my ratio of LOC-to-coding standard violations increase? Those are the kinds of questions which are most useful to answer.

#### PHP Lines of Code
[PHPLOC](https://github.com/sebastianbergmann/phploc) is a very simple tool to generate basic information about your project. It will give information about the number of lines, how much of it is comments, executable, whitespace, etc.

This information is useful, but it isn't actionable. Pairing this information with statistics from other tools allows for simple prioritization of standards and quality.

#### PHP Lint
Running a lint checker on a codebase is trivial to implement, and prevents simple issues from becoming huge problems. A project which is littered with syntax errors will quickly lose positive inertia.

With a simple check it quickly becomes apparent that the little bitty change I made and didn't test because it was so gosh darned simple... oh wait it's broken, whoops... Is not acceptable.

This is possibly the easiest step to take, and is definitely the least scary.

#### PHP Mess Detector
>  \[PHPMD\] takes a given PHP source code base and look for several potential problems within that source. These problems can be things like:
> - Possible bugs
> - Suboptimal code
> - Overcomplicated expressions
> - Unused parameters, methods, properties
> 
> -- [PHPMD](http://phpmd.org)

PHP Mess Detector is a great way to automatically detect potential problem spots in your source. While this information is fantastic, for teams with problematic code it is only telling you what you already know.

By trending this data over time, it can paint a much more positive picture, while still delivering accurate information. Eventually the specifics will become useful, however may be ignored until the project has made significant improvements.

#### PHP Abandoned Documentation Block Detector
[PHPADD](https://github.com/fmntf/phpadd) is a relatively new tool to automatically detect docblocks in your sourcecode which are out of date, incorrect, or missing. Docblocks which are wrong are almost worse than not having them at all.

This tool will give statistics as well as specific information, and it is very important to keep this number to a minimum.

#### PHP Copy Paste Detector
[PHPCPD](https://github.com/sebastianbergmann/phpcpd) is a tool to detect copy and pasting of code around your project. This tool can create very specific information on ways you can easily refactor. This tool can generate very large output and is not necessarily always a good first step.

I recommend implementing this and capturing data trends, but not worrying so much about specific results until later on in the project.

#### PHP Coding Standards
[PHPCS](http://pear.php.net/package/PHP_CodeSniffer) will automatically detect coding standard violations in your PHP, JavaScript, and CSS files. The coding standard can be specified, or customized depending upon your team.

Coding standards are often a point of contention between developers. It eventually boils down to coming to an agreement on one standard or another. For compatibility with 3rd party projects, I highly recommend following the [Zend Framework](http://framework.zend.com/manual/en/coding-standard.html) or [PEAR](http://pear.php.net/manual/en/standards.php) coding standards.

Coding standard violations are often in the thousands, so again - knowing the trend of this over time is the important part.

### The Hard Part
Unfortunately starting whole-hog on enforcing a coding standard and keeping doc blocks up to date can be pretty intimidating for a team who isn't used to doing it. I would recommend starting a policy on one, and then as you watch the violations go down, implement more as violations go down.

These should be introduced slowly to ease a team into the good practices. By going from zero to 100 in a day will almost certainly cause rejection.