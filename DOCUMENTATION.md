# Documentation

If you have not read the
[README file](https://github.com/pabtomas/flagbox/blob/master/README.md) of
this repository, read it to understand how to use *Flagbox* for a basic usage.
In this document I am going to talk about *Flagbox*'s advanced features and
I assume that you have a bit of practice with *Flagbox*.

## Backup feature

Let's assume you opened a first terminal. You play with it a little bit and
finally you filled a box full of marks. What if you want to open a second
terminal and use marks defined in the first terminal without doing the job a
second time? *Flagbox* generates the `??` alias for this purpose. The `??`
usage is simple: if the current box you are using is empty, *Flagbox* will
search for a default backup and restore it. Otherwise, *Flagbox* will generate
a backup. For the use case I defined earlier, the solution is simple:
1) In the first terminal, your current box is not empty, so you can use `??`
alias to generate a backup with box used in this terminal.
2) In the second terminal, the box used is empty so you can use `??` alias
again to change its content to the box saved in backup. And that's it, now you
can use two different boxes with the same content in two different terminals.

Even if `??` alias seems very unusual, this command has a very flexible usage.
Here 2 other situations where `??` alias can save you:
<ul>
  <li> You have an opened terminal with a full-filled box. For system reasons, you
have to restart your laptop. To keep your box content, you can:
    <ul>
      <li> 1. use `??` alias to make a backup, </li>
      <li> 2. restart the system, </li>
      <li> 3. reuse `??` to get the content of your box back. </li>
    </ul>
  </li>
  <li>You have an opened terminal with a filled box. For some reasons, you need to
define new marks for short-term usage without loosing your current box
content. However your box does not have enough empty space to keep your
current box content and define new marks. To solve this situation, you can:
    <ul>
      <li> 1. use `??` alias to make a backup,
      <li> 2. empty space in your current box,
      <li> 3. define your short-term marks,
      <li> 4. use your newly created marks,
      <li> 5. empty your box with full question mark alias,
      <li> 6. reuse `??` to get the content of your box back.
    </ul>
  </li>
</ul>

`??` alias can take an optional argument. If you need to keep the default
backup for another marks you can define your own backup by adding a parameter:
`?? myflagboxbackup`.

## New box feature

The main problem of *Flagbox* is its box size limitation. In deed, even if you
can put a large number for your box size (10, 15, 50 or why not 315204?), you
will find quickly by yourself that navigating in your workspace will be more
annoying by typing 15 times a comma than typing

`cd /the/path/to/your/directory`.

For this reason, I could not guarantee an efficient *Flagbox* usage if your
box size is higher than 4 flags. To allow you to keep an efficient *Flagbox*
usage without blocking you with only 4 flags, *Flagbox* defines `,?` and `?,`
aliases. These aliases allow you to go to next or previous box cyclicly. If
your current box is not empty and is the last in your cycle, going to the next
box will build a new one. Building a new box, keeps the marks you defined in
other boxes and allows you to use same aliases for different directories you
want to save.

Let's assume you have a current lonely and empty box. Using `,?` alias will
not create a new box because its empty. We have to fill it with an alias.

</br>
<img src="/media/filledbox.png">
</br>

Now using `,?` alias will create a new box where you can reuse `,` alias for
an other directory.

</br>
<img src="/media/2boxes.png">
</br>

With these two boxes you just have to use `,?` and `?,` to switch box and use
`,` alias for the directory you need to go.

If you need to delete a box, you have to empty it and use the full question
marks alias on it:

</br>
<img src="/media/deletebox.png">
</br>

## Configuration
