# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

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
