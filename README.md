# David's dotfiles

```
curl --silent https://raw.githubusercontent.com/darenas31415/dotfiles/master/setup.sh | bash
```

## Things I can't do automatically

### GPG Import/Export

```
gpg --import pgp-public-keys.asc
gpg --import pgp-private-keys.asc
gpg --import-ownertrust pgp-ownertrust.asc
```

```
gpg --armor --export > pgp-public-keys.asc
gpg --armor --export-secret-keys > pgp-private-keys.asc
gpg --export-ownertrust > pgp-ownertrust.asc
```

## Inspired by

* https://github.com/mathiasbynens/dotfiles
* https://github.com/sam-hosseini/dotfiles

