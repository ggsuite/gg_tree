# Changelog

## Unreleased

### Changed

- Use ggwsm in pipelines
- Install the dna_ggsuite DNA

## 2.7.0 - 2026-08-13

### Changed

- Rework copyright headers

### Fixed

- Cleanup copy right headers. Update to dart 3.13. Auto fixes.
- Cleanup copy right headers. Update to dart 3.13. Auto fixes. Setup quick-check pipeline.

## 2.6.1 - 2026-07-06

### Changed

- gg_multi: changed references to git
- Gg Multi: changed references to pub.dev

## 2.6.0 - 2026-07-06

### Changed

- Update dependencies, esp. gg_tree for better performance
- Optimize code using claude. Update to gg_json 4.0.0

## 2.5.0 - 2026-07-05

### Added

- Add visitFutureOr

## 2.4.0 - 2026-07-05

### Changed

- Improve performance using claude

## 2.3.1 - 2026-06-08

### Changed

- refactor(ls): move lsNodes back to Tree

## 2.3.0 - 2026-06-08

### Added

- Add code to print the output of ls in different formats

## 2.2.0 - 2026-03-28

### Added

- Add visitAsync

## 2.1.0 - 2026-03-17

### Added

- Add nextSibling, previousSibling

## 2.0.10 - 2026-03-14

### Changed

- allow concurrent modification of trees while visiting

## 2.0.9 - 2026-03-14

### Fixed

- Fix version number in gg

## 2.0.8 - 2026-03-06

### Added

- Add alsoComplexValues param to list also complex values

## 2.0.7 - 2026-03-06

### Removed

- Remove tags support

## 2.0.6 - 2026-03-04

### Fixed

- Fix an error where tags were not parsed

## 2.0.5 - 2026-03-04

### Changed

- Make fromJson static

## 2.0.4 - 2026-03-04

### Fixed

- Fix issue when assigning keys

## 2.0.3 - 2026-03-03

### Changed

- Improve printing values when listing calling tree.ls()

## 2.0.2 - 2026-03-03

### Changed

- Allow to print the values of lsProps()
- lsProps: Allow to filter for keys and values

## 2.0.1 - 2026-03-03

### Added

- Add Tree.remove(...)

## 2.0.0 - 2026-03-02

### Changed

- Make Tree universally process Json
- BREAKING CHANGE: Remove Tree.root constructor.
- Refactor Tree constructors

## 1.0.16 - 2026-02-19

### Fixed

- Fix issue in deepCopy. Parents were wrong

## 1.0.15 - 2026-02-19

### Added

- Add flatcopy
- Add Tree.deepCopy(where)

### Changed

- Make deepCopy really traverse tree

## 1.0.14 - 2026-02-18

### Added

- Add Tree.visit

## 1.0.13 - 2026-02-18

### Added

- Add tags, addTag, removeTag, hasTag

## 1.0.12 - 2026-02-15

### Changed

- Rename stuff

## 1.0.11 - 2026-02-15

### Changed

- ChildIterator: Improve return types

## 1.0.10 - 2026-02-15

### Added

- Add ChildIterator

## 1.0.9 - 2026-02-08

### Changed

- improve error messages when working with a wrong field
- Improve output on querying wrong paths

## 1.0.8 - 2026-02-07

### Added

- add lsProps() to show all nodes along side with its propertie

## 1.0.7 - 2026-02-06

### Added

- Add node to output of ls

### Changed

- Tree.ls() shows also data field paths

### Fixed

- Fix issues with Tree.get

## 1.0.6 - 2026-02-04

### Fixed

- Fix an issue with requesting node infos

### Removed

- Remove publish_to: none

## 1.0.5 - 2026-02-04

### Changed

- Improve error messages. Print error messages when json data path is not found

## 1.0.4 - 2026-02-04

### Changed

- Read node metadata via tree.get('node/*')

## 1.0.3 - 2026-02-04

### Added

- Add pathSimple

## 1.0.2 - 2026-02-04

### Added

- Add lsNodes and lsNodesWhere
- Add childByPathOrNull

### Changed

- kidney: changed references to git
- Rename value into data

## 1.0.1 - 2026-02-02

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

## 1.0.0 - 2025-07-12

### Added

- Initial boilerplate.
- Add JSON serialization

### Changed

- Initial implementation
