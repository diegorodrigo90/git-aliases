# Git aliases commands for lazy developers

This script install some usefully git aliases for lazy developers.

## Install

Clone this repo.

Run the commands:

```bash
chmod +x git-aliases.sh
```

```bash
./git-aliases.sh
```

Close and open your terminal.

## Uninstall

```bash
./git-aliases.sh -u
```

## Available aliases

 Alias             |      Command                                       |
|------------------|:--------------------------------------------------:|
| **git co**       |  git checkout                                      |
| **git br**       |  git branch                                        |
| **git ci**       |  git commit                                        |
| **git st**       |  git status                                        |
| **git unstage**  |  git reset HEAD --                                 |
| **gac**          |  git add . && git commit                           |
| **gi**           |  git init && gac -m 'Initial commit'               |
| **gam**          |  git commit --amend                                |
| **gadm**         |  git add . && git commit                           |
| **gp**           |  git push                                          |
| **gpo**          |  git push origin $(git rev-parse --abbrev-ref HEAD)|
| **gpu**          |  git push -u                                       |
| **gpou**         |  git push -u $(git rev-parse --abbrev-ref HEAD)    |
| **gl**           |  git pull                                          |
| **gst**          |  git status                                        |
| **glog**         |  git log                                           |
| **gfo**          |  git fetch origin                                  |

* **$(git rev-parse --abbrev-ref HEAD)** gets the current branch

## Add your own aliases

You can customize the alias editing the files  `git-alias.txt` or `shell-alias.txt`.

## About

This script was created for my blog, [see the article here](https://www.diegorodrigo.dev/en/2022/12/04/make-your-life-in-linux-easier-with-aliases/).
