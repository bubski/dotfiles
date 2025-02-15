# dotfiles

```sh
bash -c "$(wget https://raw.githubusercontent.com/bubski/dotfiles/master/install.bash -O -)"
```

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bubski/dotfiles/master/install.bash)"
```

```sh
(
    URL=https://raw.githubusercontent.com/bubski/dotfiles/master/install.bash
    { command -v wget &>/dev/null && bash -c "$(wget $URL -O -)"  } ||\
    { command -v curl &>/dev/null && bash -c "$(curl -fsSL $URL)" }
)
```
