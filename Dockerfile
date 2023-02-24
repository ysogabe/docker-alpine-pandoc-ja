FROM pandoc/alpine-crossref:2.14.1 as alpine-builder

FROM adoptopenjdk/openjdk16:alpine

LABEL maintainer="y.sogabe <y.sogabe@gmail.com>" \
      description="Pandoc for Japanese based on Alpine Linux. with PlantUML, pandocfilter"

# Install Pandoc
ENV PANDOC_ROOT /usr/local/pandoc
ENV PATH $PATH:$PANDOC_ROOT/bin

COPY --from=alpine-builder \
  /usr/local/bin/pandoc \
  /usr/local/bin/pandoc-citeproc \
  /usr/local/bin/

COPY --from=alpine-builder \
  /usr/local/bin/pandoc-crossref \
  /usr/local/bin/

RUN apk --no-cache add \
        gmp \
        libffi \
        lua5.3 \
        lua5.3-lpeg

ENV LANG=C.UTF-8
# Install Tex Live
ENV TEXLIVE_VERSION 2021
ENV PATH /usr/local/texlive/$TEXLIVE_VERSION/bin/x86_64-linuxmusl:$PATH

RUN apk --no-cache add perl wget xz tar fontconfig-dev \
 && mkdir -p /tmp/src/install-tl-unx \
 && wget -qO-  http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/install-tl-unx.tar.gz | \
    tar -xz -C /tmp/src/install-tl-unx --strip-components=1 \
 && printf "%s\n" \
      "selected_scheme scheme-basic" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/src/install-tl-unx/texlive.profile \
 && /tmp/src/install-tl-unx/install-tl \
      --profile=/tmp/src/install-tl-unx/texlive.profile \
 && tlmgr option repository http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet \
 && tlmgr update --self && tlmgr update --all \
 && tlmgr install \
      collection-basic collection-latex \
      collection-latexrecommended collection-latexextra \
      collection-fontsrecommended collection-langjapanese latexmk \
      luatexbase ctablestack fontspec luaotfload lualatex-math \
      sourcesanspro sourcecodepro selnolig \
      adjustbox babel-german background bidi \
      collectbox csquotes everypage filehook footmisc \ 
      footnotebackref framed fvextra letltxmacro ly1 mdframed mweights \
      needspace pagecolor sourcecodepro sourcesanspro titling ucharcat \
      ulem unicode-math upquote xecjk xurl zref \
 && rm -Rf /tmp/src \
 && apk --no-cache del xz tar fontconfig-dev

# Install plantuml
#   apline 3.14 NOT HAVE ttf-ubuntu-font-family 
ENV PLANTUML_VERSION 1.2021.10
RUN apk add --no-cache \
    curl \
    graphviz \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation \
 && mkdir -p /usr/share/plantuml \
 && curl -o /usr/share/plantuml/plantuml.jar -JLsS \
    http://sourceforge.net/projects/plantuml/files/plantuml.${PLANTUML_VERSION}.jar/download \
 && ln -s /usr/local/texlive/${TEXLIVE_VERSION}/texmf-dist/fonts/truetype/public/ipaex /usr/share/fonts/ipa \
 && fc-cache -fv \
 && apk del --purge curl

# Install pandocfilters
RUN apk --no-cache add \
    git \
    python2 \
    py2-setuptools \
 && cd /tmp \
 && git clone https://github.com/jgm/pandocfilters.git \
 && cd /tmp/pandocfilters \
 && python setup.py install \
 && sed 's/plantuml.jar/\/usr\/share\/plantuml\/plantuml.jar/' examples/plantuml.py > /usr/share/plantuml/plantuml.py \
 && sed -i.bk 's/latex=\"eps\"/latex=\"png\"/' /usr/share/plantuml/plantuml.py \
 && rm -rf /usr/share/plantuml/plantuml.py.bk \
 && rm -rf /tmp/pandocfilters \
 && chmod +x /usr/share/plantuml/plantuml.py \
 && apk del --purge git py2-setuptools

VOLUME ["/workspace", "/root/.pandoc/templates"]
WORKDIR /workspace