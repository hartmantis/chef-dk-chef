Chef-DK Cookbook CHANGELOG
==========================

v3.1.0 (2015-06-03)
-------------------
* Add support for installing on Fedora, via [@joemiller][]

[@joemiller]: https://github.com/joemiller

v3.0.1 (2015-05-13)
-------------------
* Fix errors in Windows from trying to set up an unsupported shell-init, via
  [@mcallb][]
* Don't install the Omnijack gem when a `package_url` is provided, via
  [@mcallb][]

[@mcallb]: https://github.com/mcallb

v3.0.0 (2014-11-28)
-------------------
* Drop support for Chef-DK < 0.2.2
* Fix bug with `package_url` option not being respected

v2.0.3 (2014-10-24)
-------------------
* Switch release tool from Stove to Emeril

v2.0.2 (2014-10-24)
-------------------
* Update required version of Omnijack; fix issues with Ruby exceptions being
  thrown on nodes with Chef installed via system packages

v2.0.1 (2014-09-19)
-------------------
* Fix failure when installing Chef-DK 0.2.2+ on Mac
* Log a warning message on "yolo" unsupported package installs

v2.0.0 (2014-09-15)
-------------------
* Use the Omnijack Ruby Gem for queries to the Omnitruck API
* Support optionally installing prerelease or nightly builds
* Use Chef's Omnitruck metadata service to always know the 'latest' version
* Update to ChefDK 0.2.1-1 as 'latest' version
* Support pre-11.12.0 Chef on all platforms but Windows
* Add ability to set `chef shell-init` system-wide, via [@patrickayoup][]

[@patrickayoup]: https://github.com/patrickayoup

v1.0.2 (2014-07-31)
-------------------
* Fix bug with OS X package reinstalling on every Chef run

v1.0.0 (2014-07-19)
-------------------
* Update to the latest Chef-DK, v0.2.0-2
* Add Windows support
* Refactor the one monolithic provider into platform-specific ones

v0.3.2 (2014-07-03)
-------------------
* Fix recipe compilation errors in chef-client/chef-zero, via [@someara][]

[@someara]: https://github.com/someara


v0.3.0 (2014-06-28)
-------------------
* Allow user to set a custom `package_url`


v0.2.0 (2014-06-27)
-------------------
* Add OS X support


v0.1.0 (2014-06-23)
-------------------
- Initial release!


v0.0.1 (2014-06-16)
-------------------
- Development started
