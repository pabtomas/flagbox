# Documentation

If you have not read the README.md file of this repository, read it to
understand how to use flagbox for a basic usage. In this document we are going
to talk about flagbox's advanced features and I assume that you have a bit of
practice with flagbox.

## Advanced features

Probably the most useful of them is the ability to make a backup of the
current box and restore it later. Suppose you have a first terminal. You play
with it a little bit and finally you filled a box full of marks. What if you
want to open a second terminal and use marks defined is the first terminal
without doing the job all again ? flagbox generates the `??` alias for this
purpose. The `??` usage is simple: if the current box you are using is empty,
flagbox will search for a default backup and restore it. Otherwise, flagbox
will generate a backup. So for the use case we define earlier, the solution
is simple:
1) In the first terminal, the current box of the user is not empty, so the
user can use `??` alias to generate a backup with box used in this terminal.
2) In the second terminal, the box used in the second terminal is empty so the
user use `??` alias again to change its content to the box saved in backup.
And that's it, the user can now use two different boxes with the same content
in two different terminals.
Even if `??` alias seems very unusual, this command offers a great flexibility.
Here 2 more common usages of flagbox where `??` alias will save the situation:
- The user has an opened terminal with a full-filled box. For system reasons,
the user has to restart his laptop. To not lose the box content, the user can
use `??` alias to make a backup, restart the system and reuse `??` to get the
content of his box back.
- The user has an opened terminal with a full-filled box. For some reasons, the
user needs to define new marks for short-term usage without loosing his
current box content but does not have enough empty marks for his use case.
The user can use `??` alias to make a backup, make some modifications on his
box, use the box for his use case, erase totally the content of the box with
`???` alias and then reuse `??` to get the content of his box back.

`??` alias can take an optional argument. If you need to keep the default
backup for another marks you can define your own backup by adding a parameter:
`?? myflagboxbackup`.

The main problem of flagbox is its box size limitation. In deed, even if you
can put a large number for your box size (10, 15, 50 or why not 315204 ?), you
will find quickly by yourself that navigate in your workspace will be more
annoying by typing 15 times a comma than typing `cd /the/path/to/my/directory`.
For this reason, I could not guarantee an effcient flagbox usage if your box
size is higher than 4 flags.
To solve this problem, flagbox lets you define any number of box you want. but this rule is used to guarantee an efficient flagbox usage and I do
not recommend to use a box size higher than 4 if you want to keep an efficient
usage of flagbox. But what if you want to use more than 4 flags and keep a
recommend usage of flagbox.

## Configuration
