# Documentation

If you have not read the
[README file](https://github.com/pabtomas/flagbox/blob/master/README.md), read
it to understand how to use *Flagbox* for a basic usage. In this document, I
am going to talk about *Flagbox*'s advanced features and I am assuming that
you have enough practice with *Flagbox* to understand basic *Flagbox*
operations without mentionning the matching aliases.

## Backup feature

Let's assume you opened a first terminal. You play with it a little bit and
finally you filled a box full of marks. What if you want to open a second
terminal and use marks defined in the first terminal without doing the job a
second time? *Flagbox* generates the `??` alias for this purpose. The `??`
usage is simple: **if the current box you are using is empty**, *Flagbox* will
search for a default backup and restore it. Otherwise, *Flagbox* will generate
a backup. For the use case I defined earlier, the solution is simple:
1) In the first terminal, your current box is not empty, so you can use `??`
alias to generate a backup with box used in this terminal.
2) In the second terminal, the box used is empty so you can use `??` alias
again to change its content to the box saved in backup. And that's it, now you
can use two different boxes with the same content in two different terminals.

Even if `??` alias seems very unusual, this command has a very flexible usage.
Here 2 other situations where `??` alias can save you:
- You have an opened terminal with a full-filled box. For system reasons, you
have to restart your laptop. To keep your box content, you can:
  - use `??` alias to make a backup,
  - restart the system,
  - reuse `??` to get the content of your box back.

- You have an opened terminal with a filled box. For some reasons, you need to
define new marks for short-term usage without loosing your current box
content. However your box does not have enough empty space to keep your
current box content and define new marks. To solve this situation, you can:
  - use `??` alias to make a backup,
  - empty space in your current box,
  - define your short-term marks,
  - use your newly created marks,
  - reset your current box,
  - reuse `??` to get the content of your box back.

`??` **alias can take an optional argument**. If you need to keep the default
backup for another marks you can define your own backup by adding a parameter:
`?? myflagboxbackup`.

## New box feature

The main problem of *Flagbox* is its box size limitation. In deed, even if you
can set a big box size (10, 15, 50 or why not 315204? See
**Configuration section**), you will find quickly (and by yourself) that
navigating in your workspace will be more annoying by typing 15 times a comma
than typing

`cd /the/path/to/your/directory`.

For this reason, I could not guarantee an efficient *Flagbox* usage if your
box size is higher than 4 flags. To keep an efficient usage without
restraining it with only 4 flags, *Flagbox* defines `,?` and `?,` aliases.
These aliases allow box navigation cyclicly. **If your current box is not
empty and is the last in your cycle**, going to the next box will build a
new one. Building a new box, keeps the marks you defined in other boxes and
allows you to use same aliases for different directories you want to save.

Let's assume you have a current lonely and empty box. Using `,?` alias will
not create a new box because the current one is empty. We have to fill it with
an alias.

</br>
<img src="/media/filledbox.png">
</br>

Now using `,?` alias will create a new box where you can reuse `,` alias for
an other directory.

</br>
<img src="/media/2boxes.png">
</br>

With these two boxes you just have to use `,?` and `?,` to switch between them
and use `,` alias for the directory you need to go.

If you need to delete a box, **you have to empty it and use the full question
marks alias on it**:

</br>
<img src="/media/deletebox.png">

## Navigation Mode

If you read the documentation so far you should notice that `?` alias displays
two information this documentation have not covered yet:
1. The mode. When you open a terminal, *Flagbox* starts in **Edition mode**
(EDIT). In this mode, *Flagbox* allows you to erase a mark. When you leave
this mode this action will not be possible. Leaving Edition mode is a
guarantee to not accidentally erase a mark (or a filled-box). You should use
Edition mode only when you need it. When you finished what you did with
Edition mode, you are highly encouraged to use the **Navigation Mode** (NAV).
In Navigation mode, resetting aliases ability is replaced by navigation
ability. In deed, you probably notice that if you have a huge boxes number,
navigating between them with `,?` and `?,` aliases is a painful task. To
understand how Navigation mode works, you have to convert numbers in their
binary representation where '0' is a comma and '1' is a question mark. The
alias length is as minimal as possible. So if you want go to box 1 and you
have not more than 7 boxes, the alias to achieve this is `,,?` (for box 2 it
is `,?,`, box 3 `,??`, box 4 `?,,`, etc). If you want go to box 5 and you have
more than 7 boxes but you have not more than 16 boxes, the alias to achieve
this is `,?,?`.
If you are not enough confortable with binary representation
to use it in your workflow, you can configure *Flagbox* to generate decimal
aliases instead of binary aliases in Navigation mode (See **Configuration
section**).
2. *Flagbox* highlights a mark if the current directory is used by this mark.
Why? Because using this mark will change the *Flagbox* mode. So if:
  - *Flagbox* is in Edition Mode,
  - the `,` mark is used for your home directory,
  - you are located in your home directory,

Using `,` mark will set *Flagbox* in Navigation mode. This is exactly the same
operation if *Flagbox* is in Navigation mode and you need to come back to
*Edition Mode*.

## Configuration
