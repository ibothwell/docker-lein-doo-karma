# docker-lein-doo-karma

Docker image with [lein](https://github.com/technomancy/leiningen),
[doo](https://github.com/bensu/doo) 
and [karma](https://karma-runner.github.io/) for ClojureScript tests.

There are three runners available with this image
 * chromium-headless
 * firefox
 * nashorn
 
## Dockerfile contents
* `Dockerfile` is based on official `clojure:lein-2.8.1-alpine`
* Installs Chromium (courtesy of [this Dockerfile](https://github.com/Zenika/alpine-chrome/blob/master/Dockerfile))
* Adds wrappers for Firefox to use Xvfb and for Chromium to use --no-sandbox and other flags using 
[this technique](https://github.com/laurentj/slimerjs/blob/master/Dockerfile) 
* Installs `karma-cli` globally
* Creates WORKDIR at `/usr/share/build` and installs karma and runners locally
* Adds `profiles.clj` with path to karma installation at WORKDIR to be copied to project folder 

## .gitlab-ci.yml example 
```
# .gitlab-ci.yml
image: ai212983/lein-doo-karma
before_script:
  # copy node modules and profiles.clj to current directory
  - cp -a /usr/share/build/. ./
  # download deps
  - lein deps
test:
  script:  
    - lein doo chrome-headless test once
    - lein doo firefox test once
```

 
## Notes

### Nashorn limitations
Nashorn is bundled with official `clojure:lein-2.8.1-alpine`, which is used as base image.
Karma is not required for doo nashorn runner. 

Being a JS engine, not browser, Nashorn have no access to DOM. 
It can't be used if DOM/React related code is compiled into the tests. 
Even if the tests are not using DOM/React directly, watch out for dependencies.

### Puppeteer
[Puppeteer](https://github.com/GoogleChrome/puppeteer) is a Node library providing API to control 
headless Chrome/Chromium via [DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/).

It is should be a preferable way to interact with Chrome from Node, but to use it with Karma, 
it is required to customize `karma.conf.js`.

Doo does not support this, as it generates config file itself.






