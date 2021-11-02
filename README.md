# flagbox - a 2-keys marks manager for Bash

<img src="/media/weirdcommands.png">

Did you ever see those typed commands in a terminal ? Whatever your answer, I
am convinced that you find it ambiguous and not friendly-user. You are right:
flagbox was not conceived with friendly-usage in mind. It was conceived for
efficiency. For this purpose friendly-user aspect was not a priority during
flagbox conception. If you are searching a tool which allows you to make a
similar job with a more friendly usage, you can go to the Credit section of
this README. Most of them inspired the creation of flagbox.

flagbox is a mark manager. It allows you to save the directory you are in and
jump it later.

## Basic usage

Saving a directory is easy. If your flagbox settings are default settings, when
you launch your terminal you have an empty box. Type `?` to see your current
box content:

<img src="/media/chain1.png">

Here flagbox is saying that your current box is empty. After entering `,` and
typing `?` again, you can easily understand that the `,` mark is used for the
directory where you used `,`.

<img src="/media/chain0.png">

Now if you are changing directory (exemple: `/tmp` directory), and you type
`,`, you will come-back to the directory pointed by `,` mark. Full commas
aliases are used by flagbox to allow you to save directory and jump it later.
By default, you can save up to 3 marks in a box (`,`, `,,` and `,,,` marks).
You can change this setting in your `.flagbox.conf` file. We will talk about
flagbox configuration in documentation pages.

What now if you want to erase a mark that you will not use anymore ? flagbox
generates resetting aliases for this purpose. Suppose that your current box is
builded with the following content:

<img src="/media/fullfilledbox.png">

Resetting a mark is a bit tricky but really easy to use when you understand
the mechanism. To reset a mark you have to build a string composed with `?`
and `,` characters. A comma means 'keep the matched mark' and a `?` means
'reset the matched mark'. For the above box, if you type: `?,?` you will
reset `,` mark, keep `,,` mark and reset `,,,` marks because for the first and
third string's indexes, you place `?` characters.

<img src="/media/chain101.png">

Now that you know how to save a directory, delete a mark, use a mark and list
marks you defined, you have enough background for a basic usage of this tool.
If you can to learn more about advanced features, you can read the
DOCUMENTATION.md file on this repository.

## Installation

1. `git clone https://github.com/pabtomas/flagbox.git`
2. `cd flagbox/`
3. `cp flagbox.sh ${HOME}/.local/bin/`
4. add `source ${HOME}/.local/bin/flagbox.sh` into `~/.bashrc` or `~/.bash_profile`

## Contribution

## Credit

https://github.com/huyng/bashmarks
https://github.com/twerth/bashmarks
