# Documentation

If you have not read the
[README file](https://github.com/pabtomas/flagbox/blob/master/README.md) of
this repository, read it to understand how to use *flagbox* for a basic usage.
In this document we are going to talk about *flagbox*'s advanced features and
I assume that you have a bit of practice with *flagbox*.

## Backup feature

Suppose you opened a first terminal. You play with it a little bit and finally
you filled a box full of marks. What if you want to open a second terminal and
use marks defined is the first terminal without doing the job all again ?
*flagbox* generates the `??` alias for this purpose. The `??` usage is simple:
if the current box you are using is empty, *flagbox* will search for a default
backup and restore it. Otherwise, *flagbox* will generate a backup. For the
use case we define earlier, the solution is simple:
1) In the first terminal, the current box of the user is not empty, so the
user can use `??` alias to generate a backup with box used in this terminal.
2) In the second terminal, the box used is empty so the user can use `??`
alias again to change its content to the box saved in backup. And that's it,
the user can now use two different boxes with the same content in
two different terminals.
Even if `??` alias seems very unusual, this command has a very flexible usage.
Here 2 other situations where `??` alias will be the solution:
- The user has an opened terminal with a full-filled box. For system reasons,
the user has to restart his laptop. To not lose the box content, the user can
use `??` alias to make a backup, restart the system and reuse `??` to get the
content of his box back.
- The user has an opened terminal with a full-filled box. For some reasons,
the user needs to define new marks for short-term usage without loosing his
current box content but does not have enough empty marks for his use case.
The user can use `??` alias to make a backup, make some modifications on his
box, use the box for his use case, erase totally the content of the box with
`???` alias and then reuse `??` to get the content of his box back.

`??` alias can take an optional argument. If you need to keep the default
backup for another marks you can define your own backup by adding a parameter:
`?? myflagboxbackup`.

## New box feature

The main problem of *flagbox* is its box size limitation. In deed, even if you
can put a large number for your box size (10, 15, 50 or why not 315204 ?), you
will find quickly by yourself that navigating in your workspace will be more
annoying by typing 15 times a comma than typing
`cd /the/path/to/your/directory`. For this reason, I could not guarantee an
efficient *flagbox* usage if your box size is higher than 4 flags. To allow
you to keep an efficient *flagbox* usage without blocking you with only 4
flags, *flagbox* allows you to build a new box by defining `,?` and `?,`
aliases. These aliases allow you to go to next or previous box cyclicly.
If your current box is not empty and is the last in your cycle, going to the
next box will build a new one. Building a new box, keep the marks you defined
in other boxes and allows you to use same aliases for different directories
you want to save.
Suppose we have a current lonely and empty box. Using `,?` alias will not
create a new box because its empty. We have to fill it with an alias.

</br>
<img src="/media/filledbox.png">
</br>

Now using `,?` alias will create a new box where you can reuse `,` alias for
an other directory.

</br>
<img src="/media/box2.png">
</br>

With these two boxes you just have to use `,?` and `?,` to switch box and use
`,` alias for the directory you need to go.

If you need to delete a box, you have to empty it and use the full question
marks alias on it:

</br>
<img src="/media/deletebox.png">
</br>

## Configuration
