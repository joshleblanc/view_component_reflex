# Change Log

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [2.3.0](https://github.com/joshleblanc/view_component_reflex/compare/v2.2.2...v2.3.0) (2020-09-22)


### Features

* allow specifying the base reflex class ([7147d6c](https://github.com/joshleblanc/view_component_reflex/commit/7147d6c))
* allow using callbacks ([f1a8224](https://github.com/joshleblanc/view_component_reflex/commit/f1a8224))



## [2.2.2](https://github.com/joshleblanc/view_component_reflex/compare/v2.2.1...v2.2.2) (2020-09-16)

* data-key blank in views due to html file detection ([97b63f2f](https://github.com/joshleblanc/view_component_reflex/commit/97b63f2f6db3c3cf54cadc527cd1979304391399))

### [2.2.1](https://github.com/joshleblanc/view_component_reflex/compare/v2.2.0...v2.2.1) (2020-08-26)


### Bug Fixes

* explicitly use ViewComponentReflex::Reflex ([3ddd2e3](https://github.com/joshleblanc/view_component_reflex/commit/3ddd2e39e9eb18db0f1341dc6cb5bd1abc0f0da4))

## [2.2.0](https://github.com/joshleblanc/view_component_reflex/compare/v2.1.5...v2.2.0) (2020-08-24)


### Features

* add reflex_data_attributes ([#8](https://github.com/joshleblanc/view_component_reflex/issues/8)) ([51119e3](https://github.com/joshleblanc/view_component_reflex/commit/51119e39827dc43b24b85439aab98a0a20e3846b))

### [2.1.5](https://github.com/joshleblanc/view_component_reflex/compare/v2.1.4...v2.1.5) (2020-08-16)


### Bug Fixes

* pin stimulus_reflex to 3.3.0.pre2 ([52e935b](https://github.com/joshleblanc/view_component_reflex/commit/52e935b0da2379d68acdab2754bb8547656ebc8a))

### [2.1.4](https://github.com/joshleblanc/view_component_reflex/compare/v2.1.3...v2.1.4) (2020-08-16)


### Bug Fixes

* possibly modifying frozen object ([7d50b60](https://github.com/joshleblanc/view_component_reflex/commit/7d50b60286feae6c804b94389928258f1f8fb923))

### [2.1.3](https://github.com/joshleblanc/view_component_reflex/compare/v2.1.2...v2.1.3) (2020-08-06)


### Bug Fixes

* replace state in memory's store_state ([8ba916d](https://github.com/joshleblanc/view_component_reflex/commit/8ba916dea7b78e593dce18f7b1e883d17e1d7ca6))
* view component reflexes wouldn't accept arguments ([6086ecc](https://github.com/joshleblanc/view_component_reflex/commit/6086ecc44dc22c83a56e5e96ee5438231679b6fa))

### [2.1.1](https://github.com/joshleblanc/view_component_reflex/compare/v2.1.0...v2.1.1) (2020-07-15)


### Bug Fixes

* support namespaced components ([2a326cb](https://github.com/joshleblanc/view_component_reflex/commit/2a326cb81c2205a0fa0cea2ebbd76140cccd7f86))

## [2.1.0](https://github.com/joshleblanc/view_component_reflex/compare/v2.0.2...v2.1.0) (2020-07-10)


### Features

* add stimulate method to stimulate other reflex from a reflex ([a110330](https://github.com/joshleblanc/view_component_reflex/commit/a110330b4faf2424f09bb1e7df74c9a9e9f6f3e1))


### Bug Fixes

* save state if reset by parem ([9f759b4](https://github.com/joshleblanc/view_component_reflex/commit/9f759b4a46cd34b10aa69b222369b7ef0de48263))

### [2.0.2](https://github.com/joshleblanc/view_component_reflex/compare/v2.0.1...v2.0.2) (2020-07-07)


### Bug Fixes

* inputs were losing focus on morph ([e5c08b2](https://github.com/joshleblanc/view_component_reflex/commit/e5c08b2b802e9729388bb7ef0c8449219604d4c3))

### [2.0.1](https://github.com/joshleblanc/view_component_reflex/compare/v2.0.0...v2.0.1) (2020-07-07)


### Bug Fixes

* broadcast morphs ([803651b](https://github.com/joshleblanc/view_component_reflex/commit/803651be0727f8212fc5de82e032a03314801aac))
* morph instead of x_html ([1dde351](https://github.com/joshleblanc/view_component_reflex/commit/1dde351df62b1388411cb3da4942b6be7c736eb4))
* save content to state ([1d62395](https://github.com/joshleblanc/view_component_reflex/commit/1d62395fe24d304c936de632cf6d4485a1bf347a))

## [2.0.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.7.2...v2.0.0) (2020-07-07)


### ⚠ BREAKING CHANGES

* prevent_refresh! default was a breaking change

### Features

* manually replace only the component html, without rendering page ([106f643](https://github.com/joshleblanc/view_component_reflex/commit/106f643943df34a46f3e24155c336ffef93b1e17))


### Bug Fixes

* check if a selector is passed before replacing it ([6201b4f](https://github.com/joshleblanc/view_component_reflex/commit/6201b4f4c22bbbb12722d45b37b597024c7735f9))
* only render component directly if nothing omitted_from_state ([239a2bb](https://github.com/joshleblanc/view_component_reflex/commit/239a2bbce8bf01d61614f1ad61ea13bc025122ea))
* render entire page if custom selector provided ([fc37c6c](https://github.com/joshleblanc/view_component_reflex/commit/fc37c6c9eed98850de7cca865387dc55c90651a7))
* share selector with component ([0405565](https://github.com/joshleblanc/view_component_reflex/commit/0405565c77fcd72e78944d9e0da6c8f41e3d8ef4))


* prevent_refresh! default was a breaking change ([b043ea2](https://github.com/joshleblanc/view_component_reflex/commit/b043ea215d58ee565eb99e8a66036d867d229715))

### [1.7.2](https://github.com/joshleblanc/view_component_reflex/compare/v1.7.1...v1.7.2) (2020-07-06)

### [1.7.1](https://github.com/joshleblanc/view_component_reflex/compare/v1.7.0...v1.7.1) (2020-07-05)


### Bug Fixes

* set correct versions in gemspec ([8b4916c](https://github.com/joshleblanc/view_component_reflex/commit/8b4916c6b82dd271d65358835a143b5de1193b69))

## [1.7.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.6.1...v1.7.0) (2020-07-05)


### Features

* add memory state adapter ([83403d2](https://github.com/joshleblanc/view_component_reflex/commit/83403d2a2a6a41a7bfe425d1253a57bf38def4d8))
* make memory adapter the default ([68079b7](https://github.com/joshleblanc/view_component_reflex/commit/68079b77d5db22f2e639239a8f90560b917fd3e9))


### Bug Fixes

* decouple key from session ([bdd41b5](https://github.com/joshleblanc/view_component_reflex/commit/bdd41b5261673d57f51d9e3abc76fe3883f56b07))

### [1.6.1](https://github.com/joshleblanc/view_component_reflex/compare/v1.6.0...v1.6.1) (2020-06-26)


### Bug Fixes

* default options to hashes ([d56a732](https://github.com/joshleblanc/view_component_reflex/commit/d56a732e390ad7d05686f42c987c0d7ff399c5e2))

## [1.6.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.5.0...v1.6.0) (2020-06-25)


### Features

* allow passing element to component_controller ([3ddbd28](https://github.com/joshleblanc/view_component_reflex/commit/3ddbd288a8f8175c0bfbf1b0ab5a5fe8e01d16e6))


### Bug Fixes

* ensure reflex is a string ([55cec0a](https://github.com/joshleblanc/view_component_reflex/commit/55cec0a0b43aa5653421ee10b86e1eb227c0e2f9))

## [1.5.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.4.0...v1.5.0) (2020-06-22)


### Features

* add reflex tag helper ([c2395f4](https://github.com/joshleblanc/view_component_reflex/commit/c2395f4b8d75b1db56dc84c6dd13f4976e813d39))

## [1.4.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.3.0...v1.4.0) (2020-06-21)


### Features

* add flag to prevent default re-render ([acb84ca](https://github.com/joshleblanc/view_component_reflex/commit/acb84caeb4fb8c8518c332cd7befd210b2d03ee1))

## [1.3.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.2.0...v1.3.0) (2020-06-21)


### Features

* add ability to not save vars to state ([c11f611](https://github.com/joshleblanc/view_component_reflex/commit/c11f611f089962e6fd3bcd74dfc803dfe6fc6c70))


### Bug Fixes

* forward session ([3dbb98e](https://github.com/joshleblanc/view_component_reflex/commit/3dbb98e27fe835e75362a51e2a11b22bd600b98f))

## [1.2.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.1.1...v1.2.0) (2020-06-20)


### Features

* allow instance variables to be overridden by props ([c9e3a9e](https://github.com/joshleblanc/view_component_reflex/commit/c9e3a9e01170069b0bd56df5994738b1b349f7d2))


### Bug Fixes

* pass request and controller instead of reflex ([6d8c295](https://github.com/joshleblanc/view_component_reflex/commit/6d8c295836d1fb38c09a88cf8516102ea40071bb))

### [1.1.1](https://github.com/joshleblanc/view_component_reflex/compare/v1.1.0...v1.1.1) (2020-06-20)


### Bug Fixes

* initialize key in component_controller ([26da2f4](https://github.com/joshleblanc/view_component_reflex/commit/26da2f494f275331d94262410e9334cf0f5001b0))
* nested components wouldn't maintain state ([e27e0dc](https://github.com/joshleblanc/view_component_reflex/commit/e27e0dc1d9ddb3fc4ecaf8875465ce0af72bba1e))

## [1.1.0](https://github.com/joshleblanc/view_component_reflex/compare/v1.0.1...v1.1.0) (2020-06-19)


### Features

* add collection_key functionality for collection rendering ([4410987](https://github.com/joshleblanc/view_component_reflex/commit/44109878b72842253a83d0a5ca457c2970932b02))
* all passing options to component_controller ([606c03b](https://github.com/joshleblanc/view_component_reflex/commit/606c03bde5b2d433ee231ec138af219c3cb2371d))


### Bug Fixes

* add default ([b1c1526](https://github.com/joshleblanc/view_component_reflex/commit/b1c15266323e8822807d2b9de6f38cd844ebe47d))
* include any passed data attributes ([ab04569](https://github.com/joshleblanc/view_component_reflex/commit/ab0456983cea3460ddd6249d6cb7592db021a93c))
* initialize stimulus in component_controller ([cd6e9da](https://github.com/joshleblanc/view_component_reflex/commit/cd6e9dac725df28779fdcfbb4319b78ec34e222c))
* loosen selector requirement ([3454a44](https://github.com/joshleblanc/view_component_reflex/commit/3454a44b8a5a6c711ed60402ab53326a6edb6616))

### [1.0.1](https://github.com/joshleblanc/view_component_reflex/compare/v1.0.0...v1.0.1) (2020-06-19)


### Bug Fixes

* forward request to reflex component ([43fc585](https://github.com/joshleblanc/view_component_reflex/commit/43fc5854d82672ebe64ae73277f8d65837565854))
* foward params ([0fa1ae1](https://github.com/joshleblanc/view_component_reflex/commit/0fa1ae1cefa6af8bbc4ba6f0f5cb4400eaa5a731))
* permanent attribute name wasn't being detected ([fce1e3c](https://github.com/joshleblanc/view_component_reflex/commit/fce1e3cf47a455cb1c3412ba5970b196a49609c4))

## [1.0.0](https://github.com/joshleblanc/view_component_reflex/compare/v0.6.3...v1.0.0) (2020-06-18)


### Features

* add helper for controller ([07a4ff3](https://github.com/joshleblanc/view_component_reflex/commit/07a4ff326cf237b3fdff48e8ee36cf396c4e97d9))
* refactor state into instance variables ([388b44c](https://github.com/joshleblanc/view_component_reflex/commit/388b44c2938b5534eac880ea62cc0baa3501df37))


### Bug Fixes

* expose the element method to the component ([a0e012b](https://github.com/joshleblanc/view_component_reflex/commit/a0e012b53170680876306c468fe89d046e58bee5))
* fallback to super ([bd1179f](https://github.com/joshleblanc/view_component_reflex/commit/bd1179f32ab32691435facdc7d713a9b8cf67ace))
* forward refresh! and refresh_all! ([45396a0](https://github.com/joshleblanc/view_component_reflex/commit/45396a048dc9f5a4664f664f1f6ee86734335305))
* implement respond_to_missing? ([880fde1](https://github.com/joshleblanc/view_component_reflex/commit/880fde1447a86fb1e8515467ebecd55887a1e3c2))
* include data-key in component selector ([7d467a8](https://github.com/joshleblanc/view_component_reflex/commit/7d467a8e446e7bcfba1eb002657ae7e53a0007eb))
* instantiate component without props ([a976f79](https://github.com/joshleblanc/view_component_reflex/commit/a976f79e0069f25451316a7d1c872889c9e84632))
* make set_state private ([fcabeb4](https://github.com/joshleblanc/view_component_reflex/commit/fcabeb40c036e19db133492f83f2163a2cff317b))
* make state method private ([792850e](https://github.com/joshleblanc/view_component_reflex/commit/792850eaf6ce6d85dd4bdc93cf62e10151be1268))
* make stimulus_controller private ([d0ac468](https://github.com/joshleblanc/view_component_reflex/commit/d0ac46893fd6aa7d72e755d4ffa8f4b1ca785f68))
* minor performance improvement in key generation ([fff713b](https://github.com/joshleblanc/view_component_reflex/commit/fff713b61a039546f47443aeae2dbec8fba37c29))
* move method injection to target assignment ([11dcb8b](https://github.com/joshleblanc/view_component_reflex/commit/11dcb8b72ccb4a72ec08c59142db948e0a89365c))
* only re-render component ([660c69a](https://github.com/joshleblanc/view_component_reflex/commit/660c69aa9a69d5772c2ebd8e54fd5ef4de6b8bef))
* pretend the reflex method exists ([367e4c0](https://github.com/joshleblanc/view_component_reflex/commit/367e4c06931b6389535640176b95cc07abcbddab))
* remove refresh from set_state ([4f4774c](https://github.com/joshleblanc/view_component_reflex/commit/4f4774cb6dc98e9bfc5d796d46f0e65d2932316a))
* save state before re-rendering ([3858fed](https://github.com/joshleblanc/view_component_reflex/commit/3858fed0f4135a84e1feff852f173fa58447f5e0))
* select correct file to generate key ([8479088](https://github.com/joshleblanc/view_component_reflex/commit/84790887f96786f38a2a36c4825ea913c8760b3c))

### [0.6.3](https://github.com/joshleblanc/view_component_reflex/compare/v0.6.2...v0.6.3) (2020-06-15)


### Bug Fixes

* remove reconcile state from session state adapter ([653cb54](https://github.com/joshleblanc/view_component_reflex/commit/653cb546719dda141f0cdcdad36d21c035c705f9))
* remove unneccessary initial state ([8ce3fba](https://github.com/joshleblanc/view_component_reflex/commit/8ce3fba17c6f5b2af96a64653b96bf17247c4b4b))

### [0.6.2](https://github.com/joshleblanc/view_component_reflex/compare/v0.6.1...v0.6.2) (2020-06-13)


### Features

* allow passing a selector to set_state ([e036f7f](https://github.com/joshleblanc/view_component_reflex/commit/e036f7f66e82daf1d0724e89eab837361a65f42d))


### Bug Fixes

* pass correct params to refresh ([514ed4c](https://github.com/joshleblanc/view_component_reflex/commit/514ed4c980343399702614b1cee0760947cb2e46))

### [0.6.1](https://github.com/joshleblanc/view_component_reflex/compare/v0.6.0...v0.6.1) (2020-06-11)


### Bug Fixes

* use splat for selectors ([551fd8f](https://github.com/joshleblanc/view_component_reflex/commit/551fd8fb338e376ae79ad634e5cb66591ff6582d))
