### Checklist

- [ ] follow [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)
  - the scope should be the component's name e.g: `feat(StatusListItem): ... `
  - when adding new components, the scope is the module e.g: `feat(StatusQ.Controls): ...`
- [ ] add documentation if necessary (new component, new feature)
- [ ] update sandbox app
  - in case of new component, add new component page
  - in case of new features, add variation to existing component page
  - nice to have: add it to the demo application as well
- [ ] is this a breaking change?
    - [ ] use the dedicated `BREAKING CHANGE` commit message section
    - [ ] resolve breaking changes in [status-desktop](https://github.com/status-im/status-desktop)
        - [ ] (pre-merge) adapt code to breaking changes
        - [ ] (post-merge) update StatusQ submodule pointer
- [ ] test changes in [status-desktop](https://github.com/status-im/status-desktop)
