# Changelog

## [2.0.3] - 2026-03-03

### Changed

- Improve printing values when listing calling tree.ls()

## [2.0.2] - 2026-03-03

### Changed

- Allow to print the values of lsProps()
- lsProps: Allow to filter for keys and values

## [2.0.1] - 2026-03-03

### Added

- Add Tree.remove(...)

## [2.0.0] - 2026-03-02

### Changed

- Make Tree universally process Json
- BREAKING CHANGE: Remove Tree.root constructor.
- Refactor Tree constructors

## [1.0.16] - 2026-02-19

### Fixed

- Fix issue in deepCopy. Parents were wrong

## [1.0.15] - 2026-02-19

### Added

- Add flatcopy
- Add Tree.deepCopy(where)

### Changed

- Make deepCopy really traverse tree

## [1.0.14] - 2026-02-18

### Added

- Add Tree.visit

## [1.0.13] - 2026-02-18

### Added

- Add tags, addTag, removeTag, hasTag

## [1.0.12] - 2026-02-15

### Changed

- Rename stuff

## [1.0.11] - 2026-02-15

### Changed

- ChildIterator: Improve return types

## [1.0.10] - 2026-02-15

### Added

- Add ChildIterator

## [1.0.9] - 2026-02-08

### Changed

- improve error messages when working with a wrong field
- Improve output on querying wrong paths

## [1.0.8] - 2026-02-07

### Added

- add lsProps() to show all nodes along side with its propertie

## [1.0.7] - 2026-02-06

### Added

- Add node to output of ls

### Changed

- Tree.ls() shows also data field paths

### Fixed

- Fix issues with Tree.get

## [1.0.6] - 2026-02-04

### Fixed

- Fix an issue with requesting node infos

### Removed

- Remove publish\_to: none

## [1.0.5] - 2026-02-04

### Changed

- Improve error messages. Print error messages when json data path is not found

## [1.0.4] - 2026-02-04

### Changed

- Read node metadata via tree.get('node/\*')

## [1.0.3] - 2026-02-04

### Added

- Add pathSimple

## [1.0.2] - 2026-02-04

### Added

- Add lsNodes and lsNodesWhere
- Add childByPathOrNull

### Changed

- kidney: changed references to git
- Rename value into data

## [1.0.1] - 2026-02-02

### Added

- Add .gitattributes file
- Add TreeTools
- Add deepCopy
- Add various queries

### Changed

- Publish to pub.dev
- Basic implementation
- Auto rename nodes on same keys
- Work on queries

## [1.0.0] - 2025-07-12

### Added

- Initial boilerplate.
- Add JSON serialization

### Changed

- Initial implementation

[2.0.3]: https://github.com/ggsuite/gg_tree/compare/2.0.2...2.0.3
[2.0.2]: https://github.com/ggsuite/gg_tree/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/ggsuite/gg_tree/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/ggsuite/gg_tree/compare/1.0.16...2.0.0
[1.0.16]: https://github.com/ggsuite/gg_tree/compare/1.0.15...1.0.16
[1.0.15]: https://github.com/ggsuite/gg_tree/compare/1.0.14...1.0.15
[1.0.14]: https://github.com/ggsuite/gg_tree/compare/1.0.13...1.0.14
[1.0.13]: https://github.com/ggsuite/gg_tree/compare/1.0.12...1.0.13
[1.0.12]: https://github.com/ggsuite/gg_tree/compare/1.0.11...1.0.12
[1.0.11]: https://github.com/ggsuite/gg_tree/compare/1.0.10...1.0.11
[1.0.10]: https://github.com/ggsuite/gg_tree/compare/1.0.9...1.0.10
[1.0.9]: https://github.com/ggsuite/gg_tree/compare/1.0.8...1.0.9
[1.0.8]: https://github.com/ggsuite/gg_tree/compare/1.0.7...1.0.8
[1.0.7]: https://github.com/ggsuite/gg_tree/compare/1.0.6...1.0.7
[1.0.6]: https://github.com/ggsuite/gg_tree/compare/1.0.5...1.0.6
[1.0.5]: https://github.com/ggsuite/gg_tree/compare/1.0.4...1.0.5
[1.0.4]: https://github.com/ggsuite/gg_tree/compare/1.0.3...1.0.4
[1.0.3]: https://github.com/ggsuite/gg_tree/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/ggsuite/gg_tree/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/ggsuite/gg_tree/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/ggsuite/gg_tree/tag/%tag
