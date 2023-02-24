# alpine-pandoc-ja ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ysogabe/alpine-pandoc-ja) ![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ysogabe/alpine-pandoc-ja)

Pandoc for Japanese based on Alpine Linux. 
Add on PlantUML and pandocfilter(plantuml.py only)

## Usage

```sh
$ docker pull ysogabe/alpine-pandoc-ja
$ docker run -it --rm -v `pwd`:/workspace ysogabe/alpine-pandoc-ja pandoc input.md -f markdown -o output.pdf -V documentclass=ltjarticle -V classoption=a4j -V geometry:margin=1in --pdf-engine=lualatex
```

### Use Template

```
$ mkdir templates
$ wget https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex -O templates/eisvogel.tex
$ docker run -it --rm -v `pwd`:/workspace -v `pwd`/templates:/root/.pandoc/templates ysogabe/pandoc:latest pandoc input.md -f markdown -o output.pdf -V documentclass=ltjarticle -V classoption=a4j -V geometry:margin=1in -V CJKmainfont=IPAexGothic --pdf-engine=lualatex --template eisvogel.tex --listings
```
### Use PlantUML Filter

With [pandocfilter](https://github.com/jgm/pandocfilters) --filter /usr/share/plantuml/plantuml.py option.

```
$ docker run -it --rm -v `pwd`:/workspace ysogabe/alpine-pandoc-ja pandoc input.md -f markdown -o output.pdf -V documentclass=ltjarticle --pdf-engine=lualatex --filter /usr/share/plantuml/plantuml.py
``` 

## Modified from Origin

- Change Base Image frolvlad/alpine-glibc to adoptopenjdk/openjdk12:alpine
- Add PlantUML.jar
- Add pandocfilters

## Reference Dockerfile

- [portown/alpine-pandoc](https://github.com/portown/alpine-pandoc)
- [paperist/alpine-texlive-ja](https://github.com/Paperist/docker-alpine-texlive-ja)
- [AdoptOpenJDK/openjdk-docker](https://github.com/AdoptOpenJDK/openjdk-docker)

---
Edit Test vscode.dev
---