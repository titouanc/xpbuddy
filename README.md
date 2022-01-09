# xpbuddy

XP Buddy is a simply World of Warcraft addon to measure the progression of
experience points of your character and its pets, all over a gaming session and
in instances.

It is currently developed and tested on the official WoW TBC client.

## Installation

Go to the latest release page: https://github.com/titouanc/xpbuddy/releases/latest

Download the file xpbuddy-VERSION.zip, and extract its content (the folder `xpbuddy`)
in `<Wow installation directory>/Interface/Addons`

## Usage

By default, XPBuddy shows a message in the chat when:
* Exitting an instance
* Summoning or dismissing a pet

To see the actual status of your (and your pets) XP gains, you can type

```
/xpbuddy
```

## Development

### Building the addon

```shell
make dist
```

Then copy the folder `xpmeter` in Wow's `Interface/Addons`


### Running tests

```shell
make test
```

Look in tests/ to see how test functions look like.
