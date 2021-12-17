# Flagbox - a 2-keys bookmarks written in bash

</br>
<img src="/media/weirdcommands.png">
</br>

Did you ever see those typed commands in a terminal before? Whatever your
answer, I am convinced that you find it ambiguous and not friendly-user. You
are right: *Flagbox* was not conceived with friendly-usage in mind. It was
conceived for user efficiency. For this purpose friendly-user aspect was not a
priority during *Flagbox* conception. If you are searching a tool which allows
you to make a similar job with a more friendly usage, you can go to the
**Credit section**. Most of them inspired the creation of *Flagbox*.

*Flagbox* is a mark manager. It allows you to save the directory you are in
and jump it later.

## Basic usage

Saving a directory is easy. If your *Flagbox* settings are default settings,
when you launch your terminal you have an empty box. Type `?` to see your
current box content:

</br>
<img src="/media/chain1.png">
</br>

Here *Flagbox* is saying that your current box is empty. After entering `,`
and typing `?` again, you can easily understand that the `,` mark is used for
the directory where you entered `,`.

</br>
<img src="/media/chain0.png">
</br>

Now if you are changing directory (exemple: `/tmp` directory) and you are
typing `,`, you will come back to the directory pointed by `,` mark. **Full
comma aliases** are used by *Flagbox* to save directory and jump it later.
By default, you can save up to 3 marks in a box (`,`, `,,` and `,,,` marks).
You can change this setting later.

What now if you want to erase a mark that you will not use anymore? *Flagbox*
generates resetting aliases for this purpose. Let's assume that your current
box is built with the following content:

</br>
<img src="/media/fullfilledbox.png">
</br>

Resetting a mark is a bit tricky but really easy to use when you understand
the mechanism. To reset a mark you have to build a string composed with `?`
and `,` characters. A comma means "**keep** the matched mark" and a question
mark means "**reset** the matched mark". For the above box, if you type: `?,?`
you will:
1. reset `,` mark,
2. keep `,,` mark,
3. and reset `,,,` marks

Why? Because for the first and third alias' indexes, you placed `?`
characters.

</br>
<img src="/media/chain101.png">
</br>

Now that you know how to save a directory, delete a mark, use a mark and list
marks you defined, you have enough background for a basic usage of this tool.
If you want to learn about advanced features, you can read the
[documentation](https://github.com/pabtomas/flagbox/blob/master/DOCUMENTATION.md)

## Installation

This repository suggests 2 methods to use *Flagbox*. Depending of your usage
you the installation steps are different.

### First usage installation:

*Flagbox* will source a script. This script will generate aliases described in
the documentation, will build 1 function and will define 1 environment
variable (1 associated array) in your current shell. If this specification is
not respected, please open an issue, I will fix it. If it is OK to integrate
this specification in your workspace, here are the steps:

1. `git clone https://github.com/pabtomas/flagbox.git`
2. copy `flagbox/sourceme.sh` where you want:
```
cp flagbox/sourceme.sh ${WHERE_YOU_WANT}
```
3. `sourceme.sh` generates aliases in the shell the script is sourced so you
have to put this line in your `~/.bashrc` or your `~/.bash_aliases` (which
should be sourced by your `~/.bashrc`):
```
source ${WHERE_YOU_WANT}/sourceme.sh
```

### Second usage installation

If you are concerned by one or more of these reasons, the second usage is for
you:
- sourcing a script you do not written is risky,
- generating aliases is a deprecated Bash feature,
- having an executable is a better practice,
- integrating environment variables and functions in your workspace is not
possible

TODO

## Contribution

I would be very grateful for anybody wanting to contribute anything. Here are
the [instructions](https://github.com/pabtomas/flagbox/blob/master/CONTRIBUTING.md).

## Credit

- [huyng's bashmarks](https://github.com/huyng/bashmarks)
- [twerth's bashmarks](https://github.com/twerth/bashmarks)
