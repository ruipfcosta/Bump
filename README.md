# Bump

Bump is a command line utility to bump your app versions acording to the format you specify. 

**Notice: Bump is still an experimental idea therefore not ready yet for production use.**

## How does it work?

That's the easiest part! Simply create a file named `Bumpfile` with the configurations for the version updates of your apps. Then run `bump` on the same directory.


### Bumpfile

The Bumpfile tells Bump what versions need updating and how they should be updated. The format for entries on the Bumpfile is simple:

```
[Type] [Version update format] [Target] [Optional xcodeproj path]
```

Here's an example of the Bumpfile for an iOS project with two entries:

```
xcode 1.*[digit].0 "App Target 1"
xcode 5.*[date:yyyyMMdd] "App Target 2"
```

The version number of `App Target 1` is defined as `1.*[digit].0`. Wildcards (`*` symbol) are used to indicate what part of the version number should be updated when Bump is executed. Assuming the current version is 1.12.0, acording to the format specfied on the Bumpfile the next version should be 1.13.0, and so on.

`App Target 2` however uses a different format, defined as `5.*[date:yyyyMMdd]`. In this case, a date wildcard is used on the format. Assuming the current version is 5.20190101, if Bump is run on the 28/04/2019, the next version will be set as 5.20190428.

#### Available Wildcards

##### Digit
`*[digit]`

##### Date
`*[date:format]`, where *format* can be something like `yyyy-MM-dd`, `MMdd`, etc.

### Supported Projects

For the time being only Xcode projects are supported, but the plan is to add support for other types of projects.

